#!/bin/bash

# Exercice 1.3 : Calculatrice simple
# Objectif : Manipuler les variables numériques et opérations

echo "=== CALCULATRICE SIMPLE ==="
echo

# Définition de deux nombres dans des variables
nombre1=15
nombre2=4

echo "Nombre 1 : $nombre1"
echo "Nombre 2 : $nombre2"
echo

# Calcul et affichage de la somme
somme=$((nombre1 + nombre2))
echo "$nombre1 + $nombre2 = $somme"

# Calcul et affichage de la différence
difference=$((nombre1 - nombre2))
echo "$nombre1 - $nombre2 = $difference"

# Calcul et affichage du produit
produit=$((nombre1 * nombre2))
echo "$nombre1 × $nombre2 = $produit"

# Calcul du reste de la division (modulo)
modulo=$((nombre1 % nombre2))
echo "$nombre1 % $nombre2 = $modulo"

echo

# BONUS : Division avec gestion de la division par zéro
if [ $nombre2 -ne 0 ]; then
    division=$((nombre1 / nombre2))
    echo "BONUS - Division : $nombre1 ÷ $nombre2 = $division"
else
    echo "BONUS - Division : Impossible (division par zéro)"
fi

echo
echo "=== FIN DES CALCULS ==="