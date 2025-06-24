#!/bin/bash

# Exercice 2.5 : Générateur de fichiers de test
# Objectif : Utiliser les boucles for

echo "=== GÉNÉRATEUR DE FICHIERS DE TEST ==="
echo

# Nettoyer les fichiers/dossiers existants si nécessaire
echo "Nettoyage des fichiers de test précédents..."
rm -f test_*.txt 2>/dev/null
rm -rf dossier_* 2>/dev/null

echo "Début de la génération..."

# Créer 10 fichiers nommés "test_01.txt" à "test_10.txt"
echo
echo "=== CRÉATION DES FICHIERS ==="
for i in {01..10}; do
    nom_fichier="test_$i.txt"
    echo "Fichier de test numéro $i" > "$nom_fichier"
    
    # BONUS : Ajouter des métadonnées (date, taille)
    echo "Créé le : $(date)" >> "$nom_fichier"
    echo "Taille : $(wc -c < "$nom_fichier") octets" >> "$nom_fichier"
    
    echo "✓ Créé : $nom_fichier"
done

echo
echo "=== CRÉATION DES RÉPERTOIRES ==="
# Créer 5 répertoires nommés "dossier_A" à "dossier_E"
for lettre in A B C D E; do
    nom_dossier="dossier_$lettre"
    mkdir -p "$nom_dossier"
    echo "✓ Créé : $nom_dossier"
    
    # Placer 2 fichiers dans chaque répertoire
    for num in 1 2; do
        nom_fichier="$nom_dossier/fichier_${lettre}${num}.txt"
        echo "Fichier $num dans le dossier $lettre" > "$nom_fichier"
        echo "Créé le : $(date)" >> "$nom_fichier"
        echo "  ✓ Créé : $nom_fichier"
    done
done

echo
echo "=== RÉSUMÉ DES CRÉATIONS ==="
echo "Fichiers de test créés : $(ls test_*.txt 2>/dev/null | wc -l)"
echo "Répertoires créés : $(ls -d dossier_* 2>/dev/null | wc -l)"

# Compter le total de fichiers dans les dossiers
total_fichiers_dossiers=0
for dossier in dossier_*; do
    if [ -d "$dossier" ]; then
        nb_fichiers=$(ls "$dossier"/*.txt 2>/dev/null | wc -l)
        total_fichiers_dossiers=$((total_fichiers_dossiers + nb_fichiers))
    fi
done

echo "Fichiers dans les répertoires : $total_fichiers_dossiers"
echo "Total général : $((10 + total_fichiers_dossiers)) fichiers créés"

echo
echo "=== STRUCTURE CRÉÉE ==="
ls -la test_*.txt dossier_*/

echo
echo "=== GÉNÉRATION TERMINÉE ==="