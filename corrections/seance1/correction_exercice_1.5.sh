#!/bin/bash

# Exercice 1.5 : Script de salutation interactif 
# Objectif : Utiliser read pour l'interaction utilisateur


echo "=== SCRIPT DE SALUTATION INTERACTIF ==="
echo

# Demander le nom de l'utilisateur
read -p "Quel est votre nom ? " nom_utilisateur

# Demander son âge
read -p "Quel est votre âge ? " age_utilisateur

# Demander sa ville (version simplifiée sans timeout)
read -p "Dans quelle ville habitez-vous ? " ville_utilisateur

echo
echo "=== MESSAGE PERSONNALISÉ ==="
echo "Bonjour $nom_utilisateur !"
echo "Vous avez $age_utilisateur ans."
echo "Vous habitez à $ville_utilisateur."

echo
echo "Ravi de faire votre connaissance !"

echo
echo "=== INFORMATIONS RÉCAPITULATIVES ==="
echo "Nom complet de l'utilisateur : $nom_utilisateur"
echo "Âge saisi : $age_utilisateur"
echo "Ville de résidence : $ville_utilisateur"
echo "Script exécuté le : $(date)"

echo
echo "=== FIN DE LA SALUTATION ==="

# NOTE PÉDAGOGIQUE :
# Cette version utilise uniquement les concepts vus en Séance 1 :
# - Variables et affectation
# - Commande read avec option -p
# - Affichage avec echo
# - Substitution de commande $(date)
# Les conditions if/then seront vues en Séance 2 !