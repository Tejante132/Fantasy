#!/usr/bin/bash
FICHIER_URLS=$1
if [ $# -ne 1 ]
then
	echo "Ce script demande 1 argument : Le chemin du fichier d'urls"
	exit
fi

NB_LIGNES=1
while read -r line;
do
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
		</tr>" >> "../concordance/pt/concordancier$NB_LIGNES.html"
l
ynx -dump -nolist ${line} | grep -E -B2 -i "fantasias?" >> "./temp_concordance_gauche$NB_LIGNES.txt"
lynx -dump -nolist ${line} | grep -E -A2 -i "fantasias?" >> "./temp_concordance_droite$NB_LIGNES.txt"
lynx -dump -nolist ${line} | grep -E -i "fantasias?" >> "./temp_mot$NB_LIGNES.txt"
done




#Éléments concordance :
#lien vers le tableau : <td><a href=\"../concordance/pt/concordancier$NB_LIGNES.html\"></a></td>
#création du tableau : echo -e "<html>
	#<head>
		#<meta charset=\"UTF-8\">
		#<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css\">
	#</head>
	#<body>
		#<div class=\"content is-large\">
			#<h1 class=\"title is-1 has-text-centered\">Concordancier $NB_LIGNES</h1>
		#</div>
		#<table class = \"table is-bordered is-hoverable is-fullwidth\">
			#<tr class=\"is-link\">
				#<th>Contexte Gauche</th>
				#<th>Mot</th>
				#<th>Contexte Droit</th>
			#</tr>"
#récup cg : CONCORDANCE_GAUCHE=$(lynx -dump -nolist ${line} | grep -E -B2 -i "fantasias?")
#récup cd : CONCORDANCE_DROIT=$(lynx -dump -nolist ${line} | grep -E -A2 -i "fantasias?")
#récup mot : MOT=$(lynx -dump -nolist ${line} | grep -E -i "fantasias?")
#remplissage du tableau : echo -e "		<tr>
		#<td>$CONCORDANCE_GAUCHE</td>
		#<td>$MOT</td>
		#<td>$CONCORDANCE_DROIT</td>
	#</tr>" >> "./concordance/pt/concordancier$NB_LIGNES.html"
# finition du tableau : echo -e	"</table>
	#</body>
	#</html>" >> "./concordance/pt/concordancier$NB_LIGNES.html"

