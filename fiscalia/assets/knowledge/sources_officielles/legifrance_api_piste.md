# Légifrance (API PISTE)

## Synthèse
Légifrance constitue la source juridique officielle de référence pour accéder au texte consolidé des lois, ordonnances, décrets et codes français. Pour FiscalIA, cette source couvre en priorité le Code général des impôts (CGI), le Livre des procédures fiscales (LPF) et les textes législatifs associés aux lois de finances.

## Statut officiel
- Autorité éditoriale : Direction de l'information légale et administrative (DILA).
- Niveau de fiabilité : source primaire pour la base légale applicable.
- Usage RAG prioritaire : citation des articles et vérification du texte normatif en vigueur.

## Corpus fiscal couvert
- Code général des impôts (CGI).
- Livre des procédures fiscales (LPF).
- Lois de finances promulguées et articles fiscaux associés.
- Textes consolidés nécessaires pour suivre les versions applicables.

## Accès technique
- Point d'entrée : API Légifrance via PISTE.
- URL officielle : https://piste.gouv.fr/
- Format attendu : flux structurés exploitables pour ingestion automatisée.
- Identifiants utiles : articles, sections, versions consolidées, dates d'entrée en vigueur.

## Recommandations d'ingestion
- Découper par article, section et version consolidée.
- Conserver la hiérarchie code > livre > titre > chapitre > article.
- Stocker la date de vigueur et la référence officielle du texte.
- Prévoir une stratégie de rechargement dès publication d'une nouvelle version consolidée.

## Priorité RAG
- À utiliser quand la réponse doit citer la base légale exacte.
- À privilégier avant toute reformulation doctrinale ou pédagogique.
- À croiser avec BOFiP-Impôts pour l'interprétation administrative.

## Références fiscales associées
- CGI.
- LPF.
- Lois de finances publiées sur Légifrance.
