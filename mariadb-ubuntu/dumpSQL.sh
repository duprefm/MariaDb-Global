#!/bin/bash
## Parametre
USER=$1
PASS=$2
HOST=$3
RETENTION=7
#date du jour
DATE=`date +%A-%u-%B-%H-%M`
# Exclure des bases
EXCLUSIONS='(information_schema|performance_schema)'
# Rertoire de stockage des sauvegardes
DATADIR="/mnt/${HOST}/mysqldump"
mkdir -p ${DATADIR} 2>/dev/null

# On place dans un tableau le nom de toutes les bases de donnees du serveur
echo "/usr/bin/mysql -h ${HOST} -u ${USER} -p${PASS}"
databases="$(/usr/bin/mysql -h ${HOST} -u ${USER} -p${PASS} -Bse 'show databases' | grep -v -E ${EXCLUSIONS})"


#on boucle sur chaque base
for SQL in ${databases}
do
	#echo $SQL
	echo "/usr/bin/mysqldump -h ${HOST} -u ${USER} -p${PASS}"
	/usr/bin/mysqldump -h ${HOST} -u ${USER} -p${PASS} --quick --add-locks --lock-tables --extended-insert ${SQL} --skip-lock-tables > ${DATADIR}/${HOST}"_"${SQL}"_"${DATE}.sql
	#mysqldump -h $HOST -u $USER -p$PASS --all-databases --single-transaction > ${DATADIR}/$HOST"_"$DATE.sql
done

#echo "Suppression des vieux backup : "
find ${DATADIR} -name "*.sql" -mtime +${RETENTION} -print -exec rm -f {} \;
