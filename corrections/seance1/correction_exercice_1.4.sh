#!/bin/bash

# Exercice 1.4 : Manipulation de chaînes
# Objectif : Travailler avec les chaînes de caractères

echo "=== MANIPULATION DE CHAÎNES ==="
echo

# Stockage du prénom et nom dans des variables séparées
prenom="Marie"
nom="Martin"

echo "Prénom : $prenom"
echo "Nom : $nom"
echo

# Concaténation du prénom et nom avec un espace
nom_complet="$prenom $nom"
echo "Nom complet : $nom_complet"

# Affichage de la longueur du nom complet
longueur=${#nom_complet}
echo "Longueur du nom complet : $longueur caractères"

# Conversion en majuscules et minuscules
majuscules=$(echo "$nom_complet" | tr '[:lower:]' '[:upper:]')
minuscules=$(echo "$nom_complet" | tr '[:upper:]' '[:lower:]')

echo "En majuscules : $majuscules"
echo "En minuscules : $minuscules"

# Extraction des 3 premiers caractères du prénom
trois_premiers=${prenom:0:3}
echo "3 premiers caractères du prénom : $trois_premiers"

echo

# BONUS : Inversion de l'ordre (nom, prénom) avec une virgule
nom_inverse="$nom, $prenom"
echo "BONUS - Format inversé : $nom_inverse"

echo
echo "=== FIN DE LA MANIPULATION ==="