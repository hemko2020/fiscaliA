# BOFiP-Impôts

## Synthèse
BOFiP-Impôts centralise la doctrine administrative fiscale publiée par la DGFiP. Cette base explicite l'interprétation de la loi fiscale par l'administration et sert de référence opérationnelle pour comprendre l'application concrète des règles.

## Statut officiel
- Autorité éditoriale : Direction générale des finances publiques (DGFiP).
- Niveau de fiabilité : doctrine administrative opposable selon le cadre applicable.
- Usage RAG prioritaire : interprétation administrative, commentaires d'articles, cas d'usage et exceptions.

## Corpus fiscal couvert
- Bulletins officiels en vigueur.
- Commentaires de doctrine par thème fiscal.
- Rescrits, précisions d'application et exemples administratifs.

## Accès technique
- Point d'entrée : dataset officiel Data.gouv.fr.
- URL officielle : https://www.data.gouv.fr/datasets/bofip-impots-publications-en-vigueur
- Format attendu : export structuré ou synchronisation par jeux de données publics.
- Identifiants utiles : numéro BOI, date de publication, date de mise à jour, paragraphe.

## Recommandations d'ingestion
- Découper par document BOI puis par paragraphe doctrinal.
- Conserver les références croisées vers les articles du CGI et du LPF.
- Indexer les dates de publication et de révision pour détecter l'obsolescence.
- Déclencher une veille quasi quotidienne sur les nouveaux bulletins.

## Priorité RAG
- À utiliser pour expliquer comment l'administration applique un texte.
- À présenter après le texte légal primaire si une citation normative est nécessaire.
- À signaler explicitement comme doctrine administrative dans la réponse.

## Références fiscales associées
- Bulletins BOI en vigueur.
- Commentaires administratifs rattachés au CGI et au LPF.
