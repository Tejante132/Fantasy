#!/bin/bash

# Vérification qu'on a donné un argument
if [ $# -ne 1 ] # teste si nb d'argument différent de 1
then
	echo "Donner le paramètre: langue (en/pt/de) en minuscules"
	exit 1 # fin de programme
fi

N=0 	# compteur d'URLs
LG=$1
URLS=urls/${LG}.txt
# URLS=$1

echo "langue choisie : $LG"

if [ "$LG" = "en" ]; then
	MOT=fantasy
elif [ "$LG" = "pt" ]; then
	MOT=fantasia
elif [ "$LG" = "de" ]; then
	MOT=Fantasie
else
	echo "Donner le paramètre: langue PARMI CES CODES (en/pt/de) en minuscules"
	exit 1 # fin de programme
fi

echo "Mot étudié : $MOT"

# on crée un fichier de sortie dans lequel on stockera les informations
fichier=tableaux/tableau-${LG}.html
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
				<thead><tr><th>N</th><th>URL</th><th>Statut HTTP</th><th>Encodage</th><th>Nb mots</th><th>Aspiration</th><th>Dump</th><th>Compte</th><th>Contexte</th><th>Concordancier</th></tr></thead>" >> ${fichier}

while read -r URL;
do
	N=$(expr $N + 1) # incrément
	STYLE_ENC="" && STYLE_HTTP="" && STYLE_NB="" #couleur de fond vide par défaut

	echo "ligne numéro $N"
	echo "lecture de $URL"

	# Nouvelles lignes pour exo 2

	# On va récupérer les métadonnées en exécutant curl
	METADONNEES=$(curl -L -s -I URL | tr -d '\r')

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

	FICHIER_ASPIRATION=aspirations/${LG}/${LG}-${N}.txt
	curl -s ${URL} > $FICHIER_ASPIRATION

	FICHIER_DUMP=dumps/${LG}/${LG}-${N}.txt
	lynx -dump -nolist ${URL} > $FICHIER_DUMP

	NB_MOTS=$(cat $FICHIER_DUMP | wc -w)
	NB_OCCURRENCES=$(cat $FICHIER_DUMP | grep -oP "$MOT" | wc -l)

	if [ $NB_MOTS -eq 0 ]
	then
		STYLE_NB="is-warning"
	fi

	# attention, ça ne crée pas les chemins, il faut eventuellement faire un mkdir des dossiers 
	# s'ils n'existent pas déjà au moment où on lance le programme
	FICHIER_CONTEXTES=contextes/${LG}/${LG}-${N}.html
	CONTEXTES=$(cat $FICHIER_DUMP | grep -P --context=3 --color=always --group-separator="---" "$MOT")
	# echo "$CONTEXTES" > $FICHIER_CONTEXTES
	echo "$CONTEXTES" | aha --title "Contextes pour $MOT" > $FICHIER_CONTEXTES

	# on affiche les données extraites espacées par des tabulations
	echo -e "
				<tr>
					<td>${N}</td>
					<td><a href='${URL}'>${URL}</a></td>
					<td class='${STYLE_HTTP}'>${CODE_HTTP}</td>
					<td class='${STYLE_ENC}'>${ENCODING}</td>
					<td class='${STYLE_NB}'>${NB_MOTS}</td>
					<td><a href='../${FICHIER_ASPIRATION}'>lien vers l'aspiration</a></td>
					<td><a href='../${FICHIER_DUMP}'>lien vers le dump</a></td>
					<td class='${STYLE_NB}'>${NB_OCCURRENCES}</td>
					<td><a href='../${FICHIER_CONTEXTES}'>lien vers les contextes</a></td>
				</tr>" >> ${fichier}

done < ${URLS};

echo -e "
			</table></div>
		<br />
		</div>
	</section>
</body>
</html>" >> ${fichier}
