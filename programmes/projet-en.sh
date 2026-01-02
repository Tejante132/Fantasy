#!/usr/bin/bash

CHEMIN_FICHIER=$1
CHEMIN_TABLEAU=$2
if [ $# -ne 2 ]
then
    echo "Donnez deux arguments !"
    exit
fi
if [ ! -f "$CHEMIN_FICHIER" ] ;
then
    echo "$CHEMIN_FICHIER Ce n'est pas un fichier!"
    exit
fi

mkdir -p "../aspirations/en" "../contextes/en" "../dumps/en"


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
        </tr>" >> "$CHEMIN_TABLEAU"

nbr_lignes=1
while read -r LINE;
do
    if [[ $LINE =~ ^https?:// ]]; then


    ASPIRATIONS=$(lynx -source "$LINE" 2>/dev/null) #attention_à_bien_mettre_un_espace_devant_le_2
    echo -E "$ASPIRATIONS" >> "../aspirations/en/en-aspiration-$nbr_lignes.txt"
    CONTEXTES=$(lynx -dump -nolist "$LINE" 2>/dev/null | grep -E -C3 -i "fantasy")
    echo -E "$CONTEXTES" >> "../contextes/en/en-contextes-$nbr_lignes.txt"
    DUMP=$(lynx -dump -nolist "$LINE" 2>/dev/null)
    echo -E "$DUMP" >> "../dumps/en/en-dump-$nbr_lignes.txt"

    INFOS_CURL=$(curl -i -L -s "$LINE")
    HTTP_REP=$(echo "$INFOS_CURL" | head -n 1 | tr -d '\r')

	if [ -z "$HTTP_REP" ];then
	HTTP_REP="N/A";#si c'est vide
	fi

	MOTS=$(echo "$ASPIRATIONS" | wc -w)

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
    </tr>" >> "$CHEMIN_TABLEAU"
	fi
    nbr_lignes=$((nbr_lignes + 1))

done < "$CHEMIN_FICHIER"


echo -e "    </table>
</body>
</html>" >> "$CHEMIN_TABLEAU"

