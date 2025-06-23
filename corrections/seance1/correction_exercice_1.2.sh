#!/bin/bash

# Exercice 1.2 : Script d'information système
# Objectif : Découvrir les commandes système de base

echo "========================================="
echo "         INFORMATIONS SYSTÈME"
echo "========================================="
echo

# Le nom d'utilisateur connecté (whoami)
echo "--- UTILISATEUR CONNECTÉ ---"
echo "Utilisateur : $(whoami)"
echo

# L'espace disque disponible (df -h)
echo "--- ESPACE DISQUE ---"
df -h
echo

# La charge système (uptime)
echo "--- CHARGE SYSTÈME ---"
uptime
echo

# Les 5 derniers utilisateurs connectés (last -5)
echo "--- DERNIÈRES CONNEXIONS ---"
last -5
echo

echo "========================================="
echo "         FIN DU RAPPORT"
echo "========================================="