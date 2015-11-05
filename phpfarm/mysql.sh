#!/bin/bash

service mysql start

ln -s /var/run/mysqld/mysqld.sock  /tmp/mysql.sock
mkdir /var/mysql/
ln -s /var/run/mysqld/mysqld.sock  /var/mysql/mysql.sock

rootDbPassword=`openssl rand -base64 5`
wpDbPassword=`openssl rand -base64 5`

touch /mysql.passwords.txt
echo "$rootDbPassword" > /root/mysql.password.root.txt
echo "$wpDbPassword" > /root/mysql.password.wordpress.txt

mysql="
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('"$rootDbPassword"');
    SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('"$rootDbPassword"');
    CREATE USER 'wordpress'@'localhost';
    SET PASSWORD FOR 'wordpress'@'localhost' = PASSWORD('"$wpDbPassword"');
    GRANT ALL PRIVILEGES ON * . * TO 'wordpress'@'localhost';
";

mysql -u root -e "$mysql"