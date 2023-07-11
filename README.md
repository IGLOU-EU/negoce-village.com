# Migration de negoce-village.com
Afin de ce débarasser de la technologie Microsoft SharePoint et son hebergement extrement onéreux, la Fédération du Negoce Agricole a décidé de migrer son site web vers une technologie plus moderne et ouverte. Dans l'attente de la mise en place du nouveau site webdevant etre mis en ligne d'ici 2024, ce dépôt contient les fichiers du site au format HTML statique.

## TODO
- [ ] Migrer les fichiers du site vers le dépôt
- [ ] Mettre a jour les mentions légales
- [ ] Retrait du formulaire de contact
- [ ] Conserver la redirection pour le lien Centre atlantique
- [ ] Remplacer la recherche par mots clé des actualités par un champ recherche spécifique
- [ ] Remplacement du contenu de la page `annuaire-des-adhérents` par une carte interactive
- [ ] Remplacer Facebook par LinkedIn
- [ ] Supprimer les liens Dailymotion
- [ ] Ajout DPO pour la protection des données personnelles
- [ ] Ajout de la personne en charge de la publication
- [ ] Ajout des mentions légales de la Féderation du Negoce Agricole

## Hébergement
L'hébergement du site dans son format statique est assuré par GitHub Pages.
```
Hébergement

GitHub Pages (https://pages.github.com/)
Par GitHub, Inc.

88 Colin P. Kelly Jr. Street
San Francisco, CA 94107
United States

Siret:  800813156

Phone:      +1 (877) 448-4820 
Email:      privacy@github.com
Website: 	https://github.com/
```

## Publication
```
Publication de la version statique par Iglou.eu
Iglou.eu fait partie de Coopaname

RCS:        448 762 526
APE:        7022Z
Intracom:   FR49 448 762 526
Scop-SA à capital variable

Siège social de Coopaname
3/7 rue Albert Marquet
75020 PARIS
France

Phone:      +33 (0)7 69 81 20 78
Email:      contact@iglou.eu
Website:    https://iglou.eu/
```
## Import
L'import est effectué par le biais d'un script shell.   
Ce script permet de récupérer les fichiers du site actuel et de les convertir en fichiers HTML statique, il corrige aussi les différentes erreur JS et CSS du site d'origine.

Les scripts sont disponibles dans le dossier `tools/`et le site est disponible dans le dossier `pub/` du dépôt.