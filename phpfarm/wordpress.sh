#!/bin/bash

service mysql start

rm -Rf /tmp/docker-phpfarm/phpfarm/www/WordPress
mkdir -p /tmp/docker-phpfarm/phpfarm/www/WordPress
cd /tmp/docker-phpfarm/phpfarm/www/WordPress
git clone https://github.com/WordPress/WordPress.git master
#git clone http://git.clearspring.local/addthis-wordpress-plugin.git master/wp-content/plugins/addthis

versions=(
    "master"
    "3.0"
    "3.0.1"
    "3.0.6"
    "3.1.4"
    "3.2.1"
    "3.3.3"
    "3.4.2"
    "3.5.2"
    "3.6.1"
    "3.7.11"
    "3.8.11"
    "3.9.9"
    "4.0.8"
    "4.1.8"
    "4.2.5"
    "4.3.1"
)

for version in "${versions[@]}"
do
    :
    dbName=wp_${version//./}

    mysql -u wordpress -paddthisrocks -e "DROP DATABASE IF EXISTS ${dbName};"
    mysql -u wordpress -paddthisrocks -e "CREATE DATABASE ${dbName};"

    if [ "$version" != "master" ]; then
        cp -Rf master $version
    fi

    cd $version
    pwd

    if [ "$version" != "master" ]; then
        git checkout $version -b release/$version
    fi

    cp wp-config-sample.php wp-config.php
    echo "define('AUTOMATIC_UPDATER_DISABLED', true);" >> wp-config.php
    echo "define('FS_METHOD','direct');" >> wp-config.php
    echo "error_reporting(E_ALL | E_STRICT);" >> wp-config.php
    echo "define('DB_NAME', '$dbName');" >> wp-config.php
    echo "define('DB_USER', 'wordpress');" >> wp-config.php
    echo "define('DB_PASSWORD', 'addthisrocks');" >> wp-config.php

    # set to false for versions 3.0, 3.0.1, 3.0.6, 3.1.4, 3.2.1 because there's lots of depreicated PHP calls
    if [ "$version" == "3.0" ] || [ "$version" == "3.0.1" ] || [ "$version" == "3.0.6" ] || [ "$version" == "3.1.4" ] || [ "$version" == "3.2.1" ]; then
        echo "ini_set(\"display_errors\", false);" >> wp-config.php
    else
        echo "ini_set(\"display_errors\", true);" >> wp-config.php
    fi

    cd ../
done

pwd
ls -l