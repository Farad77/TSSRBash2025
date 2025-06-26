#!/bin/bash

# Exercice 3.7 : Analyseur de logs Apache
# Objectif : Extraire des statistiques avec awk

echo "=== ANALYSEUR DE LOGS APACHE ==="
echo

# Fonction pour créer un log Apache de test
creer_log_apache() {
    local fichier="$1"
    
    cat > "$fichier" << 'EOF'
192.168.1.100 - - [25/Dec/2023:10:00:12 +0100] "GET /index.html HTTP/1.1" 200 2326
10.0.0.5 - - [25/Dec/2023:10:00:15 +0100] "GET /about.html HTTP/1.1" 200 1547
192.168.1.100 - - [25/Dec/2023:10:01:22 +0100] "POST /login HTTP/1.1" 200 1024
203.0.113.15 - - [25/Dec/2023:10:02:33 +0100] "GET /nonexistent.html HTTP/1.1" 404 512
192.168.1.100 - - [25/Dec/2023:10:03:45 +0100] "GET /images/logo.png HTTP/1.1" 200 15432
10.0.0.5 - - [25/Dec/2023:10:04:12 +0100] "GET /contact.html HTTP/1.1" 200 2156
203.0.113.15 - - [25/Dec/2023:10:05:23 +0100] "GET /admin HTTP/1.1" 403 256
192.168.1.101 - - [25/Dec/2023:10:06:34 +0100] "GET /index.html HTTP/1.1" 200 2326
10.0.0.5 - - [25/Dec/2023:10:07:45 +0100] "POST /submit HTTP/1.1" 500 1024
192.168.1.100 - - [25/Dec/2023:10:08:56 +0100] "GET /styles.css HTTP/1.1" 200 8765
203.0.113.15 - - [25/Dec/2023:10:09:12 +0100] "GET /missing.php HTTP/1.1" 404 512
192.168.1.101 - - [25/Dec/2023:10:10:23 +0100] "GET /products.html HTTP/1.1" 200 3456
10.0.0.5 - - [25/Dec/2023:10:11:34 +0100] "GET /search?q=test HTTP/1.1" 200 1234
192.168.1.100 - - [25/Dec/2023:10:12:45 +0100] "GET /api/users HTTP/1.1" 200 5678
203.0.113.15 - - [25/Dec/2023:10:13:56 +0100] "GET /hidden.html HTTP/1.1" 404 512
192.168.1.102 - - [25/Dec/2023:11:00:12 +0100] "GET /index.html HTTP/1.1" 200 2326
192.168.1.102 - - [25/Dec/2023:11:01:23 +0100] "POST /api/data HTTP/1.1" 500 2048
10.0.0.5 - - [25/Dec/2023:11:02:34 +0100] "GET /downloads/file.pdf HTTP/1.1" 200 102400
192.168.1.100 - - [25/Dec/2023:11:03:45 +0100] "GET /dashboard HTTP/1.1" 200 4567
203.0.113.15 - - [25/Dec/2023:11:04:56 +0100] "GET /test.jsp HTTP/1.1" 404 512
EOF
}

