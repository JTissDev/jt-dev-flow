#!/bin/bash

# ==============================================================================
# Module : Release & Versioning (Phase 1)
# Description : Vérifie l'état Git et lance les tests avant une nouvelle version.
# ==============================================================================

# 1. Vérification de la présence d'un dépôt Git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "❌ Erreur : Le dossier actuel n'est pas un projet Git."
    exit 1
fi

echo "🔍 Phase 1 : Contrôle de l'intégrité et tests..."

# 2. Vérification de l'état Git (aucun fichier non commit)
# La commande --porcelain retourne une chaîne vide si tout est propre
ETAT_GIT=$(git status --porcelain)

if [ -n "$ETAT_GIT" ]; then
    echo "=================================================="
    echo "🛑 ERREUR : Ton répertoire de travail n'est pas propre."
    echo "=================================================="
    echo "Il reste des fichiers modifiés ou non suivis."
    echo "Utilise d'abord 'jtflow commit' pour valider tes changements."
    exit 1
fi

echo "✅ Dépôt Git propre. Aucun fichier en attente."
echo ""

# 3. Lancement des tests selon le type de projet
echo "🚀 Analyse du projet pour le lancement des tests automatiques..."

if [ -f "pom.xml" ]; then
    echo "☕ Projet Java/Maven détecté. Exécution de 'mvn clean test'..."
    
    # Exécution de Maven (Sous Windows/Git Bash, si 'mvn' ne passe pas, on peut utiliser 'mvn.cmd')
    mvn clean test
    
    # Vérification du code de retour de la dernière commande ($?)
    if [ $? -ne 0 ]; then
        echo "=================================================="
        echo "🛑 ERREUR CRITIQUE : Les tests Maven ont échoué !"
        echo "=================================================="
        echo "La procédure de release est interrompue pour protéger le code."
        exit 1
    fi
    echo "✅ Tests Maven passés avec succès !"

elif [ -f "package.json" ]; then
    echo "⚛️ Projet Node/React détecté. Exécution de 'npm test'..."
    
    npm test
    
    if [ $? -ne 0 ]; then
        echo "=================================================="
        echo "🛑 ERREUR CRITIQUE : Les tests Node ont échoué !"
        echo "=================================================="
        echo "La procédure de release est interrompue."
        exit 1
    fi
    echo "✅ Tests Node passés avec succès !"

else
    echo "⚠️ Aucun fichier pom.xml ou package.json trouvé."
    echo "➡️ L'étape des tests automatiques est ignorée pour ce projet."
fi

echo ""
echo "🎉 Phase 1 validée : Le code est sain et prêt pour la suite !"

# ==============================================================================
# Phase 2 : Gestion et harmonisation des branches
# ==============================================================================
echo ""
echo "🔍 Phase 2 : Vérification de l'environnement Git..."

# 1. Vérification de la branche courante (doit être 'dev')
BRANCH_ACTUELLE=$(git branch --show-current)
BRANCH_LOWER=$(echo "$BRANCH_ACTUELLE" | tr '[:upper:]' '[:lower:]')

if [ "$BRANCH_LOWER" != "dev" ]; then
    echo "=================================================="
    echo "🛑 ERREUR : La release doit être initiée depuis la branche 'dev'."
    echo "=================================================="
    echo "Tu es actuellement sur la branche : '$BRANCH_ACTUELLE'."
    echo "Bascule sur 'dev' (git checkout dev) et fusionne tes travaux avant de relancer."
    exit 1
fi

echo "✅ Branche courante validée : 'dev'."

# 2. Confirmation manuelle des fusions
echo "⚠️ As-tu bien fusionné toutes tes branches de fonctionnalités dans 'dev' ?"
read -p "Confirmer la préparation de la release ? (o/n) : " CONFIRM_MERGE

if [[ "$CONFIRM_MERGE" != "o" && "$CONFIRM_MERGE" != "O" ]]; then
    echo "🛑 Procédure de release interrompue par l'utilisateur."
    echo "Prends le temps de finaliser tes fusions (merge) avant de relancer."
    exit 0
fi

echo "✅ Branches harmonisées."
echo "🎉 Phase 2 validée : L'environnement est prêt pour la documentation !"

# ==============================================================================
# Phase 3 : Documentation Automatisée (TODO & Changelog)
# ==============================================================================
echo ""
echo "🔍 Phase 3 : Mise à jour de la documentation..."

# 1. Mise à jour du TODO via le scanner
JTFLOW_DIR="/c/Users/jtiss/dev-tools/jt-dev-flow"
echo "📋 Actualisation de la liste des tâches (Scanner)..."
bash "$JTFLOW_DIR/modules/suivi/scanner.sh"

# 2. Vérification / Création du CHANGELOG.md
CHANGELOG_FILE="CHANGELOG.md"

if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "📝 Fichier CHANGELOG.md absent. Création du fichier de base..."
    echo "# Changelog" > "$CHANGELOG_FILE"
    echo "" >> "$CHANGELOG_FILE"
    echo "Toutes les modifications notables apportées à ce projet sont consignées dans ce fichier." >> "$CHANGELOG_FILE"
    echo "" >> "$CHANGELOG_FILE"
fi

# 3. Extraction de l'historique des commits
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

echo "📜 Extraction des commits pour le Changelog..."

if [ -z "$LAST_TAG" ]; then
    echo "ℹ️ Aucun tag précédent. Analyse de tout l'historique..."
    RECENT_COMMITS=$(git log --pretty=format:"* %s (%h)")
