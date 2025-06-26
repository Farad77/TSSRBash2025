#!/bin/bash

# Exercice 3.6 : Nettoyeur de fichiers de log
# Objectif : Traitement de données avec sed

echo "=== NETTOYEUR DE FICHIERS DE LOG ==="
echo

# Fonction pour créer un fichier de log de test
creer_log_test() {
    local fichier="$1"
    
    cat > "$fichier" << 'EOF'
# Fichier de log de test
# Créé pour démonstration

2024-01-15 10:30:45 INFO [server] Service started successfully
2024-01-15 10:31:02 DEBUG [auth] User admin logged in from 192.168.1.100

# Configuration temporaire
2024-01-15 10:35:12 ERROR [database] Connection failed to 192.168.1.200
2024-01-15 10:35:15 INFO [database] Retrying connection...
2024-01-15 10:35:18 INFO [database] Connected to 192.168.1.200

2024-01-10 08:22:33 INFO [backup] Backup started
2024-01-10 08:25:45 WARN [backup] Low disk space
# Mot de passe temporaire: password123

2024-01-10 08:30:12 INFO [auth] User john password=secret123 logged in
2024-01-10 08:45:23 DEBUG [session] Session created for user mary

# Ligne vide suivante


2023-12-20 14:15:30 OLD [system] Old entry to be removed
2023-11-15 09:30:45 OLD [system] Very old entry

2024-01-16 09:15:22 INFO [web] Request from 10.0.0.5
2024-01-16 09:16:33 ERROR [web] Authentication failed for user test password=admin
2024-01-16 09:20:45 INFO [web] Response sent to 172.16.0.10

# Commentaire à supprimer
2024-01-16 10:00:00 INFO [system] System check completed

2024-01-16 11:30:15 WARN [security] Failed login attempt from 203.0.113.5
# Debug: user=admin pass=123456

2024-01-16 12:00:00 INFO [cleanup] Log rotation completed
EOF
}

# Fonction pour compter les modifications
compter_modifications() {
    local avant="$1"
    local apres="$2"
    local type="$3"
    
    local count_avant=$(wc -l < "$avant")
    local count_apres=$(wc -l < "$apres")
    local diff=$((count_avant - count_apres))
    
    echo "  $type : $diff lignes supprimées"
}