# Vérifier les paramètres
if [ $# -eq 0 ]; then
    echo "Usage : $0 <fichier_log_apache>"
    echo "Format attendu : IP - - [date] \"méthode URL\" code taille"
    echo
    echo "Création d'un fichier de test pour la démonstration..."
    
    log_file="apache_access_test.log"
    creer_log_apache "$log_file"
    echo "✓ Fichier de test créé : $log_file"
else
    log_file="$1"
fi

# Vérifier que le fichier existe
if [ ! -f "$log_file" ]; then
    echo "Erreur : Le fichier '$log_file' n'existe pas"
    exit 1
fi

echo "Analyse du fichier : $log_file"
echo "Taille du fichier : $(wc -l < "$log_file") lignes"
echo

# Créer le fichier de rapport
rapport_file="stats_apache_$(date +%Y%m%d_%H%M%S).txt"

echo "=== RAPPORT D'ANALYSE APACHE ===" > "$rapport_file"
echo "Date d'analyse : $(date)" >> "$rapport_file"
echo "Fichier analysé : $log_file" >> "$rapport_file"
echo "======================================" >> "$rapport_file"
echo >> "$rapport_file"

# Script awk pour l'analyse complète
awk '
BEGIN {
    print "Début de l'\''analyse des logs Apache..."
    total_requests = 0
    total_bytes = 0
}

# Traitement de chaque ligne
{
    # Vérifier que la ligne a le bon format
    if (NF >= 10) {
        total_requests++
        
        # Extraire les champs
        ip = $1
        date_time = $4 " " $5
        method = $6
        url = $7
        protocol = $8
        status_code = $9
        bytes = $10
        
        # Enlever les caractères [ ] et " du parsing
        gsub(/[\[\]"]/, "", date_time)
        gsub(/["]/, "", method)
        gsub(/["]/, "", url)
        gsub(/["]/, "", protocol)
        
        # Compter les requêtes par IP
        ip_count[ip]++
        
        # Compter les codes de statut
        status_count[status_code]++
        
        # Calculer la bande passante
        if (bytes ~ /^[0-9]+$/) {
            total_bytes += bytes
            ip_bytes[ip] += bytes
        }
        
        # Extraire l'\''heure pour les statistiques horaires (BONUS)
        split(date_time, date_parts, ":")
        if (length(date_parts) >= 2) {
            hour = date_parts[2]
            hour_count[hour]++
        }
        
        # Compter les méthodes HTTP
        method_count[method]++
        
        # Compter les URL les plus demandées
        url_count[url]++
    }
}

END {
    # 1. Nombre total de requêtes
    print "1. STATISTIQUES GÉNÉRALES"
    print "========================="
    printf "Nombre total de requêtes : %d\n", total_requests
    printf "Bande passante totale : %.2f MB (%d octets)\n", total_bytes/1048576, total_bytes
    printf "Taille moyenne par requête : %.2f octets\n", (total_requests > 0 ? total_bytes/total_requests : 0)
    print ""
    
    # 2. Top 10 des IP les plus fréquentes
    print "2. TOP 10 DES ADRESSES IP"
    print "========================="
    
    # Trier les IP par nombre de requêtes
    n = asorti(ip_count, sorted_ips)
    count = 0
    for (i = n; i >= 1 && count < 10; i--) {
        ip = sorted_ips[i]
        requests = ip_count[ip]
        bytes_ip = ip_bytes[ip]
        percentage = (total_requests > 0 ? requests * 100.0 / total_requests : 0)
        printf "%2d. %-15s : %5d requêtes (%.1f%%) - %.2f MB\n", 
               ++count, ip, requests, percentage, bytes_ip/1048576
    }
    print ""
    
    # 3. Codes d'\''erreur 404 et 500
    print "3. CODES D'\''ERREUR"
    print "=================="
    errors_404 = (status_count["404"] ? status_count["404"] : 0)
    errors_500 = (status_count["500"] ? status_count["500"] : 0)
    printf "Erreurs 404 (Not Found) : %d\n", errors_404
    printf "Erreurs 500 (Server Error) : %d\n", errors_500
    
    print "\nRépartition de tous les codes de statut :"
    for (code in status_count) {
        percentage = (total_requests > 0 ? status_count[code] * 100.0 / total_requests : 0)
        printf "  %s : %d (%.1f%%)\n", code, status_count[code], percentage
    }
    print ""
    
    # 4. Méthodes HTTP
    print "4. MÉTHODES HTTP"
    print "================"
    for (method in method_count) {
        percentage = (total_requests > 0 ? method_count[method] * 100.0 / total_requests : 0)
        printf "%-6s : %5d requêtes (%.1f%%)\n", method, method_count[method], percentage
    }
    print ""
    
    # 5. BONUS : Statistiques par heure
    print "5. BONUS - RÉPARTITION PAR HEURE"
    print "================================="
    for (h = 0; h <= 23; h++) {
        hour_key = sprintf("%02d", h)
        count = (hour_count[hour_key] ? hour_count[hour_key] : 0)
        if (count > 0) {
            percentage = (total_requests > 0 ? count * 100.0 / total_requests : 0)
            # Créer une barre graphique ASCII
            bar_length = int(count * 40 / total_requests)
            bar = ""
            for (j = 0; j < bar_length; j++) {
                bar = bar "#"
            }
            printf "%02d:xx [%3d] %-40s (%.1f%%)\n", h, count, bar, percentage
        }
    }
    print ""
    
    # 6. Top 5 des URL les plus demandées
    print "6. TOP 5 DES URLS LES PLUS DEMANDÉES"
    print "===================================="
    n = asorti(url_count, sorted_urls)
    count = 0
    for (i = n; i >= 1 && count < 5; i--) {
        url = sorted_urls[i]
        requests = url_count[url]
        percentage = (total_requests > 0 ? requests * 100.0 / total_requests : 0)
        printf "%d. %-30s : %d requêtes (%.1f%%)\n", 
               ++count, url, requests, percentage
    }
    print ""
    
    print "Analyse terminée."
}
' "$log_file" | tee -a "$rapport_file"

echo
echo "=== RÉSUMÉ RAPIDE ==="

# Résumé rapide avec awk
awk '
{
    if (NF >= 10) {
        total++
        if ($9 == "404") errors_404++
        if ($9 == "500") errors_500++
        if ($10 ~ /^[0-9]+$/) total_bytes += $10
        ip_count[$1]++
    }
}
END {
    printf "• Total requêtes : %d\n", total
    printf "• Erreurs 404 : %d\n", (errors_404 ? errors_404 : 0)
    printf "• Erreurs 500 : %d\n", (errors_500 ? errors_500 : 0)
    printf "• Bande passante : %.2f MB\n", total_bytes/1048576
    printf "• IPs uniques : %d\n", length(ip_count)
}
' "$log_file"

echo
echo "📄 Rapport détaillé sauvegardé dans : $rapport_file"

# Proposer de voir les IP les plus actives en temps réel
echo
read -p "Voulez-vous voir le top 5 des IP en temps réel ? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "=== TOP 5 IP EN TEMPS RÉEL ==="
    awk '{if (NF >= 10) ip[$1]++} END {for (i in ip) print ip[i], i}' "$log_file" | \
    sort -nr | head -5 | \
    awk '{printf "%2d. %-15s : %d requêtes\n", NR, $2, $1}'
fi

# Proposer de supprimer le fichier de test
if [ "$log_file" = "apache_access_test.log" ]; then
    echo
    read -p "Supprimer le fichier de test créé ? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$log_file"
        echo "Fichier de test supprimé."
    fi
fi

echo
echo "=== ANALYSE APACHE TERMINÉE ==="