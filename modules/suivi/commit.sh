#!/bin/bash

# ==============================================================================
# Module : Assistant de Commit Interactif
# Description : Vérifie la branche, lance le scan, puis guide le commit Git.
# ==============================================================================

# 1. Vérification de la présence d'un dépôt Git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "❌ Erreur : Le dossier actuel n'est pas un projet Git."
    exit 1
fi

# 2. Sécurité : Interdiction stricte de commiter sur master ou main (insensible à la casse)
BRANCH_ACTUELLE=$(git branch --show-current)
BRANCH_LOWER=$(echo "$BRANCH_ACTUELLE" | tr '[:upper:]' '[:lower:]')

if [ "$BRANCH_LOWER" == "master" ] || [ "$BRANCH_LOWER" == "main" ]; then
    echo "=================================================="
    echo "🛑 ERREUR DE SÉCURITÉ : BRANCHE INTERDITE !"
    echo "=================================================="
    echo "Tu es actuellement sur la branche : '$BRANCH_ACTUELLE'."
    echo "Il est interdit de commiter directement sur master/main."
    echo "Veuillez basculer sur une branche de développement (ex: dev) :"
    echo "  👉 git checkout dev"
    echo "=================================================="
    exit 1
fi

echo "🛡️  Vérification de la branche '$BRANCH_ACTUELLE' : OK."

# 3. Lancement automatique du scanner de balises
JTFLOW_DIR="/c/Users/jtiss/dev-tools/jt-dev-flow"
echo ""
echo "🚀 Lancement préalable du scanner de balises..."
bash "$JTFLOW_DIR/modules/suivi/scanner.sh"
echo ""

# 4. Assistant interactif pour structurer le message de commit
echo "----------------------------------------"
echo "      ASSISTANT DE COMMIT GIT"
echo "----------------------------------------"
echo "Choisis le type de modification :"
echo "  a) feat     (Nouvelle fonctionnalité)"
echo "  f) fix      (Correction de bug)"
echo "  r) refactor (Refactoring / Nettoyage du code)"
echo "  c) chore    (Tâches diverses, config, mise à jour doc)"
read -p "Ton choix (a-f-r-c) [Défaut: c - chore] : " CHOIX_TYPE

case $CHOIX_TYPE in
    a) TYPE="feat" ;;
    f) TYPE="fix" ;;
    r) TYPE="refactor" ;;
    *) TYPE="chore" ;;
esac

read -p "Entre le message court de ton commit : " MESSAGE
if [ -z "$MESSAGE" ]; then
    MESSAGE="mise à jour générale"
fi

# Construction du message final standardisé
FULL_MESSAGE="$TYPE: $MESSAGE"

# 5. Exécution des commandes Git
echo ""
echo "📦 Préparation des fichiers (git add)..."
git add .

echo "💾 Création du commit..."
git commit -m "$FULL_MESSAGE"

if [ $? -eq 0 ]; then
    echo "========================================"
    echo "✅ Commit réussi avec succès !"
    echo "Message : $FULL_MESSAGE"
    echo "========================================"
else
    echo "❌ Erreur lors de la création du commit."
    exit 1
fi