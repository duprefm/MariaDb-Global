# MariaDb
Docker Mariadb et Galera cluster

## Création du réseau comun aux bases et clusters.

docker network create --driver=overlay --attachable mariadb-network

## Récupération des sources.

git clone https://github.com/duprefm/MariaDb-Global.git

## Construction de l'image mariadb.

cd mariadb-ubuntu

docker build -t fabricedupre/mariadb-ubuntu:latest .

docker push fabricedupre/mariadb-ubuntu:latest

## Construction de l'image mariadb-galera.

cd galera

docker build -t fabricedupre/mariadb-galera:latest .

docker push fabricedupre/mariadb-galera:latest

## Construction de l'image mariadb-galeracluster.

cd galera

docker build -t fabricedupre/mariadb-galeracluster:latest .

docker push fabricedupre/mariadb-galeracluster:latest

## Création d'un Cluster Mariadb Galera (Nginx).
### Lancement de la stack.

cd MariaDb

export PORT_MARIA=33064

export APP_NAME=GALERACLUSTER

cat nginx_template.conf | sed 's/template/GALERACLUSTER/g' > nginx_GALERACLUSTER.conf

docker stack deploy --compose-file docker-compose-galera-mariadb.yml $APP_NAME

## Création d'un Cluster Mariadb Galera.
### Lancement de la stack.

export PORT_MARIA=33066

export APP_NAME=GALERACLUSTER

docker network create --driver=overlay --attachable $APP_NAME-network

docker stack deploy --compose-file docker-compose-galeracluster.yml $APP_NAME

### Commandes sql de vérification de l'état du cluster galera.

SHOW GLOBAL STATUS LIKE 'wsrep_cluster_size'

SHOW GLOBAL STATUS LIKE 'wsrep_local_state_comment'

SHOW GLOBAL STATUS LIKE 'wsrep_cluster_status'

SHOW GLOBAL STATUS LIKE 'wsrep_local_state_comment'

SHOW STATUS LIKE 'wsrep_last_committed';

SHOW GLOBAL STATUS LIKE 'wsrep_%';

## Lancement d'une base Mariadb Sandalone.
### Lancement de la stack.

export PORT_MARIA=33062

export APP_NAME=MARIADB

docker stack deploy --compose-file MARIADB-docker-compose-standalone-mariadb.yml $APP_NAME

## Console admin

docker run --name myadmin --network=mariadb-network --name myadmin --hostname myadmin -d -e PMA_HOSTS=GALERACLUSTER_lb,MARIADB_db, -p 8000:80 phpmyadmin/phpmyadmin

## Script perl de chagement de données

### Commande de création de la table reçevant les données.

CREATE database test;

USE test;

CREATE TABLE data ( id INTEGER NOT NULL AUTO_INCREMENT, value CHAR(30), count INTEGER, PRIMARY KEY (value), KEY (id) );

### Chargemenr des donées.

cd ..

* Cluster.

docker run -it --rm --name my-running-script --network=mariadb-network -v "$PWD":/usr/src/myapp -w /usr/src/myapp fabricedupre/perl:dbi perl query-lb.pl

* Standalone.

docker run -it --rm --name my-running-script --network=mariadb-network -v "$PWD":/usr/src/myapp -w /usr/src/myapp fabricedupre/perl:dbi perl query-single.pl

## Sauvegardes

### Mysqldump
Création du volume commun :

docker volume create VolumeMysqldump

* Cluster.

docker run -d --network=mariadb-network -v VolumeMysqldump:/mnt fabricedupre/mariadb sh -c 'exec /usr/local/bin/dumpSQL.sh root k3O2Iyd89cnqV0IQx7qV AppGalera_node1'

* Single instance.

docker run -d --network=mariadb-network -v VolumeMysqldump:/mnt fabricedupre/mariadb sh -c 'exec /usr/local/bin/dumpSQL.sh root k3O2Iyd89cnqV0IQx7qV firstDBapp_db'

* Vérifier le contenu du volume contenant les dumps.

docker run --network=mariadb-network -v VolumeMysqldump:/mnt ubuntu ls -rtl /mnt/mysqldump

### XtraBackup

* Cluster.

docker run -d --network=mariadb-network -v VolumeMysqldump:/mnt fabricedupre/mariadb sh -c 'exec /usr/local/bin/svgxtrabackup.sh root k3O2Iyd89cnqV0IQx7qV AppGalera_node1'

* Single instance.

docker run -d --network=mariadb-network -v VolumeMysqldump:/mnt fabricedupre/mariadb sh -c 'exec /usr/local/bin/svgxtrabackup.sh root k3O2Iyd89cnqV0IQx7qV firstDBapp_db'

### Chagement de données grace un un script perl

* Création d'une table.

CREATE DATABASE test;
USE test;
CREATE TABLE data ( id INTEGER NOT NULL AUTO_INCREMENT, value CHAR(30), count INTEGER, PRIMARY KEY (value), KEY (id) );

* Lancement d'un container d'injection de données.

docker run -it --rm --name my-running-script --network=mariadb-network -v "$PWD":/usr/src/myapp -w /usr/src/myapp fabricedupre/perl:dbi perl querry1.pl

## Arrêt/Relance d'une stack.

### Galera.

* Arrêt de la stack.

export APP_NAME=GALERACLUSTER

docker stack rm $APP_NAME


* Modification du fichier grastate.dat

Le fait de passer de 0 a 1 la variable **safe_to_bootstrap**, permet au cluster de redémarrer avec le node1 comme master.

docker run -v GALERACLUSTER_Volumenode1VarLibMysql:/var/lib/mysql ubuntu sed -i 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/g' /var/lib/mysql/grastate.dat

* Vérification du contenu du fichier **grastate.dat**.

docker run -v GALERACLUSTER_Volumenode1VarLibMysql:/var/lib/mysql ubuntu cat
 /var/lib/mysql/grastate.dat

* Redémarrage de la pile.

export PORT_MARIA=33064

export APP_NAME=GALERACLUSTER

docker stack deploy --compose-file GALERACLUSTER-docker-compose-galera-mariadb.yml $APP_NAME

### Sandalone

* Arrêt de la stack.

docker stack rm MARIADB

* Redémarrage de la pile.

export PORT_MARIA=33062

docker stack deploy --compose-file MARIADB-docker-compose-standalone-mariadb.yml MARIADB


# Sauvegardes
## Lancement d'un container pilotant les sauvegardes.
docker run -d -e MYSQL_RANDOM_ROOT_PASSWORD=yes -v MariaDb_VolumeDBsvg:/mnt --name MariaDb_Backups --network mariadb-network fabricedupre/mariadb-ubuntu:latest


## Lancement Sauvegardes Standalone
docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/svgxtrabackup.sh root rootpass MariaDb_db

docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/dumpSQL.sh root rootpass MariaDb_db

## Vérification Sauvegardes Standalone

## Lancement Sauvegardes Cluster
docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/svgxtrabackup.sh root rootpass MariaDbGalera_dbdbcluster

docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/dumpSQL.sh root rootpass MariaDbGalera_dbcluster

## Vérification Sauvegardes Standalone
