#!/bin/bash

BaseMariaDb=$1

echo "Sauvegarde de ${BaseMariaDb}"

PATH=$PATH:/home/docker/.local/bin:/usr/local/sbin:/usr/local/bin:/apps/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Verification presence container
echo "/usr/local/bin/docker ps --filter 'name=${BaseMariaDb}' --format \"{{.ID}}\""
echo "/usr/local/bin/docker ps --filter 'name=${BaseMariaDb}' --format \"{{.ID}}\"" > /tmp/cmd
chmod u+x /tmp/cmd
Test=$(/tmp/cmd)
echo "Resultat du test :$Test"

if [ ${Test} != "" ]
then
	echo "Container present"
	/usr/local/bin/docker exec -it ${Test} /bin/bash /usr/local/bin/backup.sh > /tmp/backup.log
	#	echo "/usr/local/bin/docker exec -it ${Test} /usr/local/bin/backup.sh"
	#	echo "/usr/local/bin/docker exec -it ${Test} /usr/local/bin/backup.sh" > /tmp/cmd
	#	chmod u+x /tmp/cmd
	#	/tmp/cmd
else
	echo "Container abscent !"
fi
