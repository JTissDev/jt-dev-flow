#!/bin/bash

# ==============================================================================
# Module : Scanner de balises (Avec nettoyage automatique du code source)
# Description : Extrait les tâches Git, les injecte dans le suivi et nettoie les fichiers.
# ==============================================================================

# 1. Vérification que la commande est lancée depuis un dépôt Git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Erreur : Le dossier actuel n'est pas un projet Git."
    exit 1
fi

echo "🔍 Recherche et nettoyage des balises TODO, TOFIX et FIXME..."

# 2. Vérification des fichiers modifiés
NB_FICHIERS=$(git ls-files --modified --others --exclude-standard | wc -l)

if [ "$NB_FICHIERS" -eq 0 ]; then
    echo "✅ Aucun fichier modifié détecté. Rien à analyser."
    exit 0
fi

# 3. Recherche d'un fichier de suivi existant dans le projet
FICHIER_CIBLE=""
if [ -f "TODO.md" ]; then
    FICHIER_CIBLE="TODO.md"
else
    FICHIER_TROUVE=$(find . -maxdepth 2 -name "*.md" -exec grep -l "Project Tracking" {} \; | head -n 1)
    if [ -n "$FICHIER_TROUVE" ]; then
        FICHIER_CIBLE="$FICHIER_TROUVE"
    else
        FICHIER_CIBLE="TODO_LIST.md"
    fi
fi

# 4. Génération du contenu temporaire des tâches scannées
RAPPORT_TEMP=$(mktemp)

echo "" >> "$RAPPORT_TEMP"
echo "## 🔍 Suivi Automatique des Balises (Généré le : $(date '+\%Y-\%m-\%d \%H:\%M:\%S'))" >> "$RAPPORT_TEMP"
echo "" >> "$RAPPORT_TEMP"

COMPTEUR=0

while IFS= read -r -d '' FICHIER; do
    # On évite de s'auto-scanner
    if [ "$FICHIER" == "$FICHIER_CIBLE" ] || [ "./$FICHIER" == "$FICHIER_CIBLE" ]; then
        continue
    fi

    # Extraction des résultats pour le rapport
    RESULTATS=$(awk 'tolower($0) ~ /todo|tofix|fixme/ {print NR ":" $0}' "$FICHIER")

    if [ -n "$RESULTATS" ]; then
        echo "### Fichier : $FICHIER" >> "$RAPPORT_TEMP"
        echo '```text' >> "$RAPPORT_TEMP"
        echo "$RESULTATS" >> "$RAPPORT_TEMP"
        echo '```' >> "$RAPPORT_TEMP"
        echo "" >> "$RAPPORT_TEMP"

        # NETTOYAGE : On réécrit le fichier source en excluant les lignes contenant les balises
        awk 'tolower($0) !~ /todo|tofix|fixme/' "$FICHIER" > "${FICHIER}.tmp" && mv "${FICHIER}.tmp" "$FICHIER"

        ((COMPTEUR++))
    fi
    
done < <(git ls-files -z --modified --others --exclude-standard)

# 5. Injection dans le fichier de suivi ou création
if [ $COMPTEUR -gt 0 ]; then
    if [ -f "$FICHIER_CIBLE" ]; then
        if grep -q "## 🔍 Suivi Automatique des Balises" "$FICHIER_CIBLE"; then
            sed -i '/## 🔍 Suivi Automatique des Balises/,$d' "$FICHIER_CIBLE"
        fi
        cat "$RAPPORT_TEMP" >> "$FICHIER_CIBLE"
        echo "⚠️  $COMPTEUR fichier(s) traité(s). Balises retirées du code source et rapport mis à jour dans '$FICHIER_CIBLE' !"
    else
        echo "# 📝 Project Tracking - Auto-Generated" > "$FICHIER_CIBLE"
        cat "$RAPPORT_TEMP" >> "$FICHIER_CIBLE"
        echo "⚠️  $COMPTEUR fichier(s) traité(s). Balises retirées du code source et nouveau fichier '$FICHIER_CIBLE' créé !"
    fi
else
    echo "✅ Aucune tâche en attente trouvée dans le code modifié."
    if [ -f "$FICHIER_CIBLE" ] && grep -q "## 🔍 Suivi Automatique des Balises" "$FICHIER_CIBLE"; then
        sed -i '/## 🔍 Suivi Automatique des Balises/,$d' "$FICHIER_CIBLE"
        echo "🧹 Ancienne section de suivi automatique nettoyée dans '$FICHIER_CIBLE'."
    fi
fi

# Nettoyage du fichier temporaire
rm -f "$RAPPORT_TEMP"