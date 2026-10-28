#!/bin/bash

# Définition du chemin absolu de l'outil
# Cela permet d'exécuter jtflow depuis n'importe où
JTFLOW_DIR="/c/Users/jtiss/dev-tools/jt-dev-flow"

# On récupère le premier argument passé à la commande (ex: scan, commit)
COMMANDE=$1

# Si aucune commande n'est saisie, on affiche un menu d'aide basique
if [ -z "$COMMANDE" ]; then
    echo "========================================"
    echo "   JT-Flow : Utilitaire de Développement"
    echo "========================================"
    echo "Commandes disponibles :"
    echo "  scan    : Recherche les TODO et TOFIX dans le projet courant"
    echo "  commit  : Lance l'assistant de commit Git"
    echo "  release : Lance le processus de versioning (Release)"
    echo ""
    echo "========================================"
    exit 0
fi

# Routage des commandes vers les bons scripts
case $COMMANDE in
    "scan")
        echo "Lancement du module de scan en cours..."
        bash "$JTFLOW_DIR/modules/suivi/scanner.sh"
        ;;
    "commit")
        echo "Lancement de l'assistant de commit en cours..."
        bash "$JTFLOW_DIR/modules/suivi/commit.sh"
        ;;
        "release")
        echo "Lancement du processus de versioning (Release)..."
        bash "$JTFLOW_DIR/modules/versioning/release.sh"
        ;;
    *)
        # Gestion des commandes inconnues
        echo "Erreur : Commande '$COMMANDE' inconnue."
        echo "Tapez 'jtflow' sans argument pour voir l'aide."
        exit 1
        ;;
esac