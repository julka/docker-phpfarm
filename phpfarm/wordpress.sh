#!/bin/bash

wp_versions=(
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

php_versions=(
#    "5.2.17"
#    "5.3.29"
#    "5.4.44"
#    "5.5.28"
    "5.6.12"
)

service mysql start
wpDbPassword=`cat /root/mysql.password.wordpress.txt`

git clone https://github.com/WordPress/WordPress.git /root/wordpress.git

for php_version in "${php_versions[@]}"
do
    :
    cd /root/www/php-$php_version
    for wp_version in "${wp_versions[@]}"
    do
        :
        dbName=wp_${wp_version//./}_php_${php_version//./}

        mysql -u wordpress -p$wpDbPassword -e "DROP DATABASE IF EXISTS $dbName;"
        mysql -u wordpress -p$wpDbPassword -e "CREATE DATABASE $dbName;"

        wpInstallFolder="/root/www/php-$php_version/WordPress-$wp_version"
        echo "install folder is $wpInstallFolder"
        cp -Rf /root/wordpress.git $wpInstallFolder

        cd $wpInstallFolder
        git config core.fileMode false

        if [ "$wp_version" != "master" ]; then
            git checkout $wp_version -b release/$wp_version
        fi

        rm -Rf wp-content/plugins/
        cp -Rf /root/wordpress_plugins wp-content/plugins/

        cp wp-config-sample.php wp-config.php

        touch wp-config-generated.php
        echo "<?php" >> wp-config-generated.php
        echo "define('AUTOMATIC_UPDATER_DISABLED', true);" >> wp-config-generated.php
        echo "define('FS_METHOD','direct');" >> wp-config-generated.php
        echo "error_reporting(E_ALL | E_STRICT);" >> wp-config-generated.php
        echo "define('DB_NAME', '$dbName');" >> wp-config-generated.php
        echo "define('DB_USER', 'wordpress');" >> wp-config-generated.php
        echo "define('DB_PASSWORD', '$wpDbPassword');" >> wp-config-generated.php

        # set to false for versions 3.0, 3.0.1, 3.0.6, 3.1.4, 3.2.1 because there's lots of depreicated PHP calls
        if [ "$wp_version" == "3.0" ] || [ "$wp_version" == "3.0.1" ] || [ "$wp_version" == "3.0.6" ] || [ "$wp_version" == "3.1.4" ] || [ "$wp_version" == "3.2.1" ]; then
            echo "ini_set(\"display_errors\", false);" >> wp-config-generated.php
        else
            echo "ini_set(\"display_errors\", true);" >> wp-config-generated.php
        fi

        perl -pi -e 's/\/\/ \*\* MySQL settings/include\(ABSPATH . "wp-config-generated.php");\n\/\/ ** MySQL settings/' wp-config.php
        perl -pi -e 's/^(\s*define\(\s*.AUTOMATIC_UPDATER_DISABLED)/#$1/g' wp-config.php
        perl -pi -e 's/^(\s*define\(\s*.FS_METHOD)/#$1/g' wp-config.php
        perl -pi -e 's/^(\s*define\(\s*.DB_NAME)/#$1/g' wp-config.php
        perl -pi -e 's/^(\s*define\(\s*.DB_USER)/#$1/g' wp-config.php
        perl -pi -e 's/^(\s*define\(\s*.DB_PASSWORD)/#$1/g' wp-config.php
    done
done