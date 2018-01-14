# PMSI_DB
Modèle de données pour l'exploitation des fichiers de transmission du PMSI

## Objectif

Création d'une structure de base de données relationnelle permettant l'exploitation des fichiers de transmission hospitaliers de manière reproductible et standardisée.

## Spécifications

### Normalisation

Le modèle doit respecter [la 5em forme normale](https://en.wikipedia.org/wiki/Fifth_normal_form) afin d'assurer la pérénité des données ainsi que la possibilité d'ajouter des informations venant de spécifications plus récentes.

### Conventions

Les noms des tables et colonnes doivent être autant que possible les plus explicites, en utilisant le minimum d'abbreviations. Réutiliser au maximum les préfix et suffix déjà présents pour augmenter la cohérence globale.
Utiliser la convention "miniscule_et_underscore" en cas de noms composés.

### Documentation

La documentation des tables et de leurs relations est primordiale.

## Implémentation

L'implémentation n'est pas l'objectif principal de ce projet. Le but est ici de formaliser la structure que doit prendre l'information et non imposer un RDBMS en particulier.
Néanmoins, par soucis de simplicité, une implémentation pour MonetDB sera présente avec l'utilisation du SQL:2003 comme référence. Le package [pmeasyr](https://github.com/IM-APHP/pmeasyr) du langage R sera le système initial de création de la base de données pour les tests.

Une fois de plus, l'implementation n'est pas l'objectif de ce projet. Une fois le modèle spécifié, chacun est libre de l'implémenter sur le RDBMS de son choix avec son langage préféré.

## Feuille de route

- [ ] création d'un schema simple avec quelques éléments pour illustrer le projet
- [ ] production des fonctions permettant de génerer la base de données correspondante
- [ ] ajout de toutes les informations disponnibles
- [ ] [draw the rest of the owl](https://roaddogmedia.files.wordpress.com/2013/07/how-to-draw-an-owl-clean.jpg)
