library(dplyr)
library(tidyr)
library(readr)
library(purrr)
library(pmeasyr)
library(lubridate)
library(stringr)

# fonction créant la DB en utilisant le fichier "make_table.sql"
create_db <- function(con) {
  # les query doivent etre executée en plusieurs fois
  # donc extraction + map()
  create_statements <- read_file("make_tables.sql") %>% 
    str_split(";") %>% 
    map(str_c, ";") %>% 
    unlist()
  
  create_statements <- create_statements[-length(create_statements)]
  
  map(create_statements, function(x) {dbSendStatement(con, x)})
}

# fonction gérant l'extraction et le data management des tables
tbls_from_rsa <- function(p) {
  sejour <- p %>%  irsa()
  diags <- sejour$das
  actes <- sejour$actes
  rum <- sejour$rsa_um
  sejour <- sejour$rsa
  
# table transmission  
  transmission <- list("id" = 1,
                       "finess" = p[[1]],
                       "annee" = p[[2]],
                       "mois" = p[[3]])
  
# correspondance RUM
  corres_rum <- rum %>% 
    select(CLE_RSA, NSEQRUM) %>% 
    mutate(id_rum = row_number())

# table diagnostiques  
  dpdr <- rum %>% 
    select(CLE_RSA, NSEQRUM, 
           DPUM, DRUM) %>% 
    mutate(DPUM = as.character(DPUM),
           DRUM = as.character(DRUM)) %>% 
    gather(rang, cim10, DPUM, DRUM) %>% 
    mutate(rang = ifelse(rang == "DPUM", 1, 2)) %>% 
    select(CLE_RSA, NSEQRUM, cim10, rang)
  
  diags <- diags %>% 
    select(CLE_RSA, NSEQRUM,
           cim10 = DAS) %>% 
    mutate(rang = 3) %>% 
    bind_rows(dpdr) %>% 
    filter(cim10 != "",
           !is.na(cim10)) %>%
    mutate(id = row_number()) %>% 
    select(CLE_RSA, NSEQRUM, id, cim10, rang) %>% 
    left_join(corres_rum, by = c("CLE_RSA", "NSEQRUM")) %>% 
    select(-CLE_RSA, -NSEQRUM)
  
  rm(dpdr)

# table actes  
  actes <- actes %>% 
    select(CLE_RSA, NSEQRUM, 
           ccam = CDCCAM) %>% 
    mutate(id = row_number()) %>% 
    select(CLE_RSA, NSEQRUM, id, ccam) %>% 
    left_join(corres_rum, by = c("CLE_RSA", "NSEQRUM")) %>% 
    select(-CLE_RSA, -NSEQRUM)
    

# table rum
  rum <- rum %>% 
    select(id_sejour = CLE_RSA, 
           duree = DUREESEJPART,
           NSEQRUM) %>% 
    mutate(id_sejour = as.numeric(id_sejour),
           id = row_number()) %>% 
    group_by(id_sejour) %>% 
    mutate(numero = row_number()) %>% 
    select(id, numero, duree, id_sejour)
    
# table sejour  
  sejour <- sejour %>% 
    select(id = CLE_RSA,
           code_postal = CDGEO,
           SEXE,
           mode_entree = ECHPMSI,
           mode_sortie = SCHPMSI,
           MOISSOR,
           ANSOR,
           rum_groupant = NOSEQRUM,
           DUREE,
           ghm)
  
  sejour <- sejour %>%
    mutate(homme = SEXE == 1,
           date_sortie = ymd(str_c(ANSOR, MOISSOR, "27")),
           date_entree = date_sortie - DUREE,
           mode_entree = as.integer(mode_entree),
           mode_sortie = as.integer(mode_sortie),
           id = as.integer(id),
           id_transmission = transmission[["id"]]) %>% 
  select(id, 
         ghm, 
         mode_entree,
         mode_sortie, 
         date_entree,
         date_sortie,
         code_postal,
         homme,
         id_transmission)
  
  list("transmission" = data.frame(transmission),
       "sejour" = sejour, 
       "rum" = rum, 
       "acte" = actes, 
       "diagnostique" = diags)
}

# fonction mettant a jour les clés primaire des tables
update_pk <- function(con, name, df) {
  key <- dbGetQuery(con, str_c(
  "SELECT tables.name as tname, objects.name as kname FROM tables JOIN keys ON tables.id = keys.table_id JOIN objects ON keys.id = objects.id WHERE tables.name='",
  name, "' and keys.type = 0"))
  
  key <- pull(key, 2)
  max_key <- dbGetQuery(con, str_c("select max(", key, ") from ", name))
  max_key <- pull(max_key, 1)
  if (is.na(max_key)) {
    max_key <-  0
  }
  
  df[[key]] <-  df[[key]] + max_key
  df
}

# fonction mettant a jour les clé secondaire des tables (foreign keys)
update_fk <- function(con, name, df) {
  keys <- dbGetQuery(con, str_c("with fk as(
    SELECT
    tables.name as tname,
    objects.name as fkname,
    keys.rkey as rkey
    from 
    tables
    join keys on tables.id = keys.table_id
    join objects on keys.id = objects.id
    where 
    tables.system=false
    and keys.type = 2
    and tables.name ='", name, 
  "' )
  select 
  fk.tname as tname,
  fk.fkname as fkname,
  tables.name as ptname,
  objects.name as pkname
  from 
  fk
  join keys on fk.rkey = keys.id
  join tables on keys.table_id = tables.id
  join objects on keys.id = objects.id"))
  
  i <- 1
  while (i <= nrow(keys)){
    max_key <- dbGetQuery(con, str_c("select max(", 
                                     keys[i, 4], ") from ", keys[i, 3]))
    max_key <- pull(max_key, 1)
    if (is.na(max_key)) {
      max_key <-  0
    }
    
    df[[keys[i, 2]]] <-  df[[keys[i, 2]]] + max_key
    i <- i + 1
  }
  
  df
}

# fonction gérant l'import des données 
# necessite les archives "out" mco
rsaout_to_db <- function(con, p){
  # decompress archive
  p %>% adezip(type = "out")
  # extract and manipulate tables
  new_data <- tbls_from_rsa(p)
  # remove extracted files
  p %>% adelete()
  
  # update the primarys and foreign keys
  for (i in seq(length(new_data))) {
    new_data[[i]] <- update_pk(con, names(new_data)[i], new_data[[i]])
    new_data[[i]] <- update_fk(con, names(new_data)[i], new_data[[i]])
  }
  
  # insert data into the db
  map(names(new_data), function(x) {
    n = str_c(x, "_temp")
    # copy des données dans une table temporaire
    dbWriteTable(con, n, new_data[[x]], overwrite = TRUE)
    
    # copy de la table temp vers la vrai table
    dbSendQuery(con, str_c("INSERT INTO ", x, " SELECT * FROM ", n))
    # suppression de la table temporaire
    dbRemoveTable(con, n)
  })
}