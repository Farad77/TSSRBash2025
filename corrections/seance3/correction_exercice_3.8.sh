#!/bin/bash

# Exercice 3.8 : Processeur de fichier CSV
# Objectif : Manipuler des données structurées

echo "=== PROCESSEUR DE FICHIER CSV ==="
echo

# Fonction pour créer un fichier CSV de test
creer_csv_test() {
    local fichier="$1"
    
    cat > "$fichier" << 'EOF'
nom,prenom,departement,salaire,date_embauche
Dupont,Jean,IT,45000,2020-03-15
Martin,Marie,RH,38000,2019-07-22
Durand,Pierre,IT,52000,2018-11-08
Bernard,Sophie,Finance,41000,2021-02-14
Petit,Luc,IT,48000,2020-09-30
Moreau,Claire,Marketing,35000,2022-01-10
Simon,Paul,Finance,44000,2019-05-18
Michel,Anne,RH,40000,2021-08-25
Leroy,David,IT,55000,2017-12-03
Roux,Emma,Marketing,37000,2023-03-22
Garcia,Carlos,IT,49000,2020-06-12
Rodriguez,Maria,Finance,43000,2021-11-05
Martinez,Antonio,Marketing,36000,2022-09-15
Lopez,Sofia,RH,39000,2023-01-08
Gonzalez,Miguel,IT,51000,2019-10-20
Sanchez,Isabel,Finance,42000,2020-12-18
Perez,Francisco,Marketing,34000,2023-05-30
Torres,Carmen,IT,47000,2021-04-07
Flores,Diego,RH,38500,2022-02-28
Herrera,Lucia,Finance,45500,2018-08-14
EOF
}

