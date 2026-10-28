## 🚀 Module 3 : Automation du Versioning & Release (`jtflow release`)

- [x] **Phase 1 : Contrôle Qualité & Tests**
  - [x] Vérification de l'état du dépôt Git (aucun fichier non commit)
  - [x] Exécution automatisée du suite de tests (`mvn clean test` ou équivalent selon projet)
  - [x] Blocage immédiat du processus en cas d'échec des tests

- [x] **Phase 2 : Gestion & Harmonisation des Branches**
  - [x] Vérification de la présence sur la branche `dev`
  - [x] Confirmation du merge des branches de fonctionnalités secondaires

- [x] **Phase 3 : Documentation Automatisée (TODO & Changelog)**
  - [x] Nettoyage et mise à jour automatique des balises dans `TODO.md`
  - [x] Analyse des commits récents et génération / mise à jour du `CHANGELOG.md`

- [x] **Phase 4 : Incrémentation de Version (Bump Version)**
  - [x] Lecture et calcul du nouveau numéro de version (Major, Minor, Patch)
  - [x] Mise à jour du fichier de configuration du projet (`pom.xml`, `package.json`, etc.)
  - [x] Création du commit de release (`chore(release): bump version to X.Y.Z`)

- [x] **Phase 5 : Publication & Fusion vers Master**
  - [x] Basculement sur la branche `master`
  - [x] Fusion (`merge`) automatique de la branche `dev` vers `master`
  - [x] Création du Tag Git de version (`git tag vX.Y.Z`)
  - [x] Rebasculement automatique sur `dev` pour la suite des développements