# Guide de mise en production — FiscalIA

Ce guide couvre tout ce qu'il reste à faire pour publier FiscalIA sur
Google Play et l'App Store : CI/CD, secrets, signature, premier tag.

---

## 1. CI/CD — vue d'ensemble

| Workflow | Déclencheur | Rôle |
|---|---|---|
| `ci.yml` | push sur `develop`/`main`, toute PR | format + analyze + 318 tests + build debug Android/iOS |
| `release-android.yml` | push sur `main`, tag `v*`, manuel | APK + AAB **signés**, upload Play Console (internal) sur tag |
| `release-ios.yml` | push sur `main`, tag `v*`, manuel | IPA signé, upload TestFlight sur tag |

Flux recommandé : travail sur `develop` (CI verte) → merge `develop` →
`main` → tag `v1.0.0` sur `main` → déploiement automatique.

---

## 2. Secrets GitHub à configurer

`Settings → Secrets and variables → Actions → New repository secret`

### Android (5 secrets)

```bash
# 1. Générer le keystore de release (UNE SEULE FOIS, à conserver à vie)
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias fiscalia

# 2. L'encoder en base64 pour le secret
base64 -i release.jks | pbcopy
```

| Secret | Contenu |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | sortie base64 du keystore |
| `ANDROID_KEYSTORE_PASSWORD` | mot de passe du keystore |
| `ANDROID_KEY_PASSWORD` | mot de passe de la clé |
| `ANDROID_KEY_ALIAS` | `fiscalia` |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | JSON du compte de service Google Play (Play Console → API access → service account, rôle « Release manager ») |

⚠️ Le keystore ne doit **jamais** être commité (déjà couvert par
`.gitignore`). Le perdre = impossible de mettre à jour l'app.

### iOS (6 secrets)

```bash
# 1. Exporter le certificat de distribution depuis Keychain (.p12)
# 2. Télécharger le profil de provisionnement App Store (developer.apple.com)
base64 -i cert.p12 | pbcopy
base64 -i fiscalia.mobileprovision | pbcopy
base64 -i AuthKey_XXXXXXXX.p8 | pbcopy
```

| Secret | Contenu |
|---|---|
| `IOS_CERTIFICAT_P12_BASE64` | certificat de distribution .p12 en base64 |
| `IOS_CERTIFICAT_PASSWORD` | mot de passe du .p12 |
| `IOS_PROFIL_PROVISIONNEMENT_BASE64` | profil App Store en base64 |
| `APP_STORE_CONNECT_KEY_ID` | identifiant de la clé API (App Store Connect → Users and Access → Keys) |
| `APP_STORE_CONNECT_ISSUER_ID` | issuer ID (même page) |
| `APP_STORE_CONNECT_API_KEY_BASE64` | contenu du .p8 en base64 |

---

## 3. Configuration Firebase production

- [ ] Vérifier `firebase_options.dart` pointe sur le projet **prod**
- [ ] Remote Config : publier `tax_config_json` et
      `advanced_tax_config_json` (valeurs initiales = sortie de
      `TaxConfig.embedded().toJson()` et `AdvancedTaxConfig.embedded().toJson()`)
- [ ] Activer Crashlytics et Analytics dans la console
- [ ] **App Check** : passer `enforceAppCheck` à `true` sur la Cloud
      Function `interrogerAgentFiscal`

## 4. Monétisation production

- [ ] Remplacer les IDs AdMob de test (`ca-app-pub-3940256099942544/…`)
      par les IDs prod dans `android/app/src/main/AndroidManifest.xml`
      et `ios/Runner/Info.plist`
- [ ] Créer les produits RevenueCat (abonnement premium + lifetime) et
      remplacer la clé API de test

## 5. Validation légale

- [ ] Faire relire les 36 résumés de `assets/knowledge/` par un
      fiscaliste (CGI, BOFiP, jurisprudence)
- [ ] Vérifier les barèmes 2026 dans `tax_brackets.dart` et
      `advanced_tax_constants.dart` contre le BOFiP officiel

## 6. Premier release

```bash
# 1. Merger develop dans main
git checkout main && git merge develop && git push

# 2. Bumper la version dans fiscalia/pubspec.yaml (version: 1.0.0+1)

# 3. Tagger -> déclenche le déploiement automatique
git tag v1.0.0 && git push origin v1.0.0
```

Le tag déclenche :
1. `release-android.yml` → AAB signé → Play Console **internal track**
2. `release-ios.yml` → IPA → **TestFlight**

Après validation sur les tracks internes : promotion manuelle vers
production dans les consoles respectives.

## 7. Après la sortie

- Surveiller Crashlytics (objectif : crash-free users > 99,5 %)
- Mettre à jour les barèmes via Remote Config à chaque loi de finances
  (aucune release nécessaire — critère de la story 10.3)
- FR28 : ajouter les vidéos éducatives dans un epic ultérieur
