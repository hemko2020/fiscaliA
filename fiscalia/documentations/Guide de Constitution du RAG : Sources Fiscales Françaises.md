# Guide de Constitution du RAG : Sources Fiscales Françaises

Pour que FiscalIA soit une référence fiable, son système de **RAG (Retrieval-Augmented Generation)** doit être alimenté par des sources "Gold Standard". Voici l'inventaire complet des sources à indexer.

## 1. Sources Législatives et Réglementaires (Le Socle)

Ces sources contiennent le texte brut de la loi. Elles sont indispensables pour citer les articles officiels.

| Source | Contenu | Accès Technique |
| :--- | :--- | :--- |
| **Légifrance (API PISTE)** | Code Général des Impôts (CGI), Livre des Procédures Fiscales (LPF). | [API Légifrance via PISTE](https://piste.gouv.fr/) |
| **BOFiP-Impôts** | Bulletin Officiel des Finances Publiques. Commentaires officiels de la loi par l'administration. | [Dataset Data.gouv.fr](https://www.data.gouv.fr/datasets/bofip-impots-publications-en-vigueur) |
| **Lois de Finances** | Mises à jour annuelles (ex: Loi de finances 2026). | Flux RSS / API Légifrance |

## 2. Algorithmes et Logique de Calcul (L'Intelligence)

Le RAG ne suffit pas pour le calcul ; il faut coupler l'IA avec les algorithmes officiels pour garantir l'exactitude des chiffres.

- **OpenFisca-France :** Le moteur de micro-simulation le plus complet. Il transforme le code des impôts en code Python.
  - *Lien :* [OpenFisca GitHub](https://github.com/openfisca/openfisca-france)
- **Code Source du Calculateur National :** La Direction Générale des Finances Publiques (DGFiP) a ouvert le code source de son calculateur d'impôt sur le revenu.
  - *Lien :* [Calculette-impots.gouv.fr Source](https://github.com/dgfip/calculette-impots-m-source-code)

## 3. Guides Pratiques et Vulgarisation (Le Contexte)

Ces sources aident l'IA à comprendre comment expliquer des concepts complexes aux utilisateurs.

- **Service-Public.fr (Rubrique Fiscalité) :** Fiches pratiques sur l'impôt sur le revenu, l'IFI, les réductions d'impôts.
  - *Accès :* API Service-Public ou Scraping structuré.
- **Brochure Pratique de l'Impôt sur le Revenu :** Publiée chaque année par la DGFiP (format PDF de ~400 pages), c'est la "bible" de la déclaration.

## 4. Architecture Technique du RAG

Pour une performance optimale, nous recommandons la structure suivante :

1. **Ingestion (ETL) :** Scripts Python pour récupérer les mises à jour hebdomadaires du BOFiP et du CGI.
2. **Chunking (Découpage) :** Découper les textes par article de loi ou par paragraphe de doctrine (BOFiP) pour garder le contexte.
3. **Embedding :** Utilisation d'un modèle d'embedding performant en français (ex: `text-embedding-3-large` ou modèles spécialisés juridiques).
4. **Vector Database :** Stockage dans une base comme Pinecone ou Weaviate pour une recherche sémantique ultra-rapide.

## 5. Stratégie de Mise à Jour (Update Loop)

La loi fiscale change constamment. Votre RAG doit intégrer :
- Un **veilleur automatique** sur les nouveaux bulletins du BOFiP (publiés presque quotidiennement).
- Une **re-validation annuelle** lors du vote de la Loi de Finances (décembre/janvier).

> **Conseil d'Expert :** Ne demandez jamais à l'IA de calculer l'impôt directement à partir du texte. Utilisez le RAG pour **identifier les règles applicables** et passez ces paramètres au moteur **OpenFisca** pour obtenir le résultat chiffré exact.
