#!/bin/bash

# Vérification qu'on a donné un argument
if [ $# -ne 1 ] # teste si nb d'argument différent de 1
then
	echo "Donner un paramètre (chemin vers fichier d'URLs)"
	exit 1 # fin de programme
fi

N=0 	# compteur d'URLs
URLS=$1

# on crée un fichier de sortie dans lequel on stockera les informations
fichier=tableaux/tableau-fr.html
touch ${fichier}

echo -e "
<html>
<head>
	<link
	rel='stylesheet'
	href='https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css'>
	<title>Tableau d'URLs</title>
	<meta charset='UTF-8' />
</head>"> ${fichier}

echo -e "
<body>
	<section class='section has-background-info is-fullheight'>
		<!-- Encart titre et logo côte à côte -->
		<br />
		<div class='columns is-vcentered'>
			<div class='column'>
				<h1 class='title is-1 is-1-desktop is-2-tablet is-6-mobile has-text-centered'><i>Fantasy</i></h1>
			</div>
			<div class='column'><h1 class='title is-1 is-1-desktop is-2-tablet is-6-mobile has-text-centered'>Projet de PPE</h1></div>
		</div>
		<br />

		<div class='container has-background-white'>
			<section class='section column'>
				<h3 class='title is-3 has-text-centered has-background-info-light'>Informations sur les sites webs</h3>
			</section>

			<div class='table-container'> 
			<table class='table is-hoverable is-fullwidth'>
				<thead><tr><th>N</th><th>URL</th><th>Statut HTTP</th><th>Encodage</th><th>Nb mots</th></tr></thead>" >> ${fichier}

while read -r line;
do
	N=$(expr $N + 1) # incrément
	STYLE_ENC="" && STYLE_HTTP="" && STYLE_NB="" #couleur de fond vide par défaut

	# Nouvelles lignes pour exo 2

	# On va récupérer les métadonnées en exécutant curl (line est une URL)
	METADONNEES=$(curl -L -s -I ${line} | tr -d '\r')

	# code de statut
# 	CODE_HTTP=$(echo "${METADONNEES}" | head -n 1 | awk '{print $2}') # lit la 1ère ligne
	CODE_HTTP=$(echo "${METADONNEES}" | head -n 1 | grep -oP " \K\d{3}")
	if [ -z "$CODE_HTTP" ]
	then
		CODE_HTTP="000"
		STYLE_HTTP="is-danger"
	fi

	# cas de code d'erreur 
	if [ $CODE_HTTP -gt 200 ]
	then
		STYLE_HTTP="is-danger"
	fi


	# encodage : on fait une regex
	ENCODING=$(echo "${METADONNEES}" | grep -i "content-type" | grep -oP "charset=\K[^; ]+")

	if [ -z "$ENCODING" ]
		# écrire truc à faire si pas d'encodate donné
	then
		ENCODING="N/A"
		STYLE_ENC="is-warning"
	fi

	NB_MOTS=$(lynx -dump -nolist ${line} | wc -w)

	if [ $NB_MOTS -eq 0 ]
	then
		STYLE_NB="is-warning"
	fi

	# on affiche les données extraites espacées par des tabulations
	echo -e "
				<tr>
					<td>${N}</td>
					<td><a href='${line}'>${line}</a></td>
					<td class='${STYLE_HTTP}'>${CODE_HTTP}</td>
					<td class='${STYLE_ENC}'>${ENCODING}</td>
					<td class='${STYLE_NB}'>${NB_MOTS}</td>
				</tr>" >> ${fichier}

done < ${URLS};

echo -e "
			</table></div>
		<br />
		</div>
	</section>
</body>
</html>" >> ${fichier}
