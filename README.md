# MariaDb
Docker Mariadb et Galera cluster

## Création du réseau comun aux bases et clusters.

docker network create --driver=overlay --attachable mariadb-network

## Récupération des sources.

git clone https://github.com/duprefm/MariaDb-Global.git

cd MariaDb-Global

## Construction de l'image mariadb.

cd mariadb-ubuntu

docker build -t fabricedupre/mariadb-ubuntu:latest .

docker push fabricedupre/mariadb-ubuntu:latest

## Construction de l'image mariadb-galera.

cd galera

docker build -t fabricedupre/mariadb-galera:latest .

docker push fabricedupre/mariadb-galera:latest

## Construction de l'image mariadb-galeracluster.

cd mariadb-galeracluster

docker build -t fabricedupre/mariadb-galeracluster:latest .

docker push fabricedupre/mariadb-galeracluster:latest

## Création d'un Cluster Mariadb Galera (Nginx).
### Lancement de la stack.

cd ../MariaDb

export PORT_MARIA=33064

export APP_NAME=GALERACLUSTER

cat nginx_template.conf | sed 's/template/GALERACLUSTER/g' > nginx_GALERACLUSTER.conf

cat TPL-docker-compose-standalone-mariadb.yml | sed 's/<PORT_MARIA>/33064/g' | sed 's/<APP_NAME>/G
ALERACLUSTER/g' > GALERACLUSTER-docker-compose-galera-mariadb.yml

docker stack deploy --compose-file GALERACLUSTER-docker-compose-galera-mariadb.yml $APP_NAME

## Création d'un Cluster Mariadb Galera.
### Lancement de la stack.

export PORT_MARIA=33066

export APP_NAME=GALERASWARM

cat TPL-docker-compose-galeracluster.yml | sed 's/<PORT_MARIA>/33066/g' | sed 's/<APP_NAME>/GALERA
SWARM/g' > GALERASWARM-docker-compose-galeracluster.yml

docker stack deploy --compose-file GALERASWARM-docker-compose-galeracluster.yml $APP_NAME

#### Swarm Visualizer.

docker service create --name=viz --publish=8080:8080/tcp --constraint=node.role==manager --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock dockersamples/visualizer

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

cat TPL-docker-compose-standalone-mariadb.yml | sed 's/<PORT_MARIA>/33062/g' | sed 's/<APP_NAME>/M
ARIADB/g' > MARIADB-docker-compose-standalone-mariadb.yml

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

* Création du volume commun

docker volume create VolumeMysqldump

## Lancement d'un container pilotant les sauvegardes.
docker run -d -e MYSQL_RANDOM_ROOT_PASSWORD=yes -v VolumeMysqldump:/mnt --name MariaDb_Backups --network mariadb-network fabricedupre/mariadb-ubuntu:latest

## Lancement Sauvegardes Standalone
docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/svgxtrabackup.sh root rootpass MARIADB_db

docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/dumpSQL.sh root rootpass MARIADB_db

## Lancement Sauvegardes Cluster
docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/svgxtrabackup.sh root rootpass GALERACLUSTER_lb

docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/dumpSQL.sh root rootpass GALERACLUSTER_lb

## Vérification Sauvegardes Standalone

docker exec -it MariaDb_Backups ls -rtl /mnt/MARIADB_db/mysqldump

## Vérification Sauvegardes Cluster

docker exec -it MariaDb_Backups ls -rtl /mnt/GALERACLUSTER_lb/mysqldump
