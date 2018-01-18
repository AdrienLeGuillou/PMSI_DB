library(MonetDBLite)
library(DBI)
source("makers.R")

# creation de l'objet de connection a la DB
dbdir <- "monetdb/"
con <- dbConnect(MonetDBLite::MonetDBLite(), dbdir)

# creation de la structure de la DB
create_db(con)

# importation des données :
# on renseigne les années et les finess d'interet
ans <- 2011:2016
finess <- c(100000017,
            100000041,
            100000058,
            100006279) # sous forme de nombre
# chemin ou son situées les archives
path = "data/full/"

# boucle d'importation
for (a in ans){
  for (f in finess){
    # mise a jour du noyau pmeasyr
    p <- noyau_pmeasyr(finess = f,
                       annee = a,
                       mois = 12,
                       path = path,
                       progress = F)
    # fonction d'import (cf makers.R)
    rsaout_to_db(con, p)
  }
}

# test:
names <- dbListTables(con)
# on lance la fonction summary sur chaque table de la base
map(names, function(x) summary(as_tibble(tbl(con, x))))

# ici on test la "view" "sejour_plus"
sej_plus <- tbl(con, "sejour_plus")
# on regarde par etablissement et par an :
#  - le nombre de sejours
#  - la moyenne des rums, diagnostiques et actes par sejour
sum_transm <- sej_plus %>% 
  group_by(finess, annee) %>% 
  summarise(nombre_sejour = n(),
            moyenne_rum = mean(nombre_rum),
            moyenne_diagnostique = mean(nombre_diagnostique),
            moyenne_acte = mean(nombre_acte))

# affichage du resultat dans le viewer de rstudio
sum_transm %>% as_tibble() %>% View()

# disconnect db
dbDisconnect(con)
# shut the engine down
MonetDBLite::monetdblite_shutdown()

################################################################################
# SI BESOIN

# delete the database
# unlink(str_c(dbdir, "/*"), recursive = T)

