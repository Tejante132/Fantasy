#!/bin/bash

## Objectif : CONTEXTES

# Argument : dump donné (pour une URL)
# Renvoit : un fichier contenant les contextes d'apparition du mot Fantasie, séparés de tirets
# quelques lignes avant et après l'apparition du mot.

# style de nom de fichiers : dumps/de/de-1.txt

# donner un numéro (de 1 à 50)
FICHIER_DUMP=dumps/de/de-$1.txt

MOT=Fantasie

## CONTEXTES


# NB_MOTS=$(cat $FICHIER_DUMP | wc -w)
# # NB_OCCURRENCES=$(cat $FICHIER_DUMP | grep -oP "$MOT" | wc -l)
# LIGNES_MOT=$(cat $FICHIER_DUMP | grep -P "$MOT")
# NB_OCCURRENCES=$(echo "$LIGNES_MOT" | wc -l)
# CONTEXTES=$(cat $FICHIER_DUMP | grep -P --context=3 --color=always --group-separator="---" "$MOT")

# echo "Nombre de mots du fichier : $NB_MOTS"
# echo "Nombre d'apparitions du mot $MOT : $NB_OCCURRENCES"

# echo -e "\n"
# echo -e "Lignes avec $MOT : \n"
# echo "$LIGNES_MOT"

# echo -e "\n"
# echo -e "contextes : \n"

# echo "$CONTEXTES"






## ESSAIS BIGRAMMES

# BIGRAMMES=$(cat "$FICHIER_DUMP" | tr -cs '[:alpha:]' '\n' | tr 'A-Z' 'a-z' \
# | paste -d' ' - - \
# | sort \
# | uniq -c \
# | sort -nr) # tous les bigrammes


# echo "$BIGRAMMES"
# awk 'tolower($0) ~ /(^| )fantasy( |$)/' \
# "../bigrammes/en/en-bigrammes-$nbr_lignes.txt" \
# > "../bigrammes/en/en-bigrammes-fantasy-$nbr_lignes.txt"
# # > "../bigrammes/en/en-bigrammes-$nbr_lignes.txt"




## CONCORDANCIER


FICHIER_CONCORDANCIER="concordancier/de/de-$1.html"

# echo "<html><head><meta charset='UTF-8'>
# <title>Concordancier ligne $nbr_lignes</title></head><body>
# <h2>Concordancier – occurrences de « fantasy »</h2>
# <table border='1'>
# <tr><th>Contexte gauche</th><th>Mot</th><th>Contexte droit</th></tr>" \
# > "$FICHIER_CONCORDANCIER"

FICHIER_CONTEXTES="contextes/de/de-$1.txt"
# cat "$FICHIER_CONTEXTES"

# Tokenise le fichier : un mot par ligne, avec une ligne vide entre les phrases
# Gère les diacrités et conserve la ponctuation attachée aux mots (ex: "canapé," devient "canapé" sur une ligne et "," sur une autre)
# Utilise LC_ALL pour gérer correctement les caractères UTF-8
# export LC_ALL=fr_FR.UTF-8

# Tokenisation : un mot par ligne, avec une ligne vide entre les phrases
# 1. Remplace les ponctuations de fin de phrase par un saut de ligne
# 2. Remplace les espaces/tabs par des sauts de ligne
# 3. Nettoie les lignes vides inutiles
# 4. Ajoute une ligne vide après chaque ponctuation de fin de phrase

# TOKENS=$(sed -e 's/\([.!?;sed]\)/\1\n/g' "$FICHIER_CONTEXTES" \
#   | sed -e 's/\([[:alpha:][:blank:]\'\''àâäãåçéèêëíîïñóôöõúûüýÿæœÀÂÄÃÅÇÉÈÊËÍÎÏÑÓÔÖÕÚÛÜÝŸÆŒß-]\+\)/\1\n/g' \
#   | tr -s '[:space:]' '\n' \
#   | grep -v '^$' \
#   | sed -e '/^[.!?;]$/a\'
# )


TOKENS=$(cat "$FICHIER_CONTEXTES" | tr -cs '[:alpha:]àâäãåçéèêëíîïñóôöõúûüýÿæœÀÂÄÃÅÇÉÈÊËÍÎÏÑÓÔÖÕÚÛÜÝŸÆŒß-]' '\n')
# | tr 'A-Z' 'a-z') # tous les bigrammes



echo "$TOKENS"

# 'àâäãåçéèêëíîïñóôöõúûüýÿæœÀÂÄÃÅÇÉÈÊËÍÎÏÑÓÔÖÕÚÛÜÝŸÆŒß]+'


# cat "../dumps/en/en-dump-$nbr_lignes.txt" \
# | tr -cs '[:alpha:]' '\n' \
# | tr 'A-Z' 'a-z' \
# | awk '
# {
#     mots[NR] = $0
# }
# END {
#     for (i = 1; i <= NR; i++) {
#         if (mots[i] == "${MOT}") {
#             gauche=""
#             droite=""
#             for (j = i-5; j < i; j++)
#                 if (j > 0) gauche = gauche " " mots[j]
#             for (j = i+1; j <= i+5 && j <= NR; j++)
#                 droite = droite " " mots[j]
#             print "<tr><td>" gauche "</td><td><b>${MOT}</b></td><td>" droite "</td></tr>"
#         }
#     }
# }' >> "$FICHIER_CONCORDANCIER"





# $CONTEXTE_GAUCHE=$(grep --before-context=1)
# echo "$CONTEXTE_GAUCHE"


# echo -e "
# <html>
# <head>
# 	<link
# 	rel='stylesheet'
# 	href='https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css'>
# 	<title>Tableau d'URLs</title>
# 	<meta charset='UTF-8' />
# </head>
# <body>
# 	<section class='section has-background-info is-fullheight'>
# 		<!-- Encart titre et logo côte à côte -->
# 		<br />
# 		<div class='columns is-vcentered'>
# 			<div class='column'>
# 				<h1 class='title is-1 is-1-desktop is-2-tablet is-6-mobile has-text-centered'><i>Fantasy</i></h1>
# 			</div>
# 			<div class='column'><h1 class='title is-1 is-1-desktop is-2-tablet is-6-mobile has-text-centered'>Projet de PPE</h1></div>
# 		</div>
# 		<br />

# 		<div class='container has-background-white'>
# 			<section class='section column'>
# 				<h3 class='title is-3 has-text-centered has-background-info-light'>Concordancier de ${MOT}</h3>
# 			</section>

# 			<div class='table-container'> 
# 			<table class='table is-hoverable is-fullwidth'>
# 				<thead><tr><th>Contexte gauche</th><th>Mot</th><th>Contexte droit</th></tr></thead>" >> ${FICHIER_CONCORDANCIER}

# echo -e "
#                 <tr>
#                     <td>${CONTEXTE_GAUCHE}</td>
#                     <td>${MOT}</td>
#                     <td>${CONTEXTE_DROIT}</td>
#                 </tr>" >> ${fichier}

# echo -e "
# 			</table></div>
# 		<br />
# 		</div>
# 	</section>
# </body>
# </html>" >> ${FICHIER_CONCORDANCIER}