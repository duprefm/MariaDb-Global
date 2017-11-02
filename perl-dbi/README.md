# perl-dbi
Docker with perl DBI
### Script perl de chagement de données

docker run -it --rm --name my-running-script --network=admin-mariadb-network -v "$PWD":/usr/src/myapp -w /usr/src/myapp fabricedupre/perl:dbi perl query1.pl

docker run -it --rm --name my-running-script --network=admin-mariadb-network -v "$PWD":/usr/src/myapp -w /usr/src/myapp fabricedupre/perl:dbi perl query2.pl