# Vérifier les paramètres
if [ $# -eq 0 ]; then
    echo "Usage : $0 <fichier_csv>"
    echo "Format attendu : nom,prenom,departement,salaire,date_embauche"
    echo
    echo "Création d'un fichier de test pour la démonstration..."
    
    csv_file="employes_test.csv"
    creer_csv_test "$csv_file"
    echo "✓ Fichier de test créé : $csv_file"
else
    csv_file="$1"
fi

# Vérifier que le fichier existe
if [ ! -f "$csv_file" ]; then
    echo "Erreur : Le fichier '$csv_file' n'existe pas"
    exit 1
fi

echo "Traitement du fichier : $csv_file"
echo "Nombre de lignes : $(wc -l < "$csv_file")"
echo

# Créer les fichiers de sortie
rapport_file="rapport_employes_$(date +%Y%m%d_%H%M%S).txt"
export_file="resultats_$(date +%Y%m%d_%H%M%S).csv"

# Vérifier le format du fichier CSV
echo "Vérification du format du fichier..."
header=$(head -1 "$csv_file")
if [[ "$header" != *"nom"* ]] || [[ "$header" != *"salaire"* ]]; then
    echo "⚠️  Format de fichier non standard détecté"
    echo "En-tête trouvé : $header"
    echo "Tentative de traitement quand même..."
fi

echo "✓ Format CSV validé"
echo

# Début du traitement avec awk
echo "=== DÉBUT DU TRAITEMENT ==="
echo "Génération du rapport d'analyse..." | tee "$rapport_file"
echo "Date : $(date)" | tee -a "$rapport_file"
echo "Fichier source : $csv_file" | tee -a "$rapport_file"
echo "========================================" | tee -a "$rapport_file"
echo | tee -a "$rapport_file"

# Script awk principal pour toutes les analyses
awk -F',' '
BEGIN {
    print "Analyse des données employés en cours..."
    total_employes = 0
    total_salaires = 0
    annee_courante = strftime("%Y")
    print "Année courante pour le calcul : " annee_courante
}

# Ignorer la ligne d'\''en-tête
NR == 1 { 
    print "En-tête détecté : " $0
    next 
}

# Traitement de chaque ligne de données
NR > 1 {
    # Nettoyer les données (supprimer les espaces)
    gsub(/^[ \t]+|[ \t]+$/, "", $1) # nom
    gsub(/^[ \t]+|[ \t]+$/, "", $2) # prenom
    gsub(/^[ \t]+|[ \t]+$/, "", $3) # departement
    gsub(/^[ \t]+|[ \t]+$/, "", $4) # salaire
    gsub(/^[ \t]+|[ \t]+$/, "", $5) # date_embauche
    
    # Variables pour faciliter la lecture
    nom = $1
    prenom = $2
    departement = $3
    salaire = $4
    date_embauche = $5
    
    # Vérifier que le salaire est numérique
    if (salaire !~ /^[0-9]+$/) {
        print "Attention: salaire non numérique pour " nom " " prenom ": " salaire
        next
    }
    
    total_employes++
    total_salaires += salaire
    
    # Statistiques par département
    dept_count[departement]++
    dept_salaires[departement] += salaire
    dept_total[departement] += salaire
    
    # Trouver l'\''employé le mieux payé
    if (salaire > max_salaire) {
        max_salaire = salaire
        best_paid = nom " " prenom " (" departement ")"
    }
    
    # Stocker tous les employés pour traitement ultérieur
    employes[total_employes] = nom "," prenom "," departement "," salaire "," date_embauche
    
    # Calculer l'\''ancienneté et identifier les embauches récentes
    split(date_embauche, date_parts, "-")
    annee_embauche = date_parts[1]
    
    if (annee_embauche == annee_courante) {
        nouveaux[++nb_nouveaux] = nom " " prenom " (" date_embauche ")"
    }
    
    # Stocker pour le calcul de la médiane
    all_salaries[total_employes] = salaire
}

END {
    if (total_employes == 0) {
        print "Aucune donnée valide trouvée dans le fichier."
        exit 1
    }
    
    print "\n=== RAPPORT D'\''ANALYSE DES EMPLOYÉS ==="
    print "=========================================="
    
    # 1. Statistiques générales
    printf "\n1. STATISTIQUES GÉNÉRALES\n"
    printf "=========================\n"
    printf "Nombre total d'\''employés : %d\n", total_employes
    printf "Salaire total de la masse salariale : %d €\n", total_salaires
    printf "Salaire moyen global : %.2f €\n", (total_employes > 0 ? total_salaires / total_employes : 0)
    
    # 2. Salaire moyen par département
    printf "\n2. SALAIRE MOYEN PAR DÉPARTEMENT\n"
    printf "=================================\n"
    for (dept in dept_count) {
        moyenne = dept_total[dept] / dept_count[dept]
        printf "%-12s : %5.2f € (moyenne sur %d employé(s))\n", 
               dept, moyenne, dept_count[dept]
    }
    
    # 3. Employé le mieux payé
    printf "\n3. EMPLOYÉ LE MIEUX PAYÉ\n"
    printf "========================\n"
    printf "%s : %d €\n", best_paid, max_salaire
    
    # 4. Employés embauchés cette année
    printf "\n4. EMPLOYÉS EMBAUCHÉS EN %s\n", annee_courante
    printf "================================\n"
    if (nb_nouveaux > 0) {
        for (i = 1; i <= nb_nouveaux; i++) {
            printf "• %s\n", nouveaux[i]
        }
    } else {
        printf "Aucun employé embauché cette année.\n"
    }
    
    # 5. BONUS : Calcul de la médiane
    printf "\n5. BONUS - MÉDIANE DES SALAIRES\n"
    printf "===============================\n"
    
    # Trier les salaires pour calculer la médiane
    n = asort(all_salaries)
    if (n % 2 == 1) {
        mediane = all_salaries[(n + 1) / 2]
    } else {
        mediane = (all_salaries[n/2] + all_salaries[n/2 + 1]) / 2
    }
    printf "Médiane des salaires : %.2f €\n", mediane
    
    # 6. Répartition des effectifs
    printf "\n6. RÉPARTITION DES EFFECTIFS\n"
    printf "=============================\n"
    for (dept in dept_count) {
        pourcentage = (total_employes > 0 ? dept_count[dept] * 100.0 / total_employes : 0)
        printf "%-12s : %2d employé(s) (%.1f%%)\n", 
               dept, dept_count[dept], pourcentage
    }
    
    # 7. Analyse des salaires
    printf "\n7. ANALYSE DES SALAIRES\n"
    printf "=======================\n"
    
    # Trouver min et max
    min_salaire = max_salaire
    for (i = 1; i <= total_employes; i++) {
        if (all_salaries[i] < min_salaire) {
            min_salaire = all_salaries[i]
        }
    }
    
    printf "Salaire minimum : %d €\n", min_salaire
    printf "Salaire maximum : %d €\n", max_salaire
    printf "Écart salarial : %d € (%.1f%%)\n", 
           (max_salaire - min_salaire), 
           (min_salaire > 0 ? (max_salaire - min_salaire) * 100.0 / min_salaire : 0)
    
    print "\n=== FIN DU RAPPORT ==="
}
' "$csv_file" | tee -a "$rapport_file"

echo
echo "=== GÉNÉRATION DU FICHIER D'EXPORT ==="

# Générer un CSV de résultats avec awk
awk -F',' '
BEGIN {
    print "departement,nb_employes,salaire_moyen,salaire_total" > "'$export_file'"
}

NR == 1 { next }  # Ignorer l'\''en-tête

NR > 1 {
    gsub(/^[ \t]+|[ \t]+$/, "", $3) # nettoyer département
    gsub(/^[ \t]+|[ \t]+$/, "", $4) # nettoyer salaire
    
    if ($4 ~ /^[0-9]+$/) {
        dept_count[$3]++
        dept_total[$3] += $4
    }
}

END {
    for (dept in dept_count) {
        moyenne = dept_total[dept] / dept_count[dept]
        printf "%s,%d,%.2f,%d\n", dept, dept_count[dept], moyenne, dept_total[dept] >> "'$export_file'"
    }
}
' "$csv_file"

echo "✓ Fichier d'export généré : $export_file"

# Afficher un aperçu des résultats
echo
echo "=== APERÇU DES RÉSULTATS D'EXPORT ==="
cat "$export_file"

# Afficher un résumé rapide
echo
echo "=== RÉSUMÉ RAPIDE ==="
awk -F',' '
NR == 1 { next }
NR > 1 && $4 ~ /^[0-9]+$/ {
    total++
    total_sal += $4
    dept[$3]++
}
END {
    printf "• Total employés : %d\n", total
    printf "• Salaire moyen : %.2f €\n", (total > 0 ? total_sal/total : 0)
    printf "• Départements : %d\n", length(dept)
    printf "• Masse salariale : %d €\n", total_sal
}
' "$csv_file"

echo
echo "📄 Rapport détaillé : $rapport_file"
echo "📊 Export CSV : $export_file"

# Proposer de voir le top 5 des salaires
echo
read -p "Voulez-vous voir le top 5 des salaires ? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "=== TOP 5 DES SALAIRES ==="
    awk -F',' 'NR > 1 && $4 ~ /^[0-9]+$/ {print $4, $1, $2, $3}' "$csv_file" | \
    sort -nr | head -5 | \
    awk '{printf "%d. %s %s (%s) : %d €\n", NR, $2, $3, $4, $1}'
fi

# Proposer de supprimer le fichier de test
if [ "$csv_file" = "employes_test.csv" ]; then
    echo
    read -p "Supprimer le fichier de test créé ? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$csv_file"
        echo "Fichier de test supprimé."
    fi
fi

echo
echo "=== TRAITEMENT CSV TERMINÉ ==="