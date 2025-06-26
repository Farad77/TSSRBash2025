#!/bin/bash

# Exercice 3.1 : Analyseur de logs système
# Objectif : Maîtriser redirections et pipes

echo "=== ANALYSEUR DE LOGS SYSTÈME ==="
echo

# Créer un fichier de log de test si /var/log/syslog n'existe pas
LOG_FILE="/var/log/syslog"
if [ ! -f "$LOG_FILE" ]; then
    LOG_FILE="test_syslog.log"
    echo "Création d'un fichier de test car /var/log/syslog n'est pas accessible..."
    
    # Générer un fichier de log de test
    cat > "$LOG_FILE" << EOF
$(date '+%b %d %H:%M:%S') server01 kernel: [12345.678] USB disconnect
$(date '+%b %d %H:%M:%S') server01 sshd[1234]: Connection from 192.168.1.100 port 22
$(date '+%b %d %H:%M:%S') server01 apache2: ERROR: Configuration file not found
$(date '+%b %d %H:%M:%S') server01 kernel: [12346.789] USB connect
$(date '+%b %d %H:%M:%S') server01 sshd[1235]: Accepted password for user01 from 192.168.1.101
$(date '+%b %d %H:%M:%S') server01 apache2: ERROR: Permission denied
$(date '+%b %d %H:%M:%S') server01 mysql: Connection established
$(date '+%b %d %H:%M:%S') server01 postfix: Connection from mail.example.com
$(date '+%b %d %H:%M:%S') server01 sshd[1236]: Connection from 192.168.1.102 port 22
$(date '+%b %d %H:%M:%S') server01 apache2: Started successfully
EOF
    echo "✓ Fichier de test créé : $LOG_FILE"
fi

echo "Analyse du fichier : $LOG_FILE"
echo

# Créer le nom du fichier de rapport avec timestamp
RAPPORT_FILE="rapport_$(date +%Y%m%d).txt"

# Rediriger toutes les erreurs vers erreurs.log
exec 2> erreurs.log

echo "=== DÉBUT DE L'ANALYSE ===" > "$RAPPORT_FILE"
echo "Date du rapport : $(date)" >> "$RAPPORT_FILE"
echo "Fichier analysé : $LOG_FILE" >> "$RAPPORT_FILE"
echo >> "$RAPPORT_FILE"

# 1. Compter le nombre d'erreurs (lignes contenant "error")
echo "1. Analyse des erreurs..." | tee -a "$RAPPORT_FILE"
NB_ERREURS=$(grep -i "error" "$LOG_FILE" | wc -l)
echo "   Nombre d'erreurs trouvées : $NB_ERREURS" | tee -a "$RAPPORT_FILE"

if [ $NB_ERREURS -gt 0 ]; then
    echo "   Détail des erreurs :" >> "$RAPPORT_FILE"
    grep -i "error" "$LOG_FILE" | sed 's/^/   /' >> "$RAPPORT_FILE"
fi
echo >> "$RAPPORT_FILE"

# 2. Extraire les 10 dernières connexions
echo "2. Analyse des connexions..." | tee -a "$RAPPORT_FILE"
echo "   Les 10 dernières connexions :" >> "$RAPPORT_FILE"
grep -i "connection" "$LOG_FILE" | tail -10 | sed 's/^/   /' >> "$RAPPORT_FILE"
echo >> "$RAPPORT_FILE"

# 3. Analyse des services
echo "3. Analyse des services..." | tee -a "$RAPPORT_FILE"
echo "   Répartition par service :" >> "$RAPPORT_FILE"
awk '{print $5}' "$LOG_FILE" | sed 's/:.*$//' | sort | uniq -c | sort -nr | sed 's/^/   /' >> "$RAPPORT_FILE"
echo >> "$RAPPORT_FILE"

# BONUS : Créer un graphique ASCII des erreurs par heure
echo "4. BONUS - Graphique des erreurs par heure..." | tee -a "$RAPPORT_FILE"
echo "   Répartition des erreurs par heure :" >> "$RAPPORT_FILE"

# Extraire l'heure des erreurs et compter
grep -i "error" "$LOG_FILE" | awk '{print $3}' | cut -d: -f1 | sort | uniq -c | while read count hour; do
    # Créer une barre ASCII proportionnelle
    bars=""
    for ((i=1; i<=count; i++)); do
        bars="$bars#"
    done
    printf "   %02d:xx [%2d] %s\n" "$hour" "$count" "$bars" >> "$RAPPORT_FILE"
done

echo >> "$RAPPORT_FILE"

# 5. Statistiques générales
echo "5. Statistiques générales..." | tee -a "$RAPPORT_FILE"
TOTAL_LIGNES=$(wc -l < "$LOG_FILE")
echo "   Total de lignes analysées : $TOTAL_LIGNES" >> "$RAPPORT_FILE"

# Top 5 des adresses IP
echo "   Top 5 des adresses IP :" >> "$RAPPORT_FILE"
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5 | sed 's/^/   /' >> "$RAPPORT_FILE"

echo >> "$RAPPORT_FILE"
echo "=== FIN DE L'ANALYSE ===" >> "$RAPPORT_FILE"
echo "Généré le $(date) par $0" >> "$RAPPORT_FILE"

echo
echo "=== RÉSULTATS ==="
echo "✓ Rapport sauvegardé dans : $RAPPORT_FILE"
echo "✓ Erreurs redirigées vers : erreurs.log"
echo "✓ Analyse terminée avec succès"

# Afficher un résumé
echo
echo "=== RÉSUMÉ ==="
echo "Nombre total de lignes : $(wc -l < "$LOG_FILE")"
echo "Nombre d'erreurs : $NB_ERREURS"
echo "Taille du rapport : $(wc -l < "$RAPPORT_FILE") lignes"

# Nettoyer le fichier de test si créé
if [ "$LOG_FILE" = "test_syslog.log" ]; then
    echo
    read -p "Supprimer le fichier de test créé ? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$LOG_FILE"
        echo "Fichier de test supprimé."
    fi
fi

echo
echo "=== FIN DE L'ANALYSEUR ==="