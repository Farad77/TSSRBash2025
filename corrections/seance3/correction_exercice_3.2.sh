#!/bin/bash

# Script d'analyse de logs Apache avec rapport HTML
# Usage: ./script.sh access.log

LOG_FILE="$1"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="rapport_apache_$TIMESTAMP.html"
ERROR_FILE="erreurs_$TIMESTAMP.log"

# Vérifier si le fichier est fourni
if [ -z "$LOG_FILE" ]; then
    echo "Usage: $0 <fichier_log_apache>" 2>> "$ERROR_FILE"
    exit 1
fi

# Vérifier si le fichier existe
if [ ! -f "$LOG_FILE" ]; then
    echo "Erreur: Le fichier $LOG_FILE n'existe pas" 2>> "$ERROR_FILE"
    exit 1
fi

# Créer le début du rapport HTML
cat > "$REPORT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport d'Analyse des Logs Apache</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
            color: #333;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            font-weight: 300;
        }
        
        .header .meta {
            opacity: 0.9;
            font-size: 1.1em;
        }
        
        .content {
            padding: 30px;
        }
        
        .section {
            margin-bottom: 40px;
            background: #f8f9fa;
            border-radius: 10px;
            padding: 25px;
            border-left: 5px solid #3498db;
        }
        
        .section h2 {
            color: #2c3e50;
            font-size: 1.8em;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
        }
        
        .section h3 {
            color: #34495e;
            font-size: 1.3em;
            margin: 20px 0 15px 0;
            padding-bottom: 10px;
            border-bottom: 2px solid #ecf0f1;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            text-align: center;
            border-top: 4px solid #3498db;
        }
        
        .stat-card.error {
            border-top-color: #e74c3c;
        }
        
        .stat-card.warning {
            border-top-color: #f39c12;
        }
        
        .stat-card.success {
            border-top-color: #27ae60;
        }
        
        .stat-number {
            font-size: 2.5em;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #7f8c8d;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .log-entry {
            background: #2c3e50;
            color: #ecf0f1;
            padding: 12px 15px;
            margin: 8px 0;
            border-radius: 5px;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
            font-size: 0.85em;
            line-height: 1.4;
            overflow-x: auto;
            border-left: 4px solid #e74c3c;
        }
        
        .log-entry.success {
            border-left-color: #27ae60;
            background: #27ae60;
            color: white;
        }
        
        .status-4xx {
            color: #f39c12;
            font-weight: bold;
        }
        
        .status-5xx {
            color: #e74c3c;
            font-weight: bold;
        }
        
        .status-2xx {
            color: #27ae60;
            font-weight: bold;
        }
        
        .icon {
            margin-right: 10px;
            font-size: 1.2em;
        }
        
        .footer {
            background: #34495e;
            color: white;
            padding: 20px;
            text-align: center;
            font-size: 0.9em;
        }
        
        .error-summary {
            background: #fff5f5;
            border: 1px solid #fed7d7;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
        }
        
        .no-data {
            text-align: center;
            color: #7f8c8d;
            font-style: italic;
            padding: 20px;
        }
        
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .header h1 {
                font-size: 2em;
            }
            
            .content {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Rapport d'Analyse Apache</h1>
            <div class="meta">
EOF

# Ajouter les métadonnées dynamiques
echo "                <p>Généré le: $(date '+%d/%m/%Y à %H:%M:%S')</p>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
echo "                <p>Fichier analysé: <strong>$LOG_FILE</strong></p>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Continuer le HTML
cat >> "$REPORT_FILE" << 'EOF' 2>> "$ERROR_FILE"
            </div>
        </div>
        
        <div class="content">
EOF

# Calculer les statistiques
ERROR_4XX=$(grep -c '" 4[0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE")
ERROR_5XX=$(grep -c '" 5[0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE")
TOTAL_ERRORS=$((ERROR_4XX + ERROR_5XX))
SUCCESS_COUNT=$(grep -c '" [23][0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE")
ERROR_404=$(grep -c '" 404 ' "$LOG_FILE" 2>> "$ERROR_FILE")
ERROR_403=$(grep -c '" 403 ' "$LOG_FILE" 2>> "$ERROR_FILE")
ERROR_500=$(grep -c '" 500 ' "$LOG_FILE" 2>> "$ERROR_FILE")
ERROR_502=$(grep -c '" 502 ' "$LOG_FILE" 2>> "$ERROR_FILE")
ERROR_503=$(grep -c '" 503 ' "$LOG_FILE" 2>> "$ERROR_FILE")

# Section des statistiques générales
cat >> "$REPORT_FILE" << EOF 2>> "$ERROR_FILE"
            <div class="section">
                <h2><span class="icon">📈</span>Statistiques Générales</h2>
                <div class="stats-grid">
                    <div class="stat-card error">
                        <div class="stat-number">$TOTAL_ERRORS</div>
                        <div class="stat-label">Total Erreurs</div>
                    </div>
                    <div class="stat-card warning">
                        <div class="stat-number">$ERROR_4XX</div>
                        <div class="stat-label">Erreurs 4xx</div>
                    </div>
                    <div class="stat-card error">
                        <div class="stat-number">$ERROR_5XX</div>
                        <div class="stat-label">Erreurs 5xx</div>
                    </div>
                    <div class="stat-card success">
                        <div class="stat-number">$SUCCESS_COUNT</div>
                        <div class="stat-label">Succès</div>
                    </div>
                </div>
            </div>
EOF

# Section des erreurs 4xx
cat >> "$REPORT_FILE" << 'EOF' 2>> "$ERROR_FILE"
            <div class="section">
                <h2><span class="icon">⚠️</span>Erreurs Client (4xx)</h2>
EOF

if [ "$ERROR_4XX" -gt 0 ]; then
    echo "                <div class=\"error-summary\">" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
    echo "                    <strong>$ERROR_4XX erreurs client détectées</strong>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
    echo "                </div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
    
    grep '" 4[0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE" | while read line; do
        echo "                <div class=\"log-entry\">" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
        echo "                    $line" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
        echo "                </div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
    done
else
    echo "                <div class=\"no-data\">Aucune erreur 4xx détectée ✅</div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
fi

echo "            </div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Section des erreurs 5xx
cat >> "$REPORT_FILE" << 'EOF' 2>> "$ERROR_FILE"
            <div class="section">
                <h2><span class="icon">🚨</span>Erreurs Serveur (5xx)</h2>
EOF

if [ "$ERROR_5XX" -gt 0 ]; then
    echo "                <div class=\"error-summary\">" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
    echo "                    <strong>$ERROR_5XX erreurs serveur détectées</strong>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
    echo "                </div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
    
    grep '" 5[0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE" | while read line; do
        echo "                <div class=\"log-entry\">" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
        echo "                    $line" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
        echo "                </div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
    done
else
    echo "                <div class=\"no-data\">Aucune erreur 5xx détectée ✅</div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
fi

echo "            </div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Section des détails par code d'erreur
cat >> "$REPORT_FILE" << EOF 2>> "$ERROR_FILE"
            <div class="section">
                <h2><span class="icon">🔍</span>Détail par Code d'Erreur</h2>
                <div class="stats-grid">
                    <div class="stat-card warning">
                        <div class="stat-number">$ERROR_404</div>
                        <div class="stat-label">404 Not Found</div>
                    </div>
                    <div class="stat-card warning">
                        <div class="stat-number">$ERROR_403</div>
                        <div class="stat-label">403 Forbidden</div>
                    </div>
                    <div class="stat-card error">
                        <div class="stat-number">$ERROR_500</div>
                        <div class="stat-label">500 Internal Error</div>
                    </div>
                    <div class="stat-card error">
                        <div class="stat-number">$ERROR_502</div>
                        <div class="stat-label">502 Bad Gateway</div>
                    </div>
                    <div class="stat-card error">
                        <div class="stat-number">$ERROR_503</div>
                        <div class="stat-label">503 Service Unavailable</div>
                    </div>
                </div>
            </div>
EOF

# Section des 10 dernières connexions réussies
cat >> "$REPORT_FILE" << 'EOF' 2>> "$ERROR_FILE"
            <div class="section">
                <h2><span class="icon">✅</span>10 Dernières Connexions Réussies</h2>
EOF

grep '" [23][0-9][0-9] ' "$LOG_FILE" 2>> "$ERROR_FILE" | tail -10 > temp_success.txt 2>> "$ERROR_FILE"

if [ -s temp_success.txt ]; then
    while read line; do
        echo "                <div class=\"log-entry success\">" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
        echo "                    $line" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
        echo "                </div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
    done < temp_success.txt
else
    echo "                <div class=\"no-data\">Aucune connexion réussie trouvée</div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"
fi

echo "            </div>" >> "$REPORT_FILE" 2>> "$ERROR_FILE"

# Fermer le HTML
cat >> "$REPORT_FILE" << 'EOF' 2>> "$ERROR_FILE"
        </div>
        
        <div class="footer">
            <p>Rapport généré automatiquement par le script d'analyse Apache</p>
            <p>Pour plus d'informations, consultez le fichier d'erreurs associé</p>
        </div>
    </div>
</body>
</html>
EOF

# Nettoyer les fichiers temporaires
rm -f temp_success.txt 2>> "$ERROR_FILE"

# Afficher le résultat
echo "Analyse des logs Apache terminée!"
echo "Rapport HTML généré: $REPORT_FILE"
echo "Erreurs redirigées vers: $ERROR_FILE"
echo ""
echo "Résumé rapide:"
echo "- Erreurs 4xx: $ERROR_4XX"
echo "- Erreurs 5xx: $ERROR_5XX"
echo "- 404 Not Found: $ERROR_404"
echo ""
echo "🌐 Ouvrez le fichier $REPORT_FILE dans votre navigateur pour voir le rapport complet!"