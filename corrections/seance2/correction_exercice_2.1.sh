#!/bin/bash

# Exercice 2.1 : Vérificateur d'âge et permissions
# Objectif : Utiliser les conditions pour des vérifications

echo "=== VÉRIFICATEUR D'ÂGE ET PERMISSIONS ==="
echo

# Demander l'âge de l'utilisateur
read -p "Quel est votre âge ? " age

# Vérifier et afficher la catégorie d'âge
if [ $age -lt 18 ]; then
    echo "Catégorie : Mineur ($age ans)"
elif [ $age -lt 65 ]; then
    echo "Catégorie : Majeur ($age ans)"
else
    echo "Catégorie : Senior ($age ans)"
fi

echo

# Vérifier si un fichier a été fourni en paramètre
if [ $# -eq 0 ]; then
    echo "Usage : $0 <nom_du_fichier>"
    echo "Exemple : $0 /etc/passwd"
    exit 1
fi

nom_fichier="$1"
echo "=== VÉRIFICATION DU FICHIER : $nom_fichier ==="

# Vérifier si le fichier existe
if [ -e "$nom_fichier" ]; then
    echo "✓ Le fichier existe"
    
    # Vérifier le type
    if [ -f "$nom_fichier" ]; then
        echo "✓ C'est un fichier régulier"
    elif [ -d "$nom_fichier" ]; then
        echo "✓ C'est un répertoire (BONUS)"
    fi
    
    # Vérifier les permissions
    if [ -r "$nom_fichier" ]; then
        echo "✓ Le fichier est lisible"
    else
        echo "✗ Le fichier n'est pas lisible"
    fi
    
    if [ -w "$nom_fichier" ]; then
        echo "✓ Le fichier est écritable"
    else
        echo "✗ Le fichier n'est pas écritable"
    fi
    
    if [ -x "$nom_fichier" ]; then
        echo "✓ Le fichier est exécutable"
    else
        echo "✗ Le fichier n'est pas exécutable"
    fi
    
else
    echo "✗ Le fichier n'existe pas"
fi

echo
echo "=== FIN DE LA VÉRIFICATION ==="