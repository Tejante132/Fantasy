#!/usr/bin/bash

FICHIER_URLS=$1
FICHIER_SORTIE=$2
if [ $# -ne 2 ]
then
	echo "Ce script demande 2 arguments : Le chemin du fichier d'urls et le chemin du fichier de sortie"
	exit
fi


### CREATION TABLEAU

echo -e "<html>
<head>
	<meta charset=\"UTF-8\">
	<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css\">
</head>
<body>
	<div class=\"content is-large\">
		<h1 class=\"title is-1 has-text-centered\">Projet pt : Résultats</h1>
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
			<th>Contextes</th>
			<th>Concordance</th>
			<th>Robots</th>
			<th>Bigrammes</th>
		</tr>" >> "$FICHIER_SORTIE"


NB_LIGNES=1

while read -r url;
do
	
	### ASPIRATIONS
	ASPIRATIONS=$(lynx -source ${url})
	echo -E "$ASPIRATIONS" >> "./aspirations/pt/aspiration$NB_LIGNES.txt"


	### CONTEXTES
	CONTEXTES=$(lynx -dump -nolist ${url} | grep -E -C3 -i "fantasias?")
	echo -E "$CONTEXTES" >> "./contextes/pt/contextes$NB_LIGNES.txt"
	

	### DUMPS
	DUMP=$(lynx -dump -nolist ${url})
	echo -E "$DUMP" >> "./dumps/pt/dump$NB_LIGNES.txt"
	

	### CODE_HTTP
	CODE_HTTP=$(curl -i -L ${url} | grep -E "^HTTP/(2|1|3) "*"" | tr -d "\r\n")
		if [ -z "${CODE_HTTP}" ]
		then
			CODE_HTTP="N/A"
		fi

	
	### ENCODAGE
	ENCODAGE=$(curl -i -L ${url} | grep -P -o 'charset\s*=\s*"?\K[^"\s>]+'| cut -d"=" -f2 | head -n 1 | tr -d "\"\'")
		if [ -z "${ENCODAGE}" ]
		then
			ENCODAGE="N/A"
		fi

	
	### N_MOTS
	N_MOTS=$(lynx -dump -nolist ${url} | grep -E -i "fantasias?" | wc -w)


	### ROBOTS
	LIEN_BASE=$(echo ${url} | cut -d"/" -f1,2,3 )
	COMPLEMENT=$(echo "$LIEN_BASE/robots.txt")
	ROBOTS=$(curl $COMPLEMENT)
	echo "$ROBOTS" >> "./robots/pt/robot$NB_LIGNES.txt"
	

	
	### BIGRAMMES
    cat "../dumps/pt/dump-$NB_LIGNES.txt" \
    | tr -cs '[:alpha:]' '\n' \
    | tr 'A-Z' 'a-z' \
    | paste -d' ' - - \
    | sort \
    | uniq -c \
    | sort -nr > "../bigrammes/pt/pt-bigrammes-$NB_LIGNES.txt"

    awk 'tolower($0) ~ /(^| )fantasia( |$)/' \
    "../bigrammes/pt/pt-bigrammes-$NB_LIGNES.txt" > "../bigrammes/pt/pt-bigrammes-fantasia-$NB_LIGNES.txt"

	### CONCORDANCE
	MAX_WORDS=15

	FICHIERS_CONTEXTES=$(cat ./contextes/pt/contextes$NB_LIGNES.txt | sed 's/^[[:space:]]\+//' |tr '\n' ' ' | sed -z 's/--/\n/g' |  sed 's/^[[:space:]]\+//')

	echo -e "<html>
	<head>
		<meta charset=\"UTF-8\">
		<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css\">
	</head>
	<body>
		<div class=\"content is-large\">
			<h1 class=\"title is-1 has-text-centered\">Concordancier</h1>
		</div>
		<table class = \"table is-bordered is-hoverable is-fullwidth\">
			<tr class=\"is-link\">
				<th>Contexte Gauche</th>
				<th>Pivot</th>
				<th>Contexte Droit</th>
			</tr>" > "./concordance/pt/concordancier$NB_LIGNES.html"
	
	while read -r line ; 
	do 

		SEPARATIONS=$(echo "$line" | sed -E 's/(.*)([fF]antasias?)(.*)/\1|\2|\3/')


		CONTEXTE_GAUCHE=$(echo "$SEPARATIONS" | cut -d"|" -f1 | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | tr ' ' '\n' | tail -n $MAX_WORDS | tr '\n' ' ' | sed 's/[[:space:]]\+$//')
		PIVOT=$(echo "$SEPARATIONS" | cut -d"|" -f2)
		CONTEXTE_DROIT=$(echo "$SEPARATIONS" | cut -d"|" -f3 | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | tr ' ' '\n' | head -n $MAX_WORDS | tr '\n' ' ' | sed 's/[[:space:]]\+$//')

		echo -e "       <tr>
					<td>$CONTEXTE_GAUCHE</td>
					<td>$PIVOT</td>
					<td>$CONTEXTE_DROIT</td>
			</tr>" >> "./concordance/pt/concordancier$NB_LIGNES.html"

	done <<< "$FICHIERS_CONTEXTES" 

	echo -e "   </table>
	</body>
	</html>" >> "./concordance/pt/concordancier$NB_LIGNES.html"

	### REMPLISSAGE
	echo -e "		<tr>
			<td>$NB_LIGNES</td>
			<td>${url}</td>
			<td>$CODE_HTTP</td>
			<td>$ENCODAGE</td>
			<td><a href=\"../aspirations/pt/aspiration$NB_LIGNES.txt\">voir aspiration</a></td>
			<td><a href=\"../dumps/pt/dump$NB_LIGNES.txt\">voir dump</a></td>
			<td>$N_MOTS</td>
			<td><a href=\"../contextes/pt/contextes$NB_LIGNES.txt\">voir contextes</a></td>
			<td><a href=\"../concordance/pt/concordancier$NB_LIGNES.html\">voir concordance</a></td>
			<td><a href=\"../robots/pt/robot$NB_LIGNES.txt\">voir robots.txt</a></td>
			<td><a href=\"../bigrammes/pt/pt-bigrammes-fantasia-$NB_LIGNES.txt\">voir bigrammes</a></td>
		</tr>" >> "$FICHIER_SORTIE";

	NB_LIGNES=$(expr $NB_LIGNES + 1);
done < "$FICHIER_URLS";


### FERMETURE HTML

echo -e "	</table>
</body>
</html>" >> "$FICHIER_SORTIE"


### GÉNÉRATION WORDCLOUD

source ~/venvs/plurital/bin/activate
cat ./dumps/pt/dump*.txt >> "./wordclouds/pt/all_dumps.txt"
wordcloud_cli --text ./wordclouds/pt/all_dumps.txt --stopwords ./wordclouds/pt/stopwords_pt.txt --mask ./wordclouds/pt/coq_de_barcelos.png --imagefile ./wordclouds/pt/wordcloud_pt.png
