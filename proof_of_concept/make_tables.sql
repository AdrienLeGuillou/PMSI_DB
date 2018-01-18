CREATE TABLE transmission
(
  id INT NOT NULL,
  finess INT NOT NULL,
  annee INT NOT NULL,
  mois INT NOT NULL,
  PRIMARY KEY (id)
);
  
CREATE TABLE sejour
(
  id INT NOT NULL,
  ghm CHAR(6) NOT NULL,
  mode_entree INT NOT NULL,
  mode_sortie INT NOT NULL,
  date_entree DATE NOT NULL,
  date_sortie DATE NOT NULL,
  code_postal CHAR(5) NOT NULL,
  homme BOOLEAN NOT NULL,
  id_transmission INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (id_transmission) REFERENCES transmission(id)
);

CREATE TABLE rum
(
  id INT NOT NULL,
  numero INT NOT NULL,
  duree INT NOT NULL,
  id_sejour INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (id_sejour) REFERENCES sejour(id)
);

CREATE TABLE acte
(
  id INT NOT NULL,
  ccam VARCHAR(7) NOT NULL,
  id_rum INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (id_rum) REFERENCES rum(id)
);

CREATE TABLE diagnostique
(
  id INT NOT NULL,
  cim10 VARCHAR(6) NOT NULL,
  rang INT NOT NULL,
  id_rum INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (id_rum) REFERENCES rum(id)
);

CREATE VIEW sejour_rum AS
SELECT 
  sejour.id AS id_sejour,
  count(*)  AS nombre_rum
FROM 
  sejour
  JOIN rum ON sejour.id = rum.id_sejour
GROUP BY
  sejour.id;

CREATE VIEW sejour_acte AS
SELECT 
  sejour.id AS id_sejour,
  count(*) AS nombre_acte
FROM 
  sejour
  JOIN rum ON sejour.id = rum.id_sejour
  JOIN acte ON rum.id = acte.id_rum
GROUP BY
  sejour.id;
  
CREATE VIEW sejour_diagnostique AS
SELECT 
  sejour.id AS id_sejour,
  count(*) AS nombre_diagnostique
FROM 
  sejour
  JOIN rum ON sejour.id = rum.id_sejour
  JOIN diagnostique ON rum.id = diagnostique.id_rum
GROUP BY
  sejour.id;
  
CREATE VIEW sejour_plus AS
SELECT 
  sejour.*,
  transmission.finess,
  transmission.annee,
  transmission.mois,
  sejour_rum.nombre_rum,
  sejour_diagnostique.nombre_diagnostique,
  sejour_acte.nombre_acte
FROM 
  sejour
  JOIN transmission ON sejour.id_transmission = transmission.id
  JOIN sejour_rum ON sejour.id = sejour_rum.id_sejour
  JOIN sejour_diagnostique ON sejour.id = sejour_diagnostique.id_sejour
  JOIN sejour_acte ON sejour.id = sejour_acte.id_sejour;