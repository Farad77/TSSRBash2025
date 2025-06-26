#!/bin/bash

# Script d'analyse de logs Apache
# Usage: ./script.sh access.log

LOG_FILE="$1"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="rapport_apache_$TIMESTAMP.txt"
ERROR_FILE="erreurs_$TIMESTAMP.log"

# Vérifier si le fichier est fourni
if [ -z "$LOG_FILE" ]; then
    echo "Usage: $0 <fichier_log_apache>" 2>> "$ERROR_FILE"
    exit 1
fi

# Vérifier si le fichier existe
if [ ! -f "$LOG_FILE" ]; then
    echo "Erreur: Le fichier $LOG_FILE n'existe pas" 2>> "$ERROR_FILE"
    exit 1
fi

# Créer le rapport avec timestamp
echo "=== RAPPORT D'ANALYSE DES LOGS APACHE ===" > "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "Date de génération: $(date)" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "Fichier analysé: $LOG_FILE" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Compter les erreurs HTTP (4xx et 5xx)
echo "=== ERREURS HTTP ===" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Erreurs 4xx (erreurs client) - Pattern précis après les guillemets
echo "--- Erreurs 4xx (Client) ---" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
grep '" 4[0-9][0-9] ' "$LOG_FILE" > temp_4xx.txt 2>> "$ERROR_FILE"
cat temp_4xx.txt >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "Nombre d'erreurs 4xx: $(grep -c '" 4[0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE")" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Erreurs 5xx (erreurs serveur) - Pattern précis après les guillemets
echo "--- Erreurs 5xx (Serveur) ---" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
grep '" 5[0-9][0-9] ' "$LOG_FILE" > temp_5xx.txt 2>> "$ERROR_FILE"
cat temp_5xx.txt >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "Nombre d'erreurs 5xx: $(grep -c '" 5[0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE")" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Total des erreurs HTTP
grep '" [45][0-9][0-9] ' "$LOG_FILE" > temp_all_errors.txt 2>> "$ERROR_FILE"
echo "TOTAL DES ERREURS HTTP: $(grep -c '" [45][0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE")" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Extraire les 10 dernières connexions (codes 2xx et 3xx) - Pattern précis
echo "=== 10 DERNIÈRES CONNEXIONS RÉUSSIES ===" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
grep '" [23][0-9][0-9] ' "$LOG_FILE" > temp_success.txt 2>> "$ERROR_FILE"
tail -10 temp_success.txt >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Statistiques par code d'erreur courant - Patterns précis
echo "=== DÉTAIL DES CODES D'ERREUR ===" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "404 Not Found: $(grep -c '" 404 ' "$LOG_FILE" 2>> "$ERROR_FILE")" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "403 Forbidden: $(grep -c '" 403 ' "$LOG_FILE" 2>> "$ERROR_FILE")" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "500 Internal Server Error: $(grep -c '" 500 ' "$LOG_FILE" 2>> "$ERROR_FILE")" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "502 Bad Gateway: $(grep -c '" 502 ' "$LOG_FILE" 2>> "$ERROR_FILE")" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "503 Service Unavailable: $(grep -c '" 503 ' "$LOG_FILE" 2>> "$ERROR_FILE")" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Nettoyer les fichiers temporaires
rm -f temp_4xx.txt temp_5xx.txt temp_all_errors.txt temp_success.txt 2>> "$ERROR_FILE"

# Afficher le résultat
echo "Analyse des logs Apache terminée!"
echo "Rapport sauvegardé: $REPORT_FILE"
echo "Erreurs redirigées vers: $ERROR_FILE"
echo ""
echo "Résumé rapide:"
echo "- Erreurs 4xx: $(grep -c '" 4[0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE")"
echo "- Erreurs 5xx: $(grep -c '" 5[0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE")"
echo "- 404 Not Found: $(grep -c '" 404 ' "$LOG_FILE" 2>> "$ERROR_FILE")"