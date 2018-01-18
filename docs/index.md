# PMSI_DB
## Introduction
Ce site va servir de blog pour le [projet PMSI_DB](https://github.com/AdrienLeGuillou/PMSI_DB). Je m'en servirait pour présenter mes avancées, les modifications de ma roadmap et toutes les informations qui je trouverai pertinente.

## Présentation du projet
L'objectif de ce projet est la création d'un schema de base de donnée pour stocker les information du PMSI. 
L'excellent package [pmeasyr](https://github.com/IM-APHP/pmeasyr) m'a déjà permis via [R](https://www.r-project.org/) d'exploiter ces informations à des visées épidémiologiques mais la variabilité des formats imposé par [l'ATIH](http://www.atih.sante.fr/) rend la reproductibilité de ces travaux complexe. Enfin, ne disposant pas encore de plusieurs centaines de GB de RAM sur mes machines il m'est impossible d'analyser de très grands volumes de données.

### Approche entrepot de donnée
Pour répondre à ces contraintes je souhaite m'inspirer des entrepot de donner. Dans ce cas il s'agit de créer un format de base relationnel le plus généraliste possilbe afin de pouvoir l'exploiter sans nécessiter de le changer pour n'importe quel type d'analyse.

Au niveau du design de la base cela implique une conception très normalisée (jusqu'au [5NF](https://en.wikipedia.org/wiki/Fifth_normal_form) au minimum). 

### L'implementation
Bien qu'elle risque de prendre énormement de temps, l'implementation est assez secondaire pour ce projet. L'objectif est principalement le modèle de données et non les spécificité d'un RDBMS. Malgré cela je vais fournir au fur et à mesure du projet un implementation type afin d'avoir de quoi travailler. Pour cette dernière j'ai choisit [monetDB](https://www.monetdb.org/Home) et plus spécifiquement son implémentation dans R avec [monetDBLite](https://www.monetdb.org/blog/monetdblite-r). Ce choix est motivé par les conseils de [Guillaume Pressiat](https://github.com/GuillaumePressiat) qui m'a de plus dirigé vers [cette présentation](https://datactivist.coop/monet/#1). 

### Contraintes à respecter
Le but de ce projet est de s'adresser autant au médecin DIM qui veulent évaluer leur hopital ou leur groupement hospitalier de territoire qu'à quiconque ayant obtennu l'autorisation exploiter ces données à des fins de recherche. Ainsi tous les fichiers des archives de transmisssions ne seront pas systematiquement présent. Il est nécessaire que la structure de la base soit capable de gérer indifféremment les fichiers fournis. Cela implique un data management adapté et une documentation importante afin que l'utilisateur sache où l'information est brut et où elle à été manipuler. 
Exemple : la date de début d'un séjour hospitalier est connu au jour près si l'on dispose des fichiers .tra et .rsa des archives .out du MCO mais ne le sont qu'au mois près (en calculant avec la durée et le mois de sortie) si on ne dispose que du fichier .rsa. Dans ce cas la base de donnée contiendra systématiquement une date (pour gérer les deux cas de figures) mais celle ci sera une approximation (par exemple le premier jours du mois) si on ne dispose pas de l'information complète.

## Premier jet
Un dossier "proof of concept" a été ajouté sur [le dépot github du projet](https://github.com/AdrienLeGuillou/PMSI_DB). Je publierai sous peu [un article présentant ce qu'il contient et comment le tester](https://adrienleguillou.github.io/PMSI_DB/proof_of_concept).
