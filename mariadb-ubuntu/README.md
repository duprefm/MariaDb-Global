# mariadb-ubuntu
Image Docker Mariadb 10.2 sur base ubuntu Xenial.

## Récupération des fichiers de construction de l'image.
git clone http://v-app-srvc-001.mycorp-v.corp:3000/MCO/MariaDB.git

## Construction de l'image.

cd MariaDB/mariadb-ubuntu

docker login dtr-v-rr.docker.opteama.net:443

docker build -t dtr-v-rr.docker.opteama.net:443/stelia/mariadb:latest .

docker push dtr-v-rr.docker.opteama.net:443/stelia/mariadb:latest

## Lancement d'un container.
### En définisant un mot de passe a root, une première base, et son user/password.
docker run -d -e MYSQL_ROOT_PASSWORD=secret -e MYSQL_DATABASE=basefabrice -e MYSQL_USER=fabrice -e MYSQL_PASSWORD=secret -p 3306:3306 dtr-v-rr.docker.opteama.net:443/stelia/mariadb:latest

## Variables d'environnementL
Lorsque vous démarrez cette image, vous pouvez ajuster la configuration de l'instance MariaDB en passant une ou plusieurs variables d'environnement a la ligne de commande d'exécution de docker. Notez qu'aucune des variables ci-dessous n'aura d'effet si vous démarrez le conteneur avec un répertoire de données qui contient déjà une base de données: toute base de données préexistante sera toujours laissée intacte lors du démarrage du conteneur.

### MYSQL_ROOT_PASSWORD
Cette variable est obligatoire et spécifie le mot de passe qui sera défini pour le compte super-utilisateur root MariaDB.

### MYSQL_DATABASE
Cette variable est facultative et vous permet de spécifier le nom d'une base de données à créer lors du démarrage de l'image. Si un utilisateur / mot de passe a été fourni (voir ci-dessous), cet utilisateur recevra un accès de superutilisateur (correspondant à GRANT ALL) à cette base de données.

### MYSQL_USER, MYSQL_PASSWORD
Ces variables sont facultatives, utilisées conjointement pour créer un nouvel utilisateur et définir le mot de passe de cet utilisateur. Cet utilisateur recevra des autorisations de superutilisateur (voir ci-dessus) pour la base de données spécifiée par la variable MYSQL_DATABASE. Les deux variables sont nécessaires pour créer un utilisateur.

Notez qu'il n'est pas nécessaire d'utiliser ce mécanisme pour créer le super-utilisateur racine, cet utilisateur est créé par défaut avec le mot de passe spécifié par la variable MYSQL_ROOT_PASSWORD.

### MYSQL_ALLOW_EMPTY_PASSWORD
Il s'agit d'une variable facultative. Réglez sur oui pour permettre au conteneur de démarrer avec un mot de passe vide pour l'utilisateur root. REMARQUE: le réglage de cette variable sur Oui n'est pas recommandé à moins que vous ne sachiez vraiment ce que vous faites, car cela laissera votre instance MariaDB totalement protégée, ce qui permettra à quiconque d'obtenir un accès superutilisateur complet.

### MYSQL_RANDOM_ROOT_PASSWORD
Il s'agit d'une variable facultative. Définissez sur yes pour générer un mot de passe initial aléatoire pour l'utilisateur root (utilisant pwgen). Le mot de passe racine généré sera imprimé à stdout (GENERATED ROOT PASSWORD: .....).
