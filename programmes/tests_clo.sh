#!/bin/bash

## Objectif : CONTEXTES

# Argument : dump donné (pour une URL)
# Renvoit : un fichier contenant les contextes d'apparition du mot Fantasie, séparés de tirets
# quelques lignes avant et après l'apparition du mot.

# style de nom de fichiers : dumps/de/de-1.txt

# donner un numéro (de 1 à 50)
FICHIER_DUMP=dumps/de/de-$1.txt

MOT=Fantasie

NB_MOTS=$(cat $FICHIER_DUMP | wc -w)
# NB_OCCURRENCES=$(cat $FICHIER_DUMP | grep -oP "$MOT" | wc -l)
LIGNES_MOT=$(cat $FICHIER_DUMP | grep -P "$MOT")
NB_OCCURRENCES=$(echo "$LIGNES_MOT" | wc -l)
CONTEXTES=$(cat $FICHIER_DUMP | grep -P --context=3 --color=always --group-separator="---" "$MOT")

echo "Nombre de mots du fichier : $NB_MOTS"
echo "Nombre d'apparitions du mot $MOT : $NB_OCCURRENCES"

echo -e "\n"
echo -e "Lignes avec $MOT : \n"
echo "$LIGNES_MOT"

echo -e "\n"
echo -e "contextes : \n"

echo "$CONTEXTES"