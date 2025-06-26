#!/bin/bash

# Exercice 3.5 : Configurateur automatique SSH
# Objectif : Modifier des fichiers de configuration avec sed

echo "=== CONFIGURATEUR AUTOMATIQUE SSH ==="
echo

# Configuration par défaut
SSH_CONFIG="/etc/ssh/sshd_config"
SSH_CONFIG_TEST="sshd_config_test"
BACKUP_SUFFIX=".backup_$(date +%Y%m%d_%H%M%S)"

# Vérifier les permissions et créer un fichier de test si nécessaire
if [ ! -r "$SSH_CONFIG" ] || [ ! -w "$(dirname "$SSH_CONFIG")" ]; then
    echo "⚠️  Pas d'accès à $SSH_CONFIG, création d'un fichier de test..."
    
    # Créer un fichier sshd_config de test
    cat > "$SSH_CONFIG_TEST" << 'EOF'
# SSH Daemon configuration file
# Generated for testing purposes

Port 22
Protocol 2
ListenAddress 0.0.0.0
ListenAddress ::

# Authentication
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no

# Logging
SyslogFacility AUTH
LogLevel INFO

# Security settings
X11Forwarding yes
MaxAuthTries 6
ClientAliveInterval 0
ClientAliveCountMax 3

# Subsystem
Subsystem sftp /usr/lib/openssh/sftp-server

# Override default of no subsystems
UsePAM yes
PrintMotd no
AcceptEnv LANG LC_*
EOF
    
    SSH_CONFIG="$SSH_CONFIG_TEST"
    echo "✓ Fichier de test créé : $SSH_CONFIG"
fi

echo "Configuration SSH à modifier : $SSH_CONFIG"
echo

# Fonction pour valider la configuration SSH
valider_config() {
    if command -v sshd >/dev/null 2>&1; then
        echo "Validation de la configuration SSH..."
        if sshd -t -f "$SSH_CONFIG" 2>/dev/null; then
            echo "✓ Configuration SSH valide"
            return 0
        else
            echo "❌ Configuration SSH invalide"
            return 1
        fi
    else
        echo "⚠️  Commande sshd non disponible, validation manuelle requise"
        return 0
    fi
}

# Fonction pour créer une sauvegarde
creer_sauvegarde() {
    local fichier="$1"
    local backup="${fichier}${BACKUP_SUFFIX}"
    
    if cp "$fichier" "$backup"; then
        echo "✓ Sauvegarde créée : $backup"
        return 0
    else
        echo "❌ Impossible de créer la sauvegarde"
        return 1
    fi
}

# Fonction pour appliquer les modifications avec sed
appliquer_modifications() {
    local config_file="$1"
    local temp_file="${config_file}.tmp"
    
    echo "Application des modifications avec sed..."
    
    # Copier le fichier original vers un fichier temporaire
    cp "$config_file" "$temp_file"
    
    # 1. Changer le port par défaut (22 → 2222)
    echo "  1. Modification du port SSH (22 → 2222)..."
    sed -i 's/^Port 22$/Port 2222/' "$temp_file"
    sed -i 's/^#Port 22$/Port 2222/' "$temp_file"
    
    # S'assurer qu'il y a une ligne Port si elle n'existe pas
    if ! grep -q "^Port " "$temp_file"; then
        sed -i '1i Port 2222' "$temp_file"
    fi
    
    # 2. Désactiver l'authentification par mot de passe root
    echo "  2. Désactivation de l'authentification root par mot de passe..."
    sed -i 's/^PermitRootLogin yes$/PermitRootLogin prohibit-password/' "$temp_file"
    sed -i 's/^#PermitRootLogin yes$/PermitRootLogin prohibit-password/' "$temp_file"
    
    # S'assurer qu'il y a une ligne PermitRootLogin
    if ! grep -q "^PermitRootLogin " "$temp_file"; then
        sed -i '/^# Authentication/a PermitRootLogin prohibit-password' "$temp_file"
    fi
    
    # 3. Activer les logs détaillés
    echo "  3. Activation des logs détaillés..."
    sed -i 's/^LogLevel INFO$/LogLevel VERBOSE/' "$temp_file"
    sed -i 's/^#LogLevel INFO$/LogLevel VERBOSE/' "$temp_file"
    
    # S'assurer qu'il y a une ligne LogLevel
    if ! grep -q "^LogLevel " "$temp_file"; then
        sed -i '/^# Logging/a LogLevel VERBOSE' "$temp_file"
    fi
    
    # 4. Ajouter des paramètres de sécurité supplémentaires
    echo "  4. Ajout de paramètres de sécurité..."
    
    # Limiter les tentatives d'authentification
    sed -i 's/^MaxAuthTries [0-9]*$/MaxAuthTries 3/' "$temp_file"
    if ! grep -q "^MaxAuthTries " "$temp_file"; then
        sed -i '/^# Security settings/a MaxAuthTries 3' "$temp_file"
    fi
    
    # Ajouter un délai pour les connexions échouées
    if ! grep -q "^LoginGraceTime " "$temp_file"; then
        sed -i '/^MaxAuthTries /a LoginGraceTime 60' "$temp_file"
    fi
    
    # Désactiver la connexion pour les comptes sans mot de passe
    sed -i 's/^PermitEmptyPasswords yes$/PermitEmptyPasswords no/' "$temp_file"
    if ! grep -q "^PermitEmptyPasswords " "$temp_file"; then
        sed -i '/^LoginGraceTime /a PermitEmptyPasswords no' "$temp_file"
    fi
    
    # 5. Ajouter un commentaire de modification
    echo "  5. Ajout d'un en-tête de modification..."
    sed -i "1i # Configuration modifiée automatiquement le $(date)" "$temp_file"
    sed -i "2i # Modifications appliquées :" "$temp_file"
    sed -i "3i #   - Port changé de 22 à 2222" "$temp_file"
    sed -i "4i #   - PermitRootLogin configuré en prohibit-password" "$temp_file"
    sed -i "5i #   - LogLevel configuré en VERBOSE" "$temp_file"
    sed -i "6i #   - MaxAuthTries limité à 3" "$temp_file"
    sed -i "7i # " "$temp_file"
    
    # Remplacer le fichier original par le fichier modifié
    mv "$temp_file" "$config_file"
    
    echo "✓ Modifications appliquées avec succès"
}