else
    echo "ℹ️ Dernier tag détecté : $LAST_TAG. Analyse depuis ce tag..."
    RECENT_COMMITS=$(git log ${LAST_TAG}..HEAD --pretty=format:"* %s (%h)")
fi

echo ""
echo "--------------------------------------------------"
echo "📋 Commits à inclure dans cette release :"
echo "--------------------------------------------------"
echo "$RECENT_COMMITS"
echo "--------------------------------------------------"
echo ""

echo "🎉 Phase 3 validée : La documentation est synchronisée !"


# ==============================================================================
# Phase 4 : Incrémentation de Version (Bump Version)
# ==============================================================================
echo ""
echo "🔍 Phase 4 : Incrémentation du numéro de version..."

CURRENT_VERSION=""

# 1. Détection de la version actuelle dans le projet
if [ -f "pom.xml" ]; then
    CURRENT_VERSION=$(grep -m 1 "<version>" pom.xml | sed -E 's/.*<version>(.*)<\/version>.*/\1/')
elif [ -f "package.json" ]; then
    CURRENT_VERSION=$(grep -m 1 '"version"' package.json | sed -E 's/.*"version": "(.*)".*/\1/')
fi

if [ -n "$CURRENT_VERSION" ]; then
    echo "📌 Version actuelle détectée : $CURRENT_VERSION"
else
    echo "⚠️ Version actuelle non détectée."
    CURRENT_VERSION="1.0.0-SNAPSHOT"
fi

# 2. Saisie du nouveau numéro de version
read -p "Entrez le nouveau numéro de version (ex: 1.0.0) : " NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
    echo "🛑 Numéro de version invalide. Procédure interrompue."
    exit 1
fi

# 3. Mise à jour du fichier de configuration du projet
if [ -f "pom.xml" ]; then
    echo "☕ Mise à jour de la version dans pom.xml..."
    mvn versions:set -DnewVersion="$NEW_VERSION" -DgenerateBackupPoms=false > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        sed -i "0,/<version>$CURRENT_VERSION<\/version>/s//<version>$NEW_VERSION<\/version>/" pom.xml
    fi
elif [ -f "package.json" ]; then
    echo "⚛️ Mise à jour de la version dans package.json..."
    sed -i "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" package.json
fi

echo "✅ Fichier du projet mis à jour vers la version $NEW_VERSION."

# 4. Écriture du contenu dans le CHANGELOG.md
DATE_JOUR=$(date +%Y-%m-%d)
HEADER_VERSION="## [$NEW_VERSION] - $DATE_JOUR"

# Insertion de la nouvelle section sous l'en-tête du Changelog
awk -v version="$HEADER_VERSION" -v commits="$RECENT_COMMITS" '
    /^# Changelog/ {
        print $0 "\n\n" version "\n" commits;
        next
    }
    { print $0 }
' CHANGELOG.md > CHANGELOG.tmp && mv CHANGELOG.tmp CHANGELOG.md

echo "📝 CHANGELOG.md mis à jour avec les notes de la version $NEW_VERSION."

# 5. Création du commit de bump de version
echo "📦 Validation Git des modifications..."
git add .
git commit -m "chore(release): bump version to $NEW_VERSION"

echo ""
echo "🎉 Phase 4 validée : Commit de version $NEW_VERSION créé avec succès !"

# ==============================================================================
# Phase 5 : Publication et Fusion vers Master
# ==============================================================================
echo ""
echo "🔍 Phase 5 : Clôture de la release et fusion vers master..."

# 1. Basculement sur la branche master
echo "🔀 Basculement sur la branche 'master'..."
git checkout master

if [ $? -ne 0 ]; then
    echo "🛑 ERREUR : Impossible de basculer sur la branche 'master'."
    exit 1
fi

# 2. Fusion de dev dans master (option --no-ff forcée)
echo "🤝 Fusion de 'dev' dans 'master'..."
git merge dev --no-ff -m "chore(release): merge dev for release v$NEW_VERSION"

if [ $? -ne 0 ]; then
    echo "🛑 ERREUR : Conflit lors du merge de 'dev' vers 'master'."
    exit 1
fi

# 3. Création du Tag Git de version
TAG_NAME="v$NEW_VERSION"
echo "🏷️ Création du tag Git '$TAG_NAME'..."
git tag -a "$TAG_NAME" -m "Release version $NEW_VERSION"

# 4. Retour sur dev et préparation de la version suivante
echo "🔄 Retour sur la branche 'dev'..."
git checkout dev

# Proposer ou définir la version SNAPSHOT / DEV suivante (ex: 1.3.0-SNAPSHOT)
NEXT_DEV_VERSION="${NEW_VERSION}-SNAPSHOT"
echo "☕ Passage de la branche 'dev' en version de développement ($NEXT_DEV_VERSION)..."
mvn versions:set -DnewVersion="$NEXT_DEV_VERSION" -DgenerateBackupPoms=false > /dev/null 2>&1
git add pom.xml
git commit -m "chore: prepare for next development iteration ($NEXT_DEV_VERSION)"

echo ""
echo "=================================================="
echo "🚀 RELEASE $NEW_VERSION TERMINÉE AVEC SUCCÈS !"
echo "=================================================="
echo "  • Tests unitaires validés"
echo "  • TODO & CHANGELOG.md mis à jour"
echo "  • Version du projet incrémentée à $NEW_VERSION"
echo "  • Branche 'master' mise à jour avec le tag $TAG_NAME"
echo "  • Environnement repositionné sur 'dev'"
echo "=================================================="