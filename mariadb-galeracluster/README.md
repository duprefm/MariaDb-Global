# mariadb-galeracluster

## Création d'un réseau

` docker network create -d overlay monreseau `

## Construction de l'image

docker build -t fabricedupre/mariadb-galeracluster:latest .

docker push fabricedupre/mariadb-galeracluster:latest

## Init/Bootstrap d'un Cluster

Au début, je commence par créer un nouveau service avec 1 réplicas, cette instance debiendra donc le noeud principal.

Remarque: le nom du service fourni par --name doit correspondre à la variable d'environnement DB_SERVICE_NAME définie avec --env DB_SERVICE_NAME.

Bien sûr, les options par défaut de MariaDB pour définir un mot de passe root, créer une base de données, créer un utilisateur et définir un mot de passe pour cet utilisateur sont conservées. 

Exemple:

` docker service create --name dbcluster --network monreseau --publish 33063:3306 --replicas=1 --env DB_SERVICE_NAME=dbcluster --env MYSQL_ROOT_PASSWORD=rootpass --env MYSQL_DATABASE=mydb --env MYSQL_USER=mydbuser --env MYSQL_PASSWORD=mydbpass fabricedupre/mariadb-galeracluster:latest `

## Construction du cluster.

Pour l'instant le cluster n'as pas de réplicas, avant d'ajouter des membres, je vais vérifier que le premier membre a bien démarré.

### Vérification de l'état des services.

` docker service ls `

ID                  NAME                MODE                REPLICAS            IMAGE                                       PORTS
sy0hgai87k64        dbcluster           replicated          1/1                 fabricedupre/mariadb-galeracluster:latest   *:33063->3306/tcp

### Vérification de la log du premier service.

` docker service logs dbcluster `

### Passage a 3 membres.

` docker service scale dbcluster=3 `

## En mode stack.

export APP_NAME=GALERA

export PORT=33066

docker stack deploy --compose-file docker-compose-galeracluster.yml $APP_NAME

docker service scale GALERA_dbcluster=3

## Arrêt/Relance de la stack.

### Arrêt de la stack.

export APP_NAME=GALERA

docker stack rm $APP_NAME

### Init du cluster.

* Passage du node slave comme membre le plus a jour.

docker run --network=admin-mariadb-network -v GALERA_Volumedbcluster-slaveVarLibMysql:/var/lib/mysql ubuntu sed -i 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/g' /var/lib/mysql/grastate.dat

* Vérification.

docker run --network=admin-mariadb-network -v GALERA_Volumedbcluster-slaveVarLibMysql:/var/lib/mysql ubuntu cat /var/lib/mysql/grastate.dat

## Relance.

### Cluster initial.

export APP_NAME=GALERA

export PORT=33066

docker stack deploy --compose-file docker-compose-galeracluster.yml $APP_NAME

### Cluster a 3 membres actif.

docker service scale GALERA_dbcluster=3
