#!/bin/bash

# Exercice 2.7 : Bibliothèque mathématique
# Objectif : Créer et utiliser des fonctions

echo "=== BIBLIOTHÈQUE MATHÉMATIQUE ==="
echo

# Fonction addition
addition() {
    local a=$1
    local b=$2
    
    # BONUS : Validation des paramètres
    if [[ ! "$a" =~ ^-?[0-9]+$ ]] || [[ ! "$b" =~ ^-?[0-9]+$ ]]; then
        echo "Erreur : Les paramètres doivent être des nombres entiers"
        return 1
    fi
    
    echo $((a + b))
}

# Fonction factorielle
factorielle() {
    local n=$1
    
    # BONUS : Validation des paramètres
    if [[ ! "$n" =~ ^[0-9]+$ ]]; then
        echo "Erreur : Le paramètre doit être un nombre entier positif"
        return 1
    fi
    
    if [ $n -lt 0 ]; then
        echo "Erreur : La factorielle n'est pas définie pour les nombres négatifs"
        return 1
    fi
    
    if [ $n -eq 0 ] || [ $n -eq 1 ]; then
        echo 1
        return 0
    fi
    
    local resultat=1
    for ((i=2; i<=n; i++)); do
        resultat=$((resultat * i))
    done
    
    echo $resultat
}

# Fonction est_pair
est_pair() {
    local n=$1
    
    # BONUS : Validation des paramètres
    if [[ ! "$n" =~ ^-?[0-9]+$ ]]; then
        echo "Erreur : Le paramètre doit être un nombre entier"
        return 1
    fi
    
    if [ $((n % 2)) -eq 0 ]; then
        return 0  # pair
    else
        return 1  # impair
    fi
}

# Fonction pgcd (Plus Grand Commun Diviseur)
pgcd() {
    local a=$1
    local b=$2
    
    # BONUS : Validation des paramètres
    if [[ ! "$a" =~ ^[0-9]+$ ]] || [[ ! "$b" =~ ^[0-9]+$ ]]; then
        echo "Erreur : Les paramètres doivent être des nombres entiers positifs"
        return 1
    fi
    
    # Algorithme d'Euclide
    while [ $b -ne 0 ]; do
        local temp=$b
        b=$((a % b))
        a=$temp
    done
    
    echo $a
}

# Tests des fonctions
echo "=== TESTS DES FONCTIONS ==="
echo

echo "1. Test de la fonction addition :"
result=$(addition 15 25)
echo "   addition(15, 25) = $result"

echo
echo "2. Test de la fonction factorielle :"
result=$(factorielle 5)
echo "   factorielle(5) = $result"

echo
echo "3. Test de la fonction est_pair :"
if est_pair 8; then
    echo "   est_pair(8) = PAIR"
else
    echo "   est_pair(8) = IMPAIR"
fi

if est_pair 7; then
    echo "   est_pair(7) = PAIR"
else
    echo "   est_pair(7) = IMPAIR"
fi

echo
echo "4. Test de la fonction pgcd :"
result=$(pgcd 48 18)
echo "   pgcd(48, 18) = $result"

echo
echo "=== TESTS BONUS - VALIDATION DES PARAMÈTRES ==="
echo "Test avec paramètre invalide :"
addition "abc" 5 2>/dev/null || echo "   ✓ Validation fonctionne pour addition"
factorielle "-5" 2>/dev/null || echo "   ✓ Validation fonctionne pour factorielle"

echo
echo "=== FIN DES TESTS ==="