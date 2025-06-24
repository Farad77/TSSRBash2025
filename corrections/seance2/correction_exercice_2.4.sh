#!/bin/bash

# Exercice 2.4 : Classificateur de fichiers
# Objectif : Utiliser case avec des patterns

echo "=== CLASSIFICATEUR DE FICHIERS ==="

# Vérifier si un fichier a été fourni en paramètre
if [ $# -eq 0 ]; then
    echo "Usage : $0 <nom_du_fichier>"
    echo "Exemple : $0 document.txt"
    exit 1
fi

nom_fichier="$1"
echo "Fichier à analyser : $nom_fichier"

# Extraire l'extension du fichier
extension="${nom_fichier##*.}"
extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

echo

# Classifier selon l'extension
case "$extension_lower" in
    txt|md)
        type_fichier="Fichier texte"
        ;;
    jpg|jpeg|png|gif|bmp)
        type_fichier="Image"
        ;;
    sh|py|pl|rb)
        type_fichier="Script"
        ;;
    tar|gz|zip|rar|7z)
        type_fichier="Archive"
        ;;
    pdf)
        type_fichier="Document PDF"
        ;;
    doc|docx)
        type_fichier="Document Word"
        ;;
    mp3|wav|flac)
        type_fichier="Fichier audio"
        ;;
    mp4|avi|mkv)
        type_fichier="Fichier vidéo"
        ;;
    *)
        type_fichier="Type inconnu"
        ;;
esac

echo "Type de fichier : $type_fichier"
echo "Extension détectée : .$extension_lower"

# BONUS : Ajouter la taille du fichier s'il existe
if [ -f "$nom_fichier" ]; then
    taille=$(stat -c%s "$nom_fichier" 2>/dev/null || stat -f%z "$nom_fichier" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "BONUS - Taille du fichier : $taille octets"
        
        # Conversion en unités plus lisibles
        if [ $taille -gt 1048576 ]; then
            taille_mb=$((taille / 1048576))
            echo "BONUS - Taille lisible : $taille_mb MB"
        elif [ $taille -gt 1024 ]; then
            taille_kb=$((taille / 1024))
            echo "BONUS - Taille lisible : $taille_kb KB"
        fi
    fi
elif [ -e "$nom_fichier" ]; then
    echo "BONUS - Le fichier existe mais n'est pas un fichier régulier"
else
    echo "BONUS - Le fichier n'existe pas"
fi

echo
echo "=== FIN DE LA CLASSIFICATION ==="