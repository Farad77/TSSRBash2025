#!/bin/bash

# Exercice 2.2 : Analyseur de mots de passe
# Objectif : Combiner plusieurs conditions

echo "=== ANALYSEUR DE MOTS DE PASSE ==="
echo

# Demander un mot de passe en mode masqué
read -s -p "Entrez votre mot de passe : " mot_de_passe
echo

# Variables pour les vérifications
longueur=${#mot_de_passe}
score=0
recommandations=""

echo
echo "=== ANALYSE DU MOT DE PASSE ==="

# Vérifier la longueur (minimum 8 caractères)
if [ $longueur -ge 8 ]; then
    echo "✓ Longueur suffisante ($longueur caractères)"
    score=$((score + 1))
else
    echo "✗ Longueur insuffisante ($longueur caractères, minimum 8)"
    recommandations="$recommandations\n- Utilisez au moins 8 caractères"
fi

# Vérifier s'il contient des chiffres
if echo "$mot_de_passe" | grep -q "[0-9]"; then
    echo "✓ Contient des chiffres"
    score=$((score + 1))
else
    echo "✗ Ne contient pas de chiffres"
    recommandations="$recommandations\n- Ajoutez des chiffres"
fi

# Vérifier s'il contient des lettres
if echo "$mot_de_passe" | grep -q "[a-zA-Z]"; then
    echo "✓ Contient des lettres"
    score=$((score + 1))
else
    echo "✗ Ne contient pas de lettres"
    recommandations="$recommandations\n- Ajoutez des lettres"
fi

# BONUS : Vérifier la présence de caractères spéciaux
if echo "$mot_de_passe" | grep -q "[^a-zA-Z0-9]"; then
    echo "✓ BONUS : Contient des caractères spéciaux"
    score=$((score + 1))
else
    echo "✗ BONUS : Ne contient pas de caractères spéciaux"
    recommandations="$recommandations\n- Ajoutez des caractères spéciaux (!@#$%^&*)"
fi

echo

# Attribuer un score de sécurité
case $score in
    0|1)
        niveau="Faible"
        ;;
    2)
        niveau="Moyen"
        ;;
    3|4)
        niveau="Fort"
        ;;
esac

echo "=== RÉSULTAT ==="
echo "Score de sécurité : $score/4"
echo "Niveau : $niveau"

# Afficher des recommandations si nécessaire
if [ $score -lt 4 ]; then
    echo
    echo "=== RECOMMANDATIONS D'AMÉLIORATION ==="
    echo -e "$recommandations"
fi

echo
echo "=== FIN DE L'ANALYSE ==="