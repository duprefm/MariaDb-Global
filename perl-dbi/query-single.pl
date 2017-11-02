#!/usr/bin/perl -w
=pod

USE admindb;
CREATE TABLE data ( 
	id INTEGER NOT NULL AUTO_INCREMENT, 
	value CHAR(30), 
	count INTEGER, 
	PRIMARY KEY (value), 
	KEY (id)
);

=cut

use DBI;
 
my $host   = "MARIADB_db";
my $dbname = "test";
my $table  = "data";
my $user   = "root";
my $pass   = "rootpass";

foreach $i ( 0..9999 ) { 

	my $dbh = DBI->connect("DBI:mysql:$dbname:$host", $user, $pass );

	# Which database have we connected to?
	my $sql = "SHOW VARIABLES WHERE Variable_name = 'hostname';";
	my $q = $dbh->prepare($sql);
	$q->execute;

	# Only expect one row, with key 'hostname', value thehostname
	@row = $q->fetchrow_array();
	$upstream = $row[1];
	$q->finish;

	# Add a row: value = "value-$i", count = 1; increment count on duplicate adds
	$value = sprintf "value-%03d", $i;
	$sql = "INSERT INTO $table (value, count) VALUES ( '$value', 1 ) ON DUPLICATE KEY UPDATE count=count+1";

	$q = $dbh->prepare($sql);
	$q->execute;
 	$q->finish;

 	print "$upstream\n";
}
