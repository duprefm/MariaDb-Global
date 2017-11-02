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
DATADIR="/mnt/${HOST}/backups/${DATE}/"
mkdir -p ${DATADIR} 2>/dev/null

# Creating a backup
echo "/usr/bin/xtrabackup -H ${HOST} -u ${USER} -p${PASS} --backup --target-dir=${DATADIR}"
/usr/bin/xtrabackup -H ${HOST} -u ${USER} -p${PASS} --backup --target-dir=${DATADIR}

# Preparing a backup
echo "/usr/bin/xtrabackup -H ${HOST} -u ${USER} -p${PASS} --prepare --target-dir=${DATADIR}"
/usr/bin/xtrabackup -H ${HOST} -u ${USER} -p${PASS} --prepare --target-dir=${DATADIR}

#echo "Suppression des vieux backup : "
find /mnt/${HOST}/backups -name "*" -mtime +${RETENTION} -print -exec rm -f {} \;
