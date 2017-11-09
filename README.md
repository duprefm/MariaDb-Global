# MariaDb
Docker Mariadb et Galera cluster

## Création du réseau comun aux bases et clusters.

`docker network create --driver=overlay --attachable mariadb-network`

## Récupération des sources.

`git clone https://github.com/duprefm/MariaDb-Global.git`

`cd MariaDb-Global`

## Construction de l'image mariadb.

`cd mariadb-ubuntu`

`docker build -t fabricedupre/mariadb-ubuntu:latest .`

`docker push fabricedupre/mariadb-ubuntu:latest`

## Construction de l'image mariadb-galera.

`cd galera`

`docker build -t fabricedupre/mariadb-galera:latest .`

`docker push fabricedupre/mariadb-galera:latest`

## Construction de l'image mariadb-galeracluster.

`cd mariadb-galeracluster`

`docker build -t fabricedupre/mariadb-galeracluster:latest .`

`docker push fabricedupre/mariadb-galeracluster:latest`

## Création d'un Cluster Mariadb Galera (Nginx).
### Lancement de la stack.

`cd ../MariaDb`

`export PORT_MARIA=33064`

`export APP_NAME=GALERACLUSTER`

`cat nginx_template.conf | sed 's/template/GALERACLUSTER/g' > nginx_GALERACLUSTER.conf`

`cat TPL-docker-compose-galera-mariadb.yml | sed 's/<PORT_MARIA>/33064/g' | sed 's/<APP_NAME>/GALERACLUSTER/g' > GALERACLUSTER-docker-compose-galera-mariadb.yml`

`docker stack deploy --compose-file GALERACLUSTER-docker-compose-galera-mariadb.yml $APP_NAME`

## Création d'un Cluster Mariadb Galera.
### Lancement de la stack.

`export PORT_MARIA=33066`

`export APP_NAME=GALERASWARM`

`cat TPL-docker-compose-galeracluster.yml | sed 's/<PORT_MARIA>/33066/g' | sed 's/<APP_NAME>/GALERASWARM/g' > GALERASWARM-docker-compose-galeracluster.yml`

`docker stack deploy --compose-file GALERASWARM-docker-compose-galeracluster.yml $APP_NAME`

## Swarm Visualizer.

`docker service create --name=viz --publish=8080:8080/tcp --constraint=node.role==manager --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock dockersamples/visualizer`

## Commandes sql de vérification de l'état du cluster galera.

`SHOW GLOBAL STATUS LIKE 'wsrep_cluster_size'`

`SHOW GLOBAL STATUS LIKE 'wsrep_local_state_comment'`

`SHOW GLOBAL STATUS LIKE 'wsrep_cluster_status'`

`SHOW GLOBAL STATUS LIKE 'wsrep_local_state_comment'`

`SHOW STATUS LIKE 'wsrep_last_committed';`

`SHOW GLOBAL STATUS LIKE 'wsrep_%';`

## Lancement d'une base Mariadb Sandalone.
### Lancement de la stack.

`export PORT_MARIA=33062`

`export APP_NAME=MARIADB`

`cat TPL-docker-compose-standalone-mariadb.yml | sed 's/<PORT_MARIA>/33062/g' | sed 's/<APP_NAME>/MARIADB/g' > MARIADB-docker-compose-standalone-mariadb.yml`

`docker stack deploy --compose-file MARIADB-docker-compose-standalone-mariadb.yml $APP_NAME`

## Console admin

`docker run --name myadmin --network=mariadb-network --name myadmin --hostname myadmin -d -e PMA_HOSTS=GALERACLUSTER_lb,MARIADB_db, -p 8000:80 phpmyadmin/phpmyadmin`

## Script perl de chagement de données

### Commande de création de la table reçevant les données.

`CREATE database test;`

`USE test;`

`CREATE TABLE data ( id INTEGER NOT NULL AUTO_INCREMENT, value CHAR(30), count INTEGER, PRIMARY KEY (value), KEY (id) );`

### Chargemenr des donées.

`cd ..`

* Cluster.

