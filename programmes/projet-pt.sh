#!/usr/bin/bash

FICHIER_URLS=$1
FICHIER_SORTIE=$2
if [ $# -ne 2 ]
then
	echo "Ce script demande 2 arguments : Le chemin du fichier d'urls et le chemin du fichier de sortie"
	exit
fi

NB_LIGNES=1
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
		</tr>" >> "$FICHIER_SORTIE"
NB_LIGNES=1

while read -r line;
do
	ASPIRATIONS=$(lynx -source ${line})
	echo -E "$ASPIRATIONS" >> "./aspirations/pt/aspiration$NB_LIGNES.txt"
	CONTEXTES=$(lynx -dump -nolist ${line} | grep -E -C3 -i "fantasias?")
	echo -E "$CONTEXTES" >> "./contextes/pt/contextes$NB_LIGNES.txt"
	DUMP=$(lynx -dump -nolist ${line})
	echo -E "$DUMP" >> "./dumps/pt/dump$NB_LIGNES.txt"
	CODE_HTTP=$(curl -i -L ${line} | grep -E "^HTTP/(2|1) "*"" | tr -d "\r\n")
		if [ -z "${CODE_HTTP}" ]
		then
			CODE_HTTP="N/A"
		fi
	ENCODAGE=$(curl -i -L ${line} | grep -P -o "charset=\"\S+\""| cut -d"=" -f2)
		if [ -z "${ENCODAGE}" ]
		then
			ENCODAGE="N/A"
		fi
	N_MOTS=$(lynx -dump -nolist ${line} | grep -E -i "fantasias?" | wc -w)
	echo -e "		<tr>
		<td>$NB_LIGNES</td>
		<td>${line}</td>
		<td>$CODE_HTTP</td>
		<td>$ENCODAGE</td>
		<td><a href=\"../aspirations/pt/aspiration$NB_LIGNES.txt\">voir aspiration</a></td>
		<td><a href=\"../dumps/pt/dump$NB_LIGNES.txt\">voir dump</a></td>
		<td>$N_MOTS</td>
		<td><a href=\"../contextes/pt/contextes$NB_LIGNES.txt\">voir contextes</a></td>
	</tr>" >> "$FICHIER_SORTIE";
	NB_LIGNES=$(expr $NB_LIGNES + 1);
done < "$FICHIER_URLS";

echo -e "	</table>
</body>
</html>" >> "$FICHIER_SORTIE"


