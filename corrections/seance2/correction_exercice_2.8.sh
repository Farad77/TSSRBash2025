#!/bin/bash

# Exercice 2.8 : Utilitaires fichiers
# Objectif : Fonctions pour manipulation de fichiers

echo "=== UTILITAIRES FICHIERS ==="
echo

# Fonction backup_file
backup_file() {
    local fichier=$1
    
    # BONUS : Gestion d'erreurs
    if [ -z "$fichier" ]; then
        echo "Erreur : Nom de fichier requis"
        return 1
    fi
    
    if [ ! -f "$fichier" ]; then
        echo "Erreur : Le fichier '$fichier' n'existe pas"
        return 1
    fi
    
    # Créer une copie avec timestamp
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_name="${fichier}.backup_${timestamp}"
    
    if cp "$fichier" "$backup_name"; then
        echo "Sauvegarde créée : $backup_name"
        return 0
    else
        echo "Erreur : Impossible de créer la sauvegarde"
        return 1
    fi
}

# Fonction compte_lignes
compte_lignes() {
    local fichier=$1
    
    # BONUS : Gestion d'erreurs
    if [ -z "$fichier" ]; then
        echo "Erreur : Nom de fichier requis"
        return 1
    fi
    
    if [ ! -f "$fichier" ]; then
        echo "Erreur : Le fichier '$fichier' n'existe pas"
        return 1
    fi
    
    if [ ! -r "$fichier" ]; then
        echo "Erreur : Le fichier '$fichier' n'est pas lisible"
        return 1
    fi
    
    local nb_lignes=$(wc -l < "$fichier")
    echo $nb_lignes
}

# Fonction nettoie_log
nettoie_log() {
    local fichier=$1
    local jours=$2
    
    # BONUS : Gestion d'erreurs
    if [ -z "$fichier" ] || [ -z "$jours" ]; then
        echo "Erreur : Usage: nettoie_log <fichier> <jours>"
        return 1
    fi
    
    if [ ! -f "$fichier" ]; then
        echo "Erreur : Le fichier '$fichier' n'existe pas"
        return 1
    fi
    
    if [[ ! "$jours" =~ ^[0-9]+$ ]]; then
        echo "Erreur : Le nombre de jours doit être un entier positif"
        return 1
    fi
    
    # Créer une sauvegarde avant nettoyage
    backup_file "$fichier" > /dev/null
    
    # Date limite (jours avant aujourd'hui)
    local date_limite=$(date -d "$jours days ago" +"%Y-%m-%d" 2>/dev/null || date -v-${jours}d +"%Y-%m-%d" 2>/dev/null)
    
    if [ -z "$date_limite" ]; then
        echo "Erreur : Impossible de calculer la date limite"
        return 1
    fi
    
    # Compter les lignes avant nettoyage
    local lignes_avant=$(compte_lignes "$fichier")
    
    # Nettoyer les entrées anciennes (simulation simple)
    # Note : Ceci est une simulation, dans la réalité il faudrait parser les dates du log
    grep -v "$(date -d "$((jours+1)) days ago" +"%Y-%m-%d" 2>/dev/null)" "$fichier" > "$fichier.tmp" 2>/dev/null
    
    if [ -f "$fichier.tmp" ]; then
        mv "$fichier.tmp" "$fichier"
        local lignes_apres=$(compte_lignes "$fichier")
        local lignes_supprimees=$((lignes_avant - lignes_apres))
        echo "Nettoyage terminé : $lignes_supprimees lignes supprimées (> $jours jours)"
    else
        echo "Nettoyage simulé pour les entrées > $jours jours"
    fi
}

# Fonction rapport_taille
rapport_taille() {
    local repertoire=$1
    
    # BONUS : Gestion d'erreurs
    if [ -z "$repertoire" ]; then
        echo "Erreur : Répertoire requis"
        return 1
    fi
    
    if [ ! -d "$repertoire" ]; then
        echo "Erreur : Le répertoire '$repertoire' n'existe pas"
        return 1
    fi
    
    local taille_totale=$(du -sb "$repertoire" 2>/dev/null | cut -f1)
    
    if [ -z "$taille_totale" ]; then
        # Fallback pour macOS
        taille_totale=$(du -sk "$repertoire" 2>/dev/null | cut -f1)
        taille_totale=$((taille_totale * 1024))
    fi
    
    echo $taille_totale
}

# Fonction utilitaire pour formater la taille
formater_taille() {
    local taille=$1
    
    if [ $taille -gt 1073741824 ]; then
        echo "$(echo "scale=2; $taille / 1073741824" | bc 2>/dev/null || echo $((taille / 1073741824))) GB"
    elif [ $taille -gt 1048576 ]; then
        echo "$(echo "scale=2; $taille / 1048576" | bc 2>/dev/null || echo $((taille / 1048576))) MB"
    elif [ $taille -gt 1024 ]; then
        echo "$(echo "scale=2; $taille / 1024" | bc 2>/dev/null || echo $((taille / 1024))) KB"
    else
        echo "$taille octets"
    fi
}

# Tests des fonctions
echo "=== TESTS DES FONCTIONS ==="
echo

# Créer un fichier de test
echo "Création d'un fichier de test..."
cat > fichier_test.txt << EOF
Ligne 1 - $(date)
Ligne 2 - Test
Ligne 3 - Données
Ligne 4 - Fin
EOF

echo "✓ Fichier de test créé"
echo

echo "1. Test de backup_file :"
backup_file "fichier_test.txt"
echo

echo "2. Test de compte_lignes :"
nb_lignes=$(compte_lignes "fichier_test.txt")
echo "   Nombre de lignes dans fichier_test.txt : $nb_lignes"
echo

echo "3. Test de nettoie_log :"
nettoie_log "fichier_test.txt" 30
echo

echo "4. Test de rapport_taille :"
taille=$(rapport_taille ".")
taille_formatee=$(formater_taille $taille)
echo "   Taille du répertoire actuel : $taille_formatee"

echo
echo "=== NETTOYAGE ==="
rm -f fichier_test.txt fichier_test.txt.backup_* 2>/dev/null
echo "Fichiers de test supprimés"

echo
echo "=== FIN DES TESTS ==="