# Fonction pour afficher un résumé des changements
afficher_resume() {
    local config_file="$1"
    
    echo
    echo "=== RÉSUMÉ DES CHANGEMENTS EFFECTUÉS ==="
    
    # Vérifier le port
    port=$(grep "^Port " "$config_file" | awk '{print $2}')
    echo "• Port SSH : $port"
    
    # Vérifier PermitRootLogin
    root_login=$(grep "^PermitRootLogin " "$config_file" | awk '{print $2}')
    echo "• Connexion root : $root_login"
    
    # Vérifier LogLevel
    log_level=$(grep "^LogLevel " "$config_file" | awk '{print $2}')
    echo "• Niveau de log : $log_level"
    
    # Vérifier MaxAuthTries
    max_auth=$(grep "^MaxAuthTries " "$config_file" | awk '{print $2}')
    echo "• Tentatives d'auth max : $max_auth"
    
    # Vérifier PermitEmptyPasswords
    empty_pass=$(grep "^PermitEmptyPasswords " "$config_file" | awk '{print $2}')
    echo "• Mots de passe vides : $empty_pass"
    
    echo
    echo "=== RECOMMANDATIONS ==="
    echo "1. Redémarrez le service SSH : sudo systemctl restart ssh"
    echo "2. Testez la connexion sur le nouveau port : ssh -p $port user@server"
    echo "3. Configurez votre pare-feu pour le port $port"
    echo "4. Mettez à jour vos scripts et clients SSH"
    echo "5. Vérifiez les logs dans /var/log/auth.log"
}

# Début du script principal
echo "Début de la configuration automatique SSH..."
echo

# Étape 1 : Créer une sauvegarde
echo "=== ÉTAPE 1 : SAUVEGARDE ==="
if ! creer_sauvegarde "$SSH_CONFIG"; then
    echo "Arrêt du script en raison de l'échec de la sauvegarde"
    exit 1
fi

echo

# Étape 2 : Valider la configuration actuelle
echo "=== ÉTAPE 2 : VALIDATION INITIALE ==="
valider_config

echo

# Étape 3 : Appliquer les modifications
echo "=== ÉTAPE 3 : MODIFICATION ==="
appliquer_modifications "$SSH_CONFIG"

echo

# Étape 4 : Valider la nouvelle configuration (BONUS)
echo "=== ÉTAPE 4 : VALIDATION FINALE (BONUS) ==="
if valider_config; then
    echo "✓ La configuration modifiée est valide"
else
    echo "❌ La configuration modifiée est invalide"
    echo "⚠️  Restauration de la sauvegarde..."
    
    backup_file="${SSH_CONFIG}${BACKUP_SUFFIX}"
    if [ -f "$backup_file" ]; then
        cp "$backup_file" "$SSH_CONFIG"
        echo "✓ Configuration restaurée depuis la sauvegarde"
    fi
    exit 1
fi

echo

# Étape 5 : Afficher le résumé
echo "=== ÉTAPE 5 : RÉSUMÉ ==="
afficher_resume "$SSH_CONFIG"

# Proposer de voir les différences
echo
read -p "Voulez-vous voir les différences avec l'original ? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    backup_file="${SSH_CONFIG}${BACKUP_SUFFIX}"
    if [ -f "$backup_file" ]; then
        echo
        echo "=== DIFFÉRENCES ==="
        diff -u "$backup_file" "$SSH_CONFIG" || true
    fi
fi

# Nettoyer si c'est un fichier de test
if [ "$SSH_CONFIG" = "$SSH_CONFIG_TEST" ]; then
    echo
    read -p "Supprimer le fichier de test et sa sauvegarde ? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$SSH_CONFIG_TEST" "${SSH_CONFIG_TEST}${BACKUP_SUFFIX}"
        echo "Fichiers de test supprimés."
    fi
fi

echo
echo "=== CONFIGURATION SSH TERMINÉE ==="