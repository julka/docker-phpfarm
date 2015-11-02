#!/bin/bash

service mysql start

mysql -u root -e "
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('password');
    SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('password');
    CREATE USER 'wordpress'@'localhost';
    SET PASSWORD FOR 'wordpress'@'localhost' = PASSWORD('addthisrocks');
    GRANT ALL PRIVILEGES ON * . * TO 'wordpress'@'localhost';
"