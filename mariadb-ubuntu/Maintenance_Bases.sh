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
	echo "/usr/bin/mysqlcheck --analyze --databases ${databases} -u root -p${PASS}"
	/usr/bin/mysqlcheck --analyze --databases ${databases} -u root -p${PASS}
	echo "/usr/bin/mysqlcheck --check --auto-repair --databases ${databases} -u root -p${PASS}"
        /usr/bin/mysqlcheck --check --auto-repair --databases ${databases} -u root -p${PASS}
	echo "/usr/bin/mysqlcheck --optimize --databases ${databases} -u root -p${PASS}"
        /usr/bin/mysqlcheck --optimize --databases ${databases} -u root -p${PASS}
done
