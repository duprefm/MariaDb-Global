#!/bin/bash

/usr/local/bin/dumpSQL.sh root $MYSQL_ROOT_PASSWORD localhost
/usr/local/bin/svgxtrabackup.sh root $MYSQL_ROOT_PASSWORD localhost
