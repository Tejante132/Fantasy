#!/usr/bin/bash

FICHIER_URLS=$1
FICHIER_SORTIE=$2
if [ $# -ne 2 ]
then
	echo "Ce script demande 2 arguments : Le chemin du fichier d'urls et le chemin du fichier de sortie"
	exit
fi

### CREATION TABLEAU ###

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

while read -r line;
do

	### ASPIRATIONS ###
	ASPIRATIONS=$(lynx -source ${line})
	echo -E "$ASPIRATIONS" >> "./aspirations/pt/aspiration$NB_LIGNES.txt"

	### CONTEXTES ###
	CONTEXTES=$(lynx -dump -nolist ${line} | grep -E -C3 -i "fantasias?")
	echo -E "$CONTEXTES" >> "./contextes/pt/contextes$NB_LIGNES.txt"

	### DUMPS ###
	DUMP=$(lynx -dump -nolist ${line})
	echo -E "$DUMP" >> "./dumps/pt/dump$NB_LIGNES.txt"

	### CODE_HTTP ###
	CODE_HTTP=$(curl -i -L ${line} | grep -E "^HTTP/(2|1|3) "*"" | tr -d "\r\n")
		if [ -z "${CODE_HTTP}" ]
		then
			CODE_HTTP="N/A"
		fi

	### ENCODAGE ###
	ENCODAGE=$(curl -i -L ${line} | grep -P -o 'charset\s*=\s*"?\K[^"\s>]+'| cut -d"=" -f2 | head -n 1 | tr -d "\"\'")
		if [ -z "${ENCODAGE}" ]
		then
			ENCODAGE="N/A"
		fi

	### N_MOTS ###
	N_MOTS=$(lynx -dump -nolist ${line} | grep -E -i "fantasias?" | wc -w)

	### ROBOTS ###
	LIEN_BASE=$(echo ${line} | cut -d"/" -f1,2,3 )
	COMPLEMENT=$(echo "$LIEN_BASE/robots.txt")
	ROBOTS=$(curl $COMPLEMENT)
	echo "$ROBOTS" >> "./robots/pt/robot$NB_LIGNES.txt"

	### REMPLISSAGE ###
	echo -e "		<tr>
			<td>$NB_LIGNES</td>
			<td>${line}</td>
			<td>$CODE_HTTP</td>
			<td>$ENCODAGE</td>
			<td><a href=\"../aspirations/pt/aspiration$NB_LIGNES.txt\">voir aspiration</a></td>
			<td><a href=\"../dumps/pt/dump$NB_LIGNES.txt\">voir dump</a></td>
			<td>$N_MOTS</td>
			<td><a href=\"../contextes/pt/contextes$NB_LIGNES.txt\">voir contextes</a></td>
			<td><a href=\"../concordance/pt/concordancier$NB_LIGNES.html\">voir concordance</a></td>
			<td><a href=\"../robots/pt/robot$NB_LIGNES.txt\">voir robots.txt</a></td>
		</tr>" >> "$FICHIER_SORTIE";
	NB_LIGNES=$(expr $NB_LIGNES + 1);
done < "$FICHIER_URLS";


### FERMETURE HTML ###

echo -e "	</table>
</body>
</html>" >> "$FICHIER_SORTIE"

### GÉNÉRATION WORDCLOUD ###

cat ./dumps/pt/dump*.txt >> "./wordclouds/pt/all_dumps.txt"
wordcloud_cli --text ./wordclouds/pt/all_dumps.txt --stopwords ./wordclouds/pt/stopwords_pt.txt --mask ./wordclouds/pt/coq_de_barcelos.png --imagefile ./wordclouds/pt/wordcloud_pt.png --relative_scaling