`docker run -it --rm --name my-running-script --network=mariadb-network -v "$PWD":/usr/src/myapp -w /usr/src/myapp fabricedupre/perl:dbi perl query-lb.pl`

* Standalone.

`docker run -it --rm --name my-running-script --network=mariadb-network -v "$PWD":/usr/src/myapp -w /usr/src/myapp fabricedupre/perl:dbi perl query-single.pl`

## Arrêt/Relance d'une stack.

### Galera.

* Arrêt de la stack.

`export APP_NAME=GALERACLUSTER`

`docker stack rm $APP_NAME`

* Modification du fichier grastate.dat

Le fait de passer de 0 a 1 la variable **safe_to_bootstrap**, permet au cluster de redémarrer avec le node1 comme master.

`docker run -v GALERACLUSTER_Volumenode1VarLibMysql:/var/lib/mysql ubuntu sed -i 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/g' /var/lib/mysql/grastate.dat`

* Vérification du contenu du fichier **grastate.dat**.

`docker run -v GALERACLUSTER_Volumenode1VarLibMysql:/var/lib/mysql ubuntu cat
 /var/lib/mysql/grastate.dat`

* Redémarrage de la pile.

`export PORT_MARIA=33064`

`export APP_NAME=GALERACLUSTER`

`docker stack deploy --compose-file GALERACLUSTER-docker-compose-galera-mariadb.yml $APP_NAME`

### Sandalone

* Arrêt de la stack.

`docker stack rm MARIADB`

* Redémarrage de la pile.

`export PORT_MARIA=33062`

`docker stack deploy --compose-file MARIADB-docker-compose-standalone-mariadb.yml MARIADB`

# Sauvegardes

* Création du volume commun

`docker volume create VolumeMysqldump`

## Lancement d'un container pilotant les sauvegardes.

`docker run -d -e MYSQL_RANDOM_ROOT_PASSWORD=yes -v VolumeMysqldump:/mnt --name MariaDb_Backups --network mariadb-network fabricedupre/mariadb-ubuntu:latest`

## Lancement Sauvegardes Standalone

`docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/svgxtrabackup.sh root rootpass MARIADB_db`

`docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/dumpSQL.sh root rootpass MARIADB_db`

## Lancement Sauvegardes Cluster

`docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/svgxtrabackup.sh root rootpass GALERACLUSTER_lb

docker exec -it MariaDb_Backups /bin/bash /usr/local/bin/dumpSQL.sh root rootpass GALERACLUSTER_lb`

## Vérification Sauvegardes Standalone

`docker exec -it MariaDb_Backups ls -rtl /mnt/MARIADB_db/mysqldump`

## Vérification Sauvegardes Cluster

`docker exec -it MariaDb_Backups ls -rtl /mnt/GALERACLUSTER_lb/mysqldump`

## Tunning.

### Application MARIADB.

`docker run -i -t --network mariadb-network --rm hauptmedia/mysqltuner mysqltuner --host MARIADB_db --user root --pass rootpass --forcemem 32000 --verbose --buffers --dbstat --idxstat --sysstat --pfstat`

### Application GALERACLUSTER.

`docker run -i -t --network mariadb-network --rm hauptmedia/mysqltuner mysqltuner --host GALERACLUSTER_lb --user root --pass rootpass --forcemem 32000 --verbose --buffers --dbstat --idxstat --sysstat --pfstat`

### Tunning specifique mis en place pour la base ekm de la stack JLTMariaDB.

A l'aide de mysqltune, et de cette doc https://www.tecmint.com/mysql-mariadb-performance-tuning-and-optimization/3/ j'ai positionné les paramètres suivants sur la base ekm.

* InnoDB file-per-table.

```
MariaDB [(none)]> select @@innodb_file_per_table;
+-------------------------+
| @@innodb_file_per_table |
+-------------------------+
|                       1 |
+-------------------------+
1 row in set (0.00 sec)
```

* InnoDB buffer pool Usage.

```
MariaDB [(none)]> SET GLOBAL innodb_buffer_pool_size=1288490188;

MariaDB [(none)]> select @@innodb_buffer_pool_size;
+---------------------------+
| @@innodb_buffer_pool_size |
+---------------------------+
|                1342177280 |
+---------------------------+
1 row in set (0.00 sec)
```

