#!/usr/bin/bash

CHEMIN_FICHIER=$1
CHEMIN_TABLEAU=$2
if [ $# -ne 2 ]
then
    echo "Donnez deux arguments !"
    exit
fi
if [ ! -f "$CHEMIN_FICHIER" ]; #attention_espace_crochet
then
    echo "$CHEMIN_FICHIER Ce n'est pas un fichier!"
    exit
fi

mkdir -p "../aspirations/en" "../contextes/en" "../dumps/en" "../concordancier/en" "../bigrammes/en" "../robots/en" "../wordclouds/en"


echo -e "<html>
<head>
    <meta charset=\"UTF-8\">
    <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css\">
</head>
<body>
    <div class=\"content is-large\">
        <h1 class=\"title is-1 has-text-centered\">Projet version anglaise : Résultats</h1>
    </div>
    <table class = \"table is-bordered is-hoverable is-fullwidth\">
        <tr class=\"is-link\">
            <th>Ligne</th>
            <th>Adresse</th>
            <th>Réponse</th>
            <th>Encodage</th>
            <th>Aspiration</th>
            <th>Dump</th>
            <th>Compte</th>
            <th>Contexte</th>
            <th>Bigrammes</th>
            <th>Concordancier</th>
            <th>Robots.txt</th>

        </tr>" >> "$CHEMIN_TABLEAU"

nbr_lignes=1 #commence_à_1_sinon_nom_du_1erfichier_est_zéro
while read -r LINE;
do
    if [[ "$LINE" =~ ^https?:// ]]; then #attention_espace_crochet
    LIEN_BASE=$(echo "$LINE" | cut -d"/" -f1,2,3)
    curl -s "$LIEN_BASE/robots.txt" \
        > "../robots/en/robot$nbr_lignes.txt"
    else
    echo "URL invalide : $LINE" >&2
    fi

    #aspiration
    #ASPIRATIONS=$(lynx -source "$LINE" 2>/dev/null) #attention_à_bien_mettre_un_espace_devant_le_2
    #echo -E "$ASPIRATIONS" >> "../aspirations/en/en-aspiration-$nbr_lignes.txt"
    lynx -source "$LINE" 2>/dev/null >> "../aspirations/en/en-aspiration-$nbr_lignes.txt"

    #Contexte
    CONTEXTES=$(lynx -dump -nolist "$LINE" 2>/dev/null | grep -E -C3 -i "fantasy")
    echo -E "$CONTEXTES" >> "../contextes/en/en-contextes-$nbr_lignes.txt"

    #Dump
    #DUMP=$(lynx -dump -nolist "$LINE" 2>/dev/null)
    #echo -E "$DUMP" >> "../dumps/en/en-dump-$nbr_lignes.txt"
    lynx -dump -nolist "$LINE" 2>/dev/null >> "../dumps/en/en-dump-$nbr_lignes.txt"


    #Bigrammes
    cat "../dumps/en/en-dump-$nbr_lignes.txt" \
    | tr -cs '[:alpha:]' '\n' \
    | tr 'A-Z' 'a-z' \
    | paste -d' ' - - \
    | sort \
    | uniq -c \
    | sort -nr \
    > "../bigrammes/en/en-bigrammes-$nbr_lignes.txt"

    awk 'tolower($0) ~ /(^| )fantasy( |$)/' \
    "../bigrammes/en/en-bigrammes-$nbr_lignes.txt" \
    > "../bigrammes/en/en-bigrammes-fantasy-$nbr_lignes.txt"

    #Concordancier
    CONCORDANCIER="../concordancier/en/en-concordancier-$nbr_lignes.html"

    echo "<html><head><meta charset='UTF-8'>
    <title>Concordancier ligne $nbr_lignes</title></head><body>
    <h2>Concordancier – occurrences de « fantasy »</h2>
    <table border='1'>
    <tr><th>Contexte gauche</th><th>Mot</th><th>Contexte droit</th></tr>" \
    > "$CONCORDANCIER"

    cat "../dumps/en/en-dump-$nbr_lignes.txt" \
    | tr -cs '[:alpha:]' '\n' \
    | tr 'A-Z' 'a-z' \
    | awk '
    {
        mots[NR] = $0
    }
    END {
        for (i = 1; i <= NR; i++) {
            if (mots[i] == "fantasy") {
                gauche=""
                droite=""
                for (j = i-5; j < i; j++)
                    if (j > 0) gauche = gauche " " mots[j]
                for (j = i+1; j <= i+5 && j <= NR; j++)
                    droite = droite " " mots[j]
                print "<tr><td>" gauche "</td><td><b>fantasy</b></td><td>" droite "</td></tr>"
            }
        }
    }' >> "$CONCORDANCIER"

    echo "</table></body></html>" >> "$CONCORDANCIER"


    #Infos curl
    INFOS_CURL=$(curl -i -L -s "$LINE")
    HTTP_REP=$(echo "$INFOS_CURL" | head -n 1 | tr -d '\r')

	if [ -z "$HTTP_REP" ];then
	HTTP_REP="N/A";#si c'est vide
	fi

    #compte des mots
	MOTS=$(wc -w < "../aspirations/en/en-aspiration-$nbr_lignes.txt")


    ENCODAGE=$(echo "$INFOS_CURL" | grep -i "content-type:" | grep -i charset | cut -d "=" -f 2 | tr -d '\r')
    if [ -z "$ENCODAGE" ]; then #si vide
		ENCODAGE="N/A"
    fi



    echo -e "        <tr>
        <td>$nbr_lignes</td>
        <td>${LINE}</td>
        <td>$HTTP_REP</td>
        <td>$ENCODAGE</td>
        <td><a href=\"../aspirations/en/en-aspiration-$nbr_lignes.txt\">voir aspiration</a></td>
        <td><a href=\"../dumps/en/en-dump-$nbr_lignes.txt\">voir dump</a></td>
        <td>$MOTS</td>
        <td><a href=\"../contextes/en/en-contextes-$nbr_lignes.txt\">voir contextes</a></td>
        <td><a href=\"../bigrammes/en/en-bigrammes-fantasy-$nbr_lignes.txt\">voir bigrammes</a></td>
        <td><a href=\"../concordancier/en/en-concordancier-$nbr_lignes.html\">voir concordancier</a></td>
        <td><a href=\"../robots/en/robot$nbr_lignes.txt\">voir robots.txt</a></td>
    </tr>" >> "$CHEMIN_TABLEAU"

    nbr_lignes=$((nbr_lignes + 1))

done < "$CHEMIN_FICHIER"


echo -e "    </table>
</body>
</html>" >> "$CHEMIN_TABLEAU"