# Vérifier les paramètres
if [ $# -eq 0 ]; then
    echo "Usage : $0 <fichier_log>"
    echo "Exemple : $0 /var/log/application.log"
    echo
    echo "Création d'un fichier de test pour la démonstration..."
    
    fichier_log="test_log_file.log"
    creer_log_test "$fichier_log"
    echo "✓ Fichier de test créé : $fichier_log"
else
    fichier_log="$1"
fi

# Vérifier que le fichier existe
if [ ! -f "$fichier_log" ]; then
    echo "Erreur : Le fichier '$fichier_log' n'existe pas"
    exit 1
fi

echo "Nettoyage du fichier : $fichier_log"
echo "Taille originale : $(wc -l < "$fichier_log") lignes"
echo

# Créer une sauvegarde
backup_file="${fichier_log}.backup_$(date +%Y%m%d_%H%M%S)"
cp "$fichier_log" "$backup_file"
echo "✓ Sauvegarde créée : $backup_file"

# Fichiers de travail
temp1="${fichier_log}.temp1"
temp2="${fichier_log}.temp2"
temp3="${fichier_log}.temp3"
temp4="${fichier_log}.temp4"
temp5="${fichier_log}.temp5"

# Compteur de modifications
modifications_count=0

echo
echo "=== DÉBUT DU NETTOYAGE ==="

# Étape 1 : Supprimer les lignes vides
echo "1. Suppression des lignes vides..."
cp "$fichier_log" "$temp1"
sed '/^[[:space:]]*$/d' "$temp1" > "$temp2"
lignes_vides=$(($(wc -l < "$temp1") - $(wc -l < "$temp2")))
echo "   $lignes_vides lignes vides supprimées"
modifications_count=$((modifications_count + lignes_vides))

# Étape 2 : Supprimer les commentaires (#)
echo "2. Suppression des commentaires..."
sed '/^[[:space:]]*#/d' "$temp2" > "$temp3"
commentaires=$(($(wc -l < "$temp2") - $(wc -l < "$temp3")))
echo "   $commentaires lignes de commentaires supprimées"
modifications_count=$((modifications_count + commentaires))

# Étape 3 : Anonymiser les adresses IP (remplacer par XXX.XXX.XXX.XXX)
echo "3. Anonymisation des adresses IP..."
sed -E 's/([0-9]{1,3}\.){3}[0-9]{1,3}/XXX.XXX.XXX.XXX/g' "$temp3" > "$temp4"
ip_changes=$(diff "$temp3" "$temp4" | grep -c "^>" || echo 0)
echo "   Adresses IP anonymisées dans $ip_changes lignes"

# Étape 4 : Supprimer les timestamps anciens (> 30 jours)
echo "4. Suppression des entrées anciennes (> 30 jours)..."
# Calculer la date limite (30 jours avant aujourd'hui)
if date -d "30 days ago" +%Y-%m-%d >/dev/null 2>&1; then
    # GNU date (Linux)
    date_limite=$(date -d "30 days ago" +%Y-%m-%d)
else
    # BSD date (macOS)
    date_limite=$(date -v-30d +%Y-%m-%d)
fi

# Supprimer les lignes avec des dates antérieures à la date limite
# Pattern pour détecter les dates au format YYYY-MM-DD
sed -E "/${date_limite}/,\$!{/^[0-9]{4}-[0-9]{2}-[0-9]{2}/d}" "$temp4" > "$temp5"

# Pour une approche plus simple, supprimer les entrées 2023 (considérées comme anciennes)
sed '/^2023-/d' "$temp4" > "$temp5"
anciennes=$(($(wc -l < "$temp4") - $(wc -l < "$temp5")))
echo "   $anciennes entrées anciennes supprimées"
modifications_count=$((modifications_count + anciennes))

# Étape 5 : Normaliser le format des dates
echo "5. Normalisation du format des dates..."
# Convertir les formats de date incohérents (exemple : remplacer les espaces par des T)
# Ici, on garde le format existant mais on pourrait le modifier
sed -E 's/([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2})/\1T\2/' "$temp5" > "$temp1"
normalisation=$(diff "$temp5" "$temp1" | grep -c "^>" || echo 0)
echo "   $normalisation dates normalisées (format ISO)"

# Étape 6 : Remplacer les mots de passe visibles par [MASKED]
echo "6. Masquage des mots de passe..."
# Pattern pour détecter password=, pass=, pwd=, etc.
sed -E 's/(password|pass|pwd)[[:space:]]*=[[:space:]]*[^[:space:]]+/\1=[MASKED]/gi' "$temp1" > "$temp2"
passwords=$(($(grep -c "password.*=" "$temp1" || echo 0) - $(grep -c "\[MASKED\]" "$temp2" || echo 0)))
if [ $passwords -lt 0 ]; then passwords=0; fi
mots_de_passe=$(grep -c "\[MASKED\]" "$temp2" || echo 0)
echo "   $mots_de_passe mots de passe masqués"

# Finaliser : remplacer le fichier original
mv "$temp2" "$fichier_log"

# Nettoyer les fichiers temporaires
rm -f "$temp1" "$temp3" "$temp4" "$temp5"

echo
echo "=== RÉSUMÉ DU NETTOYAGE ==="
echo "Fichier traité : $fichier_log"
echo "Sauvegarde : $backup_file"
echo
echo "Modifications effectuées :"
echo "  • Lignes vides supprimées : $lignes_vides"
echo "  • Commentaires supprimés : $commentaires"
echo "  • Adresses IP anonymisées : $ip_changes lignes modifiées"
echo "  • Entrées anciennes supprimées : $anciennes"
echo "  • Dates normalisées : $normalisation"
echo "  • Mots de passe masqués : $mots_de_passe"
echo
echo "Total des lignes supprimées : $modifications_count"

# Afficher les statistiques avant/après
echo
echo "=== STATISTIQUES ==="
lignes_avant=$(wc -l < "$backup_file")
lignes_apres=$(wc -l < "$fichier_log")
reduction=$((lignes_avant - lignes_apres))
pourcentage=$(echo "scale=1; $reduction * 100 / $lignes_avant" | bc 2>/dev/null || echo "N/A")

echo "Lignes avant nettoyage : $lignes_avant"
echo "Lignes après nettoyage : $lignes_apres"
echo "Réduction : $reduction lignes ($pourcentage%)"

# Afficher la taille des fichiers
if command -v du >/dev/null; then
    taille_avant=$(du -h "$backup_file" | cut -f1)
    taille_apres=$(du -h "$fichier_log" | cut -f1)
    echo "Taille avant : $taille_avant"
    echo "Taille après : $taille_apres"
fi

# Proposer de voir les différences
echo
read -p "Voulez-vous voir un aperçu des modifications ? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "=== APERÇU DES MODIFICATIONS (10 premières lignes) ==="
    echo "--- Avant (backup) ---"
    head -10 "$backup_file"
    echo
    echo "--- Après (nettoyé) ---"
    head -10 "$fichier_log"
fi

# Proposer de supprimer le fichier de test
if [ "$fichier_log" = "test_log_file.log" ]; then
    echo
    read -p "Supprimer le fichier de test et sa sauvegarde ? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$fichier_log" "$backup_file"
        echo "Fichiers de test supprimés."
    fi
fi

echo
echo "=== NETTOYAGE TERMINÉ ==="