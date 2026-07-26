# Lois de Finances

## Synthèse
Les lois de finances constituent le vecteur législatif principal des modifications fiscales annuelles. Elles déterminent les nouvelles mesures, ajustent les barèmes et introduisent les règles applicables aux campagnes déclaratives futures.

## Statut officiel
- Autorité éditoriale : Parlement français, promulgation et publication sur Légifrance.
- Niveau de fiabilité : source primaire de mise à jour législative.
- Usage RAG prioritaire : suivi des nouveautés, date d'entrée en vigueur et arbitrage entre millésimes.

## Corpus fiscal couvert
- Loi de finances initiale.
- Loi de finances rectificative si applicable.
- Articles fiscaux modifiant le CGI, le LPF ou les régimes spéciaux.

## Accès technique
- Point d'entrée : flux RSS et API Légifrance.
- URL officielle : https://www.legifrance.gouv.fr/
- Format attendu : textes promulgués, articles, dates de publication.
- Identifiants utiles : numéro de loi, article modificateur, millésime, date de vigueur.

## Recommandations d'ingestion
- Découper par article fiscal ou bloc thématique.
- Relier chaque modification aux articles du CGI ou du LPF impactés.
- Marquer explicitement le millésime fiscal et la date d'entrée en vigueur.
- Renforcer la synchronisation annuelle en décembre et janvier.

## Priorité RAG
- À utiliser pour répondre aux questions sur les évolutions récentes.
- À croiser avec Légifrance consolidé pour confirmer le texte à jour.
- À croiser avec BOFiP pour vérifier la doctrine d'application après publication.

## Références fiscales associées
- Lois de finances annuelles.
- Lois de finances rectificatives publiées sur Légifrance.
