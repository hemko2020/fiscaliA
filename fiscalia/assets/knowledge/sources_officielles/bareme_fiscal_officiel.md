# Bareme fiscal officiel

## Synthese
Le bareme fiscal officiel sert de socle de calcul pour l'impot sur le revenu et certains controles de coherence. Dans FiscalIA, il doit rester synchronise avec la norme officielle et alimenter a la fois le moteur de calcul et le corpus de reference.

## Statut officiel
Source officielle derivee de la loi de finances, de la documentation DGFiP et des publications de campagne fiscale. Elle ne releve pas d'un corpus narratif principal, mais d'un referentiel reglementaire structure.

## Corpus fiscal couvert
- tranches du bareme de l'impot sur le revenu
- plafonds et seuils lies aux calculs recurrentes
- valeurs necessaires au moteur de simulation

## Acces technique
Recuperation depuis les publications officielles de la DGFiP et les textes legislatifs applicables. Diffusion applicative possible via Firebase Remote Config en plus du stockage documentaire.

## Recommandations d'ingestion
- stocker en format structure JSON
- versionner par exercice fiscal
- distinguer clairement les valeurs de calcul du corpus explicatif

## Priorite RAG
Priorite moyenne pour le RAG conversationnel, mais priorite critique pour le moteur de calcul.

## References fiscales associees
- bareme IR
- seuils
- plafonds
- simulation fiscale
