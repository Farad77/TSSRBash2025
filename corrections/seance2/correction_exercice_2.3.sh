#!/bin/bash

# Exercice 2.3 : Menu système interactif
# Objectif : Créer un menu avec case/esac

afficher_menu() {
    echo
    echo "=== MENU SYSTÈME INTERACTIF ==="
    echo "1) Afficher la date et l'heure"
    echo "2) Afficher l'espace disque"
    echo "3) Afficher les utilisateurs connectés"
    echo "4) Afficher les processus"
    echo "5) Quitter"
    echo "================================="
}

while true; do
    afficher_menu
    read -p "Votre choix (1-5) : " choix
    
    case $choix in
        1)
            echo
            echo "=== DATE ET HEURE ==="
            date
            echo "====================="
            ;;
        2)
            echo
            echo "=== ESPACE DISQUE ==="
            df -h
            echo "====================="
            ;;
        3)
            echo
            echo "=== UTILISATEURS CONNECTÉS ==="
            who
            echo "==============================="
            ;;
        4)
            echo
            echo "=== PROCESSUS ==="
            ps aux | head -10
            echo "=================="
            ;;
        5)
            echo
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo
            echo "✗ ERREUR : Choix invalide. Veuillez choisir entre 1 et 5."
            echo "BONUS : Gestion d'erreur pour les choix invalides"
            ;;
    esac
    
    # Pause pour lire le résultat
    echo
    read -p "Appuyez sur Entrée pour continuer..."
done