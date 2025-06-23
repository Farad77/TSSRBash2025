#!/bin/bash

# Exercice 1.6 : Gestionnaire de paramètres 
# Objectif : Maîtriser les paramètres positionnels SANS boucles ni conditions


echo "=== GESTIONNAIRE DE PARAMÈTRES ===" 
echo

# Afficher le nom du script ($0)
echo "Nom du script : $0"

# Afficher le nombre de paramètres reçus ($#)
echo "Nombre de paramètres reçus : $#"

echo
echo "=== PARAMÈTRES INDIVIDUELS ==="
# Afficher les 3 premiers paramètres directement
echo "Premier paramètre (\$1) : $1"
echo "Deuxième paramètre (\$2) : $2"
echo "Troisième paramètre (\$3) : $3"

echo
echo "=== TOUS LES PARAMÈTRES ==="
# Afficher tous les paramètres avec \$@ et \$*
echo "Tous les paramètres (\$@) : $@"
echo "Tous les paramètres (\$*) : $*"

echo
echo "=== INFORMATIONS COMPLÉMENTAIRES ==="
echo "Répertoire de travail : $(pwd)"
echo "Utilisateur actuel : $(whoami)"
echo "Date d'exécution : $(date)"

echo
echo "=== EXEMPLE D'UTILISATION ==="
echo "Pour tester ce script, exécutez :"
echo "$0 param1 param2 param3 param4"

echo
echo "=== FIN DE L'ANALYSE ==="

# NOTE PÉDAGOGIQUE :
# Cette version utilise uniquement les concepts vus en Séance 1 :
# - Variables positionnelles ($0, $1, $2, $3, $#, $@, $*)
# - Affichage avec echo
# - Substitution de commande $(commande)
# Les boucles for et conditions if/then seront vues en Séance 2 !