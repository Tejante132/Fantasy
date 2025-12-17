#!/usr/bin/bash

CHEMIN_FICHIER=$1
CHEMIN_TABLEAU=$2
if [ $# -ne 2 ];
then
    echo " Donnez deux arguments !"
    exit
fi

if [ ! -f "$CHEMIN_FICHIER" ];
then
    echo "$CHEMIN_FICHIER Ce n'est pas un fichier!"
    exit
fi

> "$CHEMIN_TABLEAU"

echo "<html data-theme=\"dark\"><head><link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css\"></head><h3 class=\"title is-3 has-text-link-light\">Tableau avec informations sur les URLs</h3><table class=\"table is-primary has-border\" border=\"1px\"><tr><thead><!--On affiche un tabeau --><tr><th>Numéros de lignes</th><th>URLs</th><th>Réponses https</th><th>Nombre de mots</th><th>Encodage</th></tr></thead><tbody>" >> "$CHEMIN_TABLEAU"
nbr_lignes=0
while read -r LINE;
do
	if [[ $LINE =~ ^https?:// ]]
	then
nbr_lignes=$(expr $nbr_lignes + 1) #ATTENTION_mettre_espace_entre_s_+_1

INFOS_CURL=$(curl -i -L -o "tmp.txt" "$LINE" )
	 # echo -e "$INFOS_CURL\t$LINE" >> "$CHEMIN_TABLEAU" #affiche_tout_dans_la_lignedoncNON
HTTP_REP=$( cat "tmp.txt"| head -n 1 | tr -d '\r')
MOTS=0
MOTS=$(cat "tmp.txt" | lynx -nolist -dump -stdin | wc -w | tr -d '\r')

ENCODAGE=$( cat "tmp.txt" | head -n 10 | grep charset | cut -d "="  -f 2 | tr -d '\r')
echo "<tr><td>$nbr_lignes</td><td>$LINE</td><td>$HTTP_REP</td><td>$MOTS</td><td>$ENCODAGE</td></tr>" >> "$CHEMIN_TABLEAU"




	fi
done < "$CHEMIN_FICHIER";
echo "</tbody></table></td></body></html>" >>"$CHEMIN_FICHIER"
#ne_pas_oublier_de_bien_mettre_fichier.html_dans_la_console_sinon_evidement_çarenvoie_pas_ce_qu'il_faut
