#!/bin/bash

# Exercice 3.4 : Extracteur d'emails et URLs
# Objectif : Regex complexes avec grep

echo "=== EXTRACTEUR D'EMAILS ET URLS ==="
echo

# Vérifier si un fichier a été fourni
if [ $# -eq 0 ]; then
    echo "Usage : $0 <fichier_texte>"
    echo "Exemple : $0 document.txt"
    echo
    echo "Création d'un fichier de test pour la démonstration..."
    
    # Créer un fichier de test
    cat > test_extraction.txt << EOF
Voici un document de test pour l'extraction de données.

Contacts emails :
- Jean Dupont : jean.dupont@example.com
- Marie Martin : marie.martin@entreprise.fr
- Support technique : support@tech-company.org
- Info générale : info@site-web.net
- Contact invalide : invalid@email (pas de TLD)

Sites web à visiter :
- Site officiel : https://www.example.com
- Documentation : http://docs.example.org/guide
- API REST : https://api.service.com/v1/users
- Ressources : ftp://files.example.com/downloads
- Lien local : file:///home/user/document.pdf

Numéros de téléphone français :
- Standard : 01 23 45 67 89
- Mobile : 06.78.90.12.34
- Service client : 0800 123 456
- International : +33 1 23 45 67 89
- Numéro court : 3615

Autres données :
- Email simple : test@test.fr
- URL sans protocole : www.example.com
- Email avec sous-domaine : admin@mail.example.com
- URL HTTPS sécurisée : https://secure.bank.fr/login
EOF
    
    fichier_input="test_extraction.txt"
    echo "✓ Fichier de test créé : $fichier_input"
else
    fichier_input="$1"
fi

# Vérifier que le fichier existe
if [ ! -f "$fichier_input" ]; then
    echo "Erreur : Le fichier '$fichier_input' n'existe pas"
    exit 1
fi

echo "Traitement du fichier : $fichier_input"
echo

# Créer les noms des fichiers de sortie avec timestamp
timestamp=$(date +%Y%m%d_%H%M%S)
emails_file="emails_${timestamp}.txt"
urls_file="urls_${timestamp}.txt"
phones_file="telephones_${timestamp}.txt"
rapport_file="rapport_extraction_${timestamp}.txt"

# Début du rapport
echo "=== RAPPORT D'EXTRACTION ===" > "$rapport_file"
echo "Date : $(date)" >> "$rapport_file"
echo "Fichier source : $fichier_input" >> "$rapport_file"
echo "Taille du fichier : $(wc -c < "$fichier_input") octets" >> "$rapport_file"
echo >> "$rapport_file"

# 1. Extraire les adresses email valides
echo "1. Extraction des adresses email..."
# Regex pour emails valides (simplifiée mais robuste)
email_regex='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

grep -oE "$email_regex" "$fichier_input" | sort | uniq > "$emails_file.tmp"

# BONUS : Validation du format des emails extraits
echo "   Validation des emails extraits..."
> "$emails_file"  # Vider le fichier final

while read email; do
    # Validation supplémentaire : vérifier le format plus strictement
    if echo "$email" | grep -qE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$'; then
        # Vérifier que le domaine n'a pas de points consécutifs
        if ! echo "$email" | grep -q '\.\.'; then
            echo "$email" >> "$emails_file"
        fi
    fi
done < "$emails_file.tmp"

nb_emails=$(wc -l < "$emails_file")
echo "   ✓ $nb_emails emails valides extraits"

# 2. Extraire les URLs (http/https)
echo "2. Extraction des URLs..."
# Regex pour URLs HTTP/HTTPS
url_regex='https?://[a-zA-Z0-9.-]+[a-zA-Z0-9./?#&=_-]*'

grep -oE "$url_regex" "$fichier_input" | sort | uniq > "$urls_file"
nb_urls=$(wc -l < "$urls_file")
echo "   ✓ $nb_urls URLs extraites"

# 3. Extraire les numéros de téléphone français
echo "3. Extraction des numéros de téléphone français..."
# Plusieurs formats de téléphones français
> "$phones_file"

# Format 01 23 45 67 89
grep -oE '0[1-9]( [0-9]{2}){4}' "$fichier_input" >> "$phones_file.tmp"

# Format 01.23.45.67.89
grep -oE '0[1-9](\.[0-9]{2}){4}' "$fichier_input" >> "$phones_file.tmp"

# Format 0123456789
grep -oE '0[1-9][0-9]{8}' "$fichier_input" >> "$phones_file.tmp"

# Format international +33 1 23 45 67 89
grep -oE '\+33 [1-9]( [0-9]{2}){4}' "$fichier_input" >> "$phones_file.tmp"

# Format numéros courts (4 chiffres)
grep -oE '\b[0-9]{4}\b' "$fichier_input" | grep -E '^(3[0-9]{3}|[0-9]{4})$' >> "$phones_file.tmp"

# Trier et dédupliquer
sort "$phones_file.tmp" | uniq > "$phones_file"
nb_phones=$(wc -l < "$phones_file")
echo "   ✓ $nb_phones numéros de téléphone extraits"

# 4. Génération du rapport détaillé
echo "4. Génération du rapport détaillé..."

echo "STATISTIQUES D'EXTRACTION :" >> "$rapport_file"
echo "- Emails trouvés : $nb_emails" >> "$rapport_file"
echo "- URLs trouvées : $nb_urls" >> "$rapport_file"
echo "- Téléphones trouvés : $nb_phones" >> "$rapport_file"
echo >> "$rapport_file"

# Détail des emails
echo "=== EMAILS EXTRAITS ===" >> "$rapport_file"
if [ $nb_emails -gt 0 ]; then
    cat "$emails_file" | sed 's/^/- /' >> "$rapport_file"
    
    # Analyse des domaines
    echo >> "$rapport_file"
    echo "Répartition par domaine :" >> "$rapport_file"
    cut -d@ -f2 "$emails_file" | sort | uniq -c | sort -nr | sed 's/^/  /' >> "$rapport_file"
else
    echo "Aucun email trouvé." >> "$rapport_file"
fi
echo >> "$rapport_file"

# Détail des URLs
echo "=== URLS EXTRAITES ===" >> "$rapport_file"
if [ $nb_urls -gt 0 ]; then
    cat "$urls_file" | sed 's/^/- /' >> "$rapport_file"
    
    # Analyse des protocoles
    echo >> "$rapport_file"
    echo "Répartition par protocole :" >> "$rapport_file"
    grep -o '^https\?://' "$urls_file" | sort | uniq -c | sort -nr | sed 's/^/  /' >> "$rapport_file"
else
    echo "Aucune URL trouvée." >> "$rapport_file"
fi
echo >> "$rapport_file"

# Détail des téléphones
echo "=== TÉLÉPHONES EXTRAITS ===" >> "$rapport_file"
if [ $nb_phones -gt 0 ]; then
    cat "$phones_file" | sed 's/^/- /' >> "$rapport_file"
    
    # Classification par type
    echo >> "$rapport_file"
    echo "Classification par type :" >> "$rapport_file"
    
    nb_fixe=$(grep -c '^0[1-5]' "$phones_file" 2>/dev/null || echo 0)
    nb_mobile=$(grep -c '^0[67]' "$phones_file" 2>/dev/null || echo 0)
    nb_special=$(grep -c '^0[89]' "$phones_file" 2>/dev/null || echo 0)
    nb_intl=$(grep -c '^\+33' "$phones_file" 2>/dev/null || echo 0)
    
    echo "  Fixes (01-05) : $nb_fixe" >> "$rapport_file"
    echo "  Mobiles (06-07) : $nb_mobile" >> "$rapport_file"
    echo "  Spéciaux (08-09) : $nb_special" >> "$rapport_file"
    echo "  Internationaux (+33) : $nb_intl" >> "$rapport_file"
else
    echo "Aucun téléphone trouvé." >> "$rapport_file"
fi

echo >> "$rapport_file"
echo "=== FIN DU RAPPORT ===" >> "$rapport_file"
echo "Généré le $(date) par $0" >> "$rapport_file"

# Affichage du résumé
echo
echo "=== RÉSUMÉ DE L'EXTRACTION ==="
echo "📧 Emails extraits : $nb_emails (sauvés dans $emails_file)"
echo "🌐 URLs extraites : $nb_urls (sauvées dans $urls_file)"
echo "📞 Téléphones extraits : $nb_phones (sauvés dans $phones_file)"
echo "📄 Rapport détaillé : $rapport_file"

# Nettoyage des fichiers temporaires
rm -f "$emails_file.tmp" "$phones_file.tmp"

# Afficher un aperçu des résultats
if [ $nb_emails -gt 0 ]; then
    echo
    echo "Aperçu des emails (3 premiers) :"
    head -3 "$emails_file" | sed 's/^/  - /'
fi

if [ $nb_urls -gt 0 ]; then
    echo
    echo "Aperçu des URLs (3 premières) :"
    head -3 "$urls_file" | sed 's/^/  - /'
fi

# Proposer de supprimer le fichier de test
if [ "$fichier_input" = "test_extraction.txt" ]; then
    echo
    read -p "Supprimer le fichier de test créé ? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$fichier_input"
        echo "Fichier de test supprimé."
    fi
fi

echo
echo "=== EXTRACTION TERMINÉE ==="