* MySQL thread_cache_size.

```
MariaDB [(none)]> show status like 'Threads_created';
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| Threads_created | 649   |
+-----------------+-------+
1 row in set (0.00 sec)

MariaDB [(none)]> show status like 'Connections';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Connections   | 4564  |
+---------------+-------+
1 row in set (0.00 sec)
```

La formule a appliquer pour positionner le paramètre thread_cache_size est la suivante :

thread_cache_size = 100 - ((Threads_created / Connections) * 100)

```
MariaDB [(none)]> set global thread_cache_size = 86;
Query OK, 0 rows affected (0.00 sec)
```

*  MySQL query_cache_size.

Si vous avez de nombreuses requêtes répétitives et que vos données ne changent pas souvent, utilisez le cache de requêtes. Si le query_cache_size est trop gros, cela peut entraîner une dégradation des performances.
La raison derrière cela est le fait que les threads doivent verrouiller le cache pendant les mises à jour. 
En règle la valeur de 200 à 300 Mo doit être plus que suffisante.
Par défaut sa valeur est de 64M, je la positionne a 80M.

```
MariaDB [(none)]> select @@query_cache_type;
+--------------------+
| @@query_cache_type |
+--------------------+
| ON                 |
+--------------------+
1 row in set (0.00 sec)

MariaDB [(none)]> set global query_cache_limit=256*1024;

MariaDB [(none)]> select @@query_cache_limit;
+---------------------+
| @@query_cache_limit |
+---------------------+
|              262144 |
+---------------------+
1 row in set (0.00 sec)

MariaDB [(none)]> set global query_cache_min_res_unit=2*1024;

MariaDB [(none)]> select @@query_cache_min_res_unit;
+----------------------------+
| @@query_cache_min_res_unit |
+----------------------------+
|                       2048 |
+----------------------------+
1 row in set (0.00 sec)

MariaDB [(none)]> set global query_cache_size=80*1024*1024;

MariaDB [(none)]> select @@query_cache_size;
+--------------------+
| @@query_cache_size |
+--------------------+
|           83886080 |
+--------------------+
1 row in set (0.00 sec)
```

* tmp_table_size et max_heap_table_size.

Les deux directives doivent avoir la même taille pour éviter les écritures de disque. 
Tmp_table_size est la taille maximale des tables internes en mémoire. 
En cas de dépassement de la limite en question, la table sera convertie en table MyISAM sur disque.

Cela affectera les performances de la base de données. 
Les administrateurs recommandent généralement de donner 64 Mo pour les deux valeurs pour chaque Go de RAM sur le serveur.

```
MariaDB [(none)]> set global tmp_table_size=128*1024*1024;

MariaDB [(none)]> show global variables like 'max_heap_table_size%';
+---------------------+----------+
| Variable_name       | Value    |
+---------------------+----------+
| max_heap_table_size | 67108864 |
+---------------------+----------+
1 row in set (0.00 sec)

MariaDB [(none)]> set global max_heap_table_size=128*1024*1024;

MariaDB [(none)]> show global variables like 'innodb_buffer_pool_size%';
+-------------------------+------------+
| Variable_name           | Value      |
+-------------------------+------------+
| innodb_buffer_pool_size | 1342177280 |
+-------------------------+------------+
1 row in set (0.00 sec)
```

* innodb_buffer_pool_size.

Cette valeur doit être comprise entre 60% et 70% de la taille de la memoire du serveur hebergeant la base de données.
Comme le container utilise 2Go, je positionne comme suit la valeur:

`MariaDB [(none)]> SET GLOBAL innodb_buffer_pool_size=1288490188;`

* MySQL idle Connections.

Il est recommandé, dans la majorité des cas de positionner ce paramètre a 60.

```
MariaDB [(none)]> set wait_timeout=60;
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> select @@wait_timeout;
+----------------+
| @@wait_timeout |
+----------------+
|             60 |
+----------------+
1 row in set (0.00 sec)
```
