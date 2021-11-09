#!/usr/bin/env bash

# Pour chaque département, produire une liste des personnels

# dépendances : GNU sed (à cause de l’option -z)
# Gnumeric pour l’export en ODS


if [ -d export ]; then
    rm -r export
fi

mkdir -p export/{CSV,ODS}

# -z permet que le délimiteur soit \0 et pas \n
sed -z -e 's/\"Par e-mail\nPar téléphone\"/Par e-mail et par téléphone/g' "${1}" |  tr -d '\"' > clean.csv

# Corps DiscPLP DiscCertif Dpt-affectation Dpt-vis academie-visee mailOUtel Nom Prénom mail tel

while read -r line ; do 
    
    (
        echo 'Prénom,Nom,Mail,Téléphone,Corps,Département d’affectation,Département visé,Académie visée,Discipline si LP,Discipline si certifié⋅e agrégé⋅e' > ./export/CSV/"${line}.csv"

        awk -F',' -v dpt="${line}" '$4==dpt {printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",$9,$8,$10,$11,$1,$4,$5,$6,$2,$3 }' clean.csv  >> ./export/CSV/"${line}.csv"
    ) &

done < departements
wait

(
cd export/CSV || exit
nom=""
    for i in *.csv ; do
        (
            nom="${i%.*}"
                       
            # Libreoffice 
            #unoconv -i FilterOptions=44,34,76 -f ods "$nom".csv
            
            # Gnumeric
            ssconvert "${i}" "$nom".ods
        ) &
    done
    wait
    

    mv ./*.ods ../ODS/
)

awk -F',' '{print $4}' clean.csv | tr -d '\"' | sort | uniq 
