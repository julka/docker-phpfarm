#!/bin/bash

service mysql start

ln -s /var/run/mysqld/mysqld.sock  /tmp/mysql.sock
mkdir /var/mysql/
ln -s /var/run/mysqld/mysqld.sock  /var/mysql/mysql.sock

mysql -u root -e "
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('password');
    SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('password');
    CREATE USER 'wordpress'@'localhost';
    SET PASSWORD FOR 'wordpress'@'localhost' = PASSWORD('addthisrocks');
    GRANT ALL PRIVILEGES ON * . * TO 'wordpress'@'localhost';
"

