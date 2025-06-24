#!/bin/bash

# Exercice 2.6 : Moniteur de services
# Objectif : Utiliser while pour la surveillance

echo "=== MONITEUR DE SERVICES ==="
echo

# Nettoyer le fichier stop.txt s'il existe
rm -f stop.txt

echo "Le moniteur surveille l'existence du fichier 'stop.txt'"
echo "Pour arrêter le service, créez ce fichier avec : touch stop.txt"
echo "BONUS : Limitation à 20 itérations maximum"
echo

iteration=0
max_iterations=20

# Boucle de surveillance
while [ ! -f "stop.txt" ] && [ $iteration -lt $max_iterations ]; do
    iteration=$((iteration + 1))
    
    # Afficher l'heure et le statut
    echo "[$iteration/20] $(date '+%H:%M:%S') - Service en cours..."
    
    # Attendre 5 secondes
    sleep 5
    
    # Vérifier la charge système
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    echo "  Charge système : $load_avg"
    
    # Vérification optionnelle de la mémoire
    if command -v free > /dev/null; then
        mem_usage=$(free | awk '/^Mem:/ {printf "%.1f", $3/$2 * 100.0}')
        echo "  Utilisation mémoire : ${mem_usage}%"
    fi
    
    echo
done

echo
echo "=== ARRÊT DU MONITEUR ==="

# Vérifier pourquoi la boucle s'est arrêtée
if [ -f "stop.txt" ]; then
    echo "✓ Arrêt demandé (fichier stop.txt détecté)"
    echo "Contenu du fichier stop.txt :"
    cat stop.txt 2>/dev/null || echo "(fichier vide)"
    rm -f stop.txt
    echo "Fichier stop.txt supprimé."
elif [ $iteration -ge $max_iterations ]; then
    echo "✓ BONUS : Arrêt automatique (limite de $max_iterations itérations atteinte)"
fi

echo
echo "Service arrêté à $(date)"
echo "Nombre total d'itérations : $iteration"
echo
echo "=== FIN DU MONITORING ==="