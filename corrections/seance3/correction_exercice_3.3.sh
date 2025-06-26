#!/bin/bash

# Exercice 3.3 : Auditeur de configurations
# Objectif : Utiliser grep et regex pour l'audit

echo "=== AUDITEUR DE CONFIGURATIONS ==="
echo

# Définir les couleurs pour la sortie (BONUS)
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Créer des fichiers de configuration de test si nécessaire
if [ ! -f "*.conf" ]; then
    echo "Création de fichiers de configuration de test..."
    
    cat > test_apache.conf << EOF
ServerName example.com
Listen 80
Listen 443
DocumentRoot /var/www/html
<VirtualHost 192.168.1.100:80>
    ServerName test.example.com
    DocumentRoot /var/www/test
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log
</VirtualHost>
# Configuration avec mot de passe (ATTENTION)
# password=admin123
AuthUserFile /etc/apache2/.htpasswd
EOF

    cat > test_ssh.conf << EOF
Port 22
ListenAddress 0.0.0.0
ListenAddress 192.168.1.50
PermitRootLogin yes
PasswordAuthentication yes
LogLevel INFO
SyslogFacility AUTH
AuthorizedKeysFile /home/%u/.ssh/authorized_keys
# Attention: password=secret123 dans ce fichier
MaxAuthTries 6
EOF

    cat > test_mysql.conf << EOF
[mysql]
host = localhost
port = 3306
user = root
password = mysql_secret
database = production

[client]
host = 127.0.0.1
port = 3306
socket = /var/run/mysqld/mysqld.sock
default-character-set = utf8mb4

# Logs
log-error = /var/log/mysql/error.log
slow_query_log_file = /var/log/mysql/slow.log
EOF

    echo "✓ Fichiers de test créés"
fi

# Nom du fichier de rapport
RAPPORT_FILE="audit_config_$(date +%Y%m%d_%H%M%S).txt"

echo "Démarrage de l'audit de sécurité..." | tee "$RAPPORT_FILE"
echo "Date : $(date)" | tee -a "$RAPPORT_FILE"
echo "========================================" | tee -a "$RAPPORT_FILE"
echo

# 1. Rechercher les adresses IP dans tous les fichiers .conf
echo -e "${BLUE}1. RECHERCHE DES ADRESSES IP${NC}" | tee -a "$RAPPORT_FILE"
echo "Recherche dans tous les fichiers .conf..." | tee -a "$RAPPORT_FILE"

IP_REGEX='([0-9]{1,3}\.){3}[0-9]{1,3}'
grep -rn --include="*.conf" -E "$IP_REGEX" . | while read line; do
    fichier=$(echo "$line" | cut -d: -f1)
    ligne_num=$(echo "$line" | cut -d: -f2)
    contenu=$(echo "$line" | cut -d: -f3-)
    ip=$(echo "$contenu" | grep -oE "$IP_REGEX")
    
    echo "   Fichier: $fichier:$ligne_num" | tee -a "$RAPPORT_FILE"
    echo "   IP trouvée: $ip" | tee -a "$RAPPORT_FILE"
    echo "   Contexte: $contenu" | tee -a "$RAPPORT_FILE"
    echo | tee -a "$RAPPORT_FILE"
done

# 2. Trouver les ports ouverts (format :port)
echo -e "${BLUE}2. RECHERCHE DES PORTS${NC}" | tee -a "$RAPPORT_FILE"
echo "Recherche des ports configurés..." | tee -a "$RAPPORT_FILE"

PORT_REGEX=':[0-9]{1,5}'
grep -rn --include="*.conf" -E "(Listen|Port|ListenAddress).*:[0-9]+" . | while read line; do
    fichier=$(echo "$line" | cut -d: -f1)
    ligne_num=$(echo "$line" | cut -d: -f2)
    contenu=$(echo "$line" | cut -d: -f3-)
    port=$(echo "$contenu" | grep -oE '[0-9]{1,5}$')
    
    # Vérifier si c'est un port standard ou non standard
    if [ "$port" = "22" ] || [ "$port" = "80" ] || [ "$port" = "443" ]; then
        status="Standard"
    else
        status="${YELLOW}Non-standard${NC}"
    fi
    
    echo -e "   Fichier: $fichier:$ligne_num" | tee -a "$RAPPORT_FILE"
    echo -e "   Port: $port ($status)" | tee -a "$RAPPORT_FILE"
    echo "   Ligne: $contenu" | tee -a "$RAPPORT_FILE"
    echo | tee -a "$RAPPORT_FILE"
done

# 3. Identifier les mots de passe en dur (CRITIQUE)
echo -e "${RED}3. RECHERCHE DES MOTS DE PASSE EN DUR (CRITIQUE)${NC}" | tee -a "$RAPPORT_FILE"
echo "⚠️  Recherche de mots de passe stockés en clair..." | tee -a "$RAPPORT_FILE"

PASSWORD_REGEX='(password|passwd|pwd)[[:space:]]*[=:][[:space:]]*[^[:space:]#]+'
grep -rn --include="*.conf" -iE "$PASSWORD_REGEX" . | while read line; do
    fichier=$(echo "$line" | cut -d: -f1)
    ligne_num=$(echo "$line" | cut -d: -f2)
    contenu=$(echo "$line" | cut -d: -f3-)
    
    echo -e "   ${RED}🚨 ALERTE SÉCURITÉ${NC}" | tee -a "$RAPPORT_FILE"
    echo "   Fichier: $fichier:$ligne_num" | tee -a "$RAPPORT_FILE"
    echo "   Mot de passe trouvé: $contenu" | tee -a "$RAPPORT_FILE"
    echo "   ⚠️  Action requise: Chiffrer ou déplacer ce mot de passe" | tee -a "$RAPPORT_FILE"
    echo | tee -a "$RAPPORT_FILE"
done

# 4. Lister les fichiers de log configurés
echo -e "${BLUE}4. FICHIERS DE LOG CONFIGURÉS${NC}" | tee -a "$RAPPORT_FILE"
echo "Recherche des configurations de logs..." | tee -a "$RAPPORT_FILE"

LOG_REGEX='(log|Log)[[:space:]]*[=:][[:space:]]*[^[:space:]#]+'
grep -rn --include="*.conf" -E "(ErrorLog|CustomLog|LogFile|log[_-]?file)" . | while read line; do
    fichier=$(echo "$line" | cut -d: -f1)
    ligne_num=$(echo "$line" | cut -d: -f2)
    contenu=$(echo "$line" | cut -d: -f3-)
    log_file=$(echo "$contenu" | awk '{print $NF}')
    
    echo "   Fichier config: $fichier:$ligne_num" | tee -a "$RAPPORT_FILE"
    echo "   Log configuré: $log_file" | tee -a "$RAPPORT_FILE"
    
    # Vérifier si le fichier de log existe
    if [ -f "$log_file" ]; then
        taille=$(stat -c%s "$log_file" 2>/dev/null || echo "0")
        echo "   Statut: ✓ Existe (taille: $taille octets)" | tee -a "$RAPPORT_FILE"
    else
        echo "   Statut: ⚠️  N'existe pas encore" | tee -a "$RAPPORT_FILE"
    fi
    echo | tee -a "$RAPPORT_FILE"
done

# 5. Générer un rapport d'audit sécurisé
echo -e "${GREEN}5. GÉNÉRATION DU RAPPORT FINAL${NC}" | tee -a "$RAPPORT_FILE"
echo "========================================" | tee -a "$RAPPORT_FILE"

# Compter les éléments trouvés
nb_ips=$(grep -r --include="*.conf" -E "$IP_REGEX" . | wc -l)
nb_ports=$(grep -r --include="*.conf" -E "(Listen|Port).*:[0-9]+" . | wc -l)
nb_passwords=$(grep -r --include="*.conf" -iE "$PASSWORD_REGEX" . | wc -l)
nb_logs=$(grep -r --include="*.conf" -E "(ErrorLog|CustomLog|LogFile)" . | wc -l)

echo "RÉSUMÉ DE L'AUDIT :" | tee -a "$RAPPORT_FILE"
echo "- Adresses IP trouvées : $nb_ips" | tee -a "$RAPPORT_FILE"
echo "- Ports configurés : $nb_ports" | tee -a "$RAPPORT_FILE"
echo "- Mots de passe en dur : $nb_passwords" | tee -a "$RAPPORT_FILE"
echo "- Fichiers de log : $nb_logs" | tee -a "$RAPPORT_FILE"
echo | tee -a "$RAPPORT_FILE"

# Niveau de sécurité global
if [ "$nb_passwords" -gt 0 ]; then
    niveau="CRITIQUE"
    couleur="$RED"
elif [ "$nb_ips" -gt 5 ] || [ "$nb_ports" -gt 5 ]; then
    niveau="MOYEN"
    couleur="$YELLOW"
else
    niveau="BON"
    couleur="$GREEN"
fi

echo -e "NIVEAU DE SÉCURITÉ : ${couleur}$niveau${NC}" | tee -a "$RAPPORT_FILE"
echo | tee -a "$RAPPORT_FILE"

# Recommandations
echo "RECOMMANDATIONS :" | tee -a "$RAPPORT_FILE"
if [ "$nb_passwords" -gt 0 ]; then
    echo "🚨 URGENT: Supprimer tous les mots de passe en clair" | tee -a "$RAPPORT_FILE"
fi
echo "- Vérifier que les IPs autorisées sont légitimes" | tee -a "$RAPPORT_FILE"
echo "- Sécuriser les ports non-standards" | tee -a "$RAPPORT_FILE"
echo "- Mettre en place la rotation des logs" | tee -a "$RAPPORT_FILE"
echo "- Implémenter un système de monitoring" | tee -a "$RAPPORT_FILE"

echo | tee -a "$RAPPORT_FILE"
echo "Rapport généré le $(date) par $0" | tee -a "$RAPPORT_FILE"

echo
echo "=== AUDIT TERMINÉ ==="
echo "Rapport sauvegardé dans : $RAPPORT_FILE"

# Nettoyer les fichiers de test
read -p "Supprimer les fichiers de test créés ? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f test_*.conf
    echo "Fichiers de test supprimés."
fi

echo
echo "=== FIN DE L'AUDIT ==="