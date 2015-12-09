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
    "5.2.4"
    "5.2.17"
    "5.3.29"
    "5.4.44"
    "5.5.29"
    "5.6.16"
    "7.0.0"
)

wpDbPassword=`cat /root/mysql.password.wordpress.txt`

# only used the specified php version, if specified at all
if [ ! -z "$php" ] ; then
    php_versions=($php)
    echo "php version defined as $php"
fi

# only use the specified wordpress version, if specified at all
if [ ! -z "$wordpress" ] ; then
    wp_versions=($wordpress)
    echo "wordpress version defined as $wordpress"
fi

php_vmajor=`echo ${php_version%%.*}`
php_vminor=`echo ${php_version%.*}`
php_vminor=`echo ${php_vminor#*.}`
php_vpatch=`echo ${php_version##*.}`

wp_vmajor=`echo ${wp_version%%.*}`
wp_vminor=`echo ${wp_version%.*}`
wp_vminor=`echo ${wp_vminor#*.}`
wp_vpatch=`echo ${wp_version##*.}`

cd /root/wordpress.git
git fetch origin
git rebase
chmod -R ugo+rwx /root/wordpress_plugins/

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

        if [ "$wp_version" != "master" ] ; then
            git checkout $wp_version -b release/$wp_version
        fi

        rm -Rf wp-content/plugins/
        #ln -s /root/wordpress_plugins wp-content/plugins
        cp -rf /root/wordpress_plugins wp-content/plugins

        cp wp-config-sample.php wp-config.php

        touch wp-config-generated.php
        echo "<?php" >> wp-config-generated.php
        echo "define('AUTOMATIC_UPDATER_DISABLED', true);" >> wp-config-generated.php
        echo "define('FS_METHOD','direct');" >> wp-config-generated.php
        echo "error_reporting(E_ALL | E_STRICT);" >> wp-config-generated.php
        echo "define('DB_NAME', '$dbName');" >> wp-config-generated.php
        echo "define('DB_USER', 'wordpress');" >> wp-config-generated.php
        echo "define('DB_PASSWORD', '$wpDbPassword');" >> wp-config-generated.php
        echo "ini_set ('upload_max_filesize', '20M' );" >> wp-config-generated.php

        # set to false for versions 3.2 and older because there's lots of depreicated PHP calls
        wp_version_check_good=false
        if [ "$wp_version" = "master" ] ; then
            wp_version_check_good=true
        else
            if [ "$wp_vmajor" -ge "3" ] ; then
                if [ "$wp_vminor" -gt "2" ] || [ "$wp_vmajor" -gt "3" ] ; then
                    wp_version_check_good=true;
                fi
            fi
        fi

        if $wp_version_check_good; then
            echo "ini_set(\"display_errors\", true);" >> wp-config-generated.php
        else
            echo "ini_set(\"display_errors\", false);" >> wp-config-generated.php
        fi

        perl -pi -e 's/\/\/ \*\* MySQL settings/include\(ABSPATH . "wp-config-generated.php");\n\/\/ ** MySQL settings/' wp-config.php
        perl -pi -e 's/^(\s*define\(\s*.AUTOMATIC_UPDATER_DISABLED)/#$1/g' wp-config.php
        perl -pi -e 's/^(\s*define\(\s*.FS_METHOD)/#$1/g' wp-config.php
        perl -pi -e 's/^(\s*define\(\s*.DB_NAME)/#$1/g' wp-config.php
        perl -pi -e 's/^(\s*define\(\s*.DB_USER)/#$1/g' wp-config.php
        perl -pi -e 's/^(\s*define\(\s*.DB_PASSWORD)/#$1/g' wp-config.php

        if [ ! -z "$base_url" ] ; then
            base_url=($base_url)
            echo "base url defined as $base_url"
            php_version_check_good=false
            wp_version_check_good=false

            if [ "$wp_version" = "master" ] ; then
                php_version_check_good=true
                wp_version_check_good=true
            else
                # requires PHP 5.3.2 and higher
                if [ "$php_vmajor" -ge "5" ] ; then
                    if [ "$php_vminor" -ge "3" ] || [ "$php_vmajor" -gt "5" ] ; then
                        if [ "$php_vpatch" -ge "2" ] || [ "$php_vminor" -gt "3" ] || [ "$php_vmajor" -gt "5" ] ; then
                            php_version_check_good=true
                        fi
                    fi
                fi

                # requires WordPress version 3.5.2 or higher
                if [ "$wp_vmajor" -ge "3" ] ; then
                    if [ "$wp_vminor" -ge "5" ] || [ "$wp_vmajor" -gt "3" ] ; then
                        if [ "$wp_vpatch" -ge "2" ] || [ "$wp_vminor" -gt "5" ] || [ "$wp_vmajor" -gt "3" ] ; then
                            wp_version_check_good=true
                        fi
                    fi
                fi
            fi

            # if the above versions check out, we can install WordPress from the command line
            if [ "$php_version_check_good" = true ] && [ "$wp_version_check_good" = true ] ; then
                echo "Installing WordPress"
                /root/phpfarm/inst/php-$php_version/bin/php /root/wp-cli.phar \
                    --allow-root \
                    core install \
                    --url="$base_url/php-$php_version/WordPress-$wp_version/wp-admin/install.php" \
                    --title="WordPress $wp_version test environment on PHP $php_version" \
                    --admin_user="admin" \
                    --admin_password="password" \
                    --admin_email="plugins@addthis.com"

                plugins=(
                    #"addthis"
                    "http://buildspring/nexus/service/local/artifact/maven/redirect?r=releases&g=com.addthis.wordpress&a=wordpress-sharing-buttons&e=zip&v=LATEST"
                    "addthis-follow"
                    "addthis-smart-layers"
                    "addthis-welcome"
                )

                for plugin_slug in "${plugins[@]}"
                do
                    :
                    /root/phpfarm/inst/php-$php_version/bin/php /root/wp-cli.phar \
                        --allow-root \
                        plugin install $plugin_slug
                done

            else
                echo "Version mismatch, can't install WordPress from the command line"
            fi
        fi
    done
done

chmod -R ugo+rwx /root/www/

# set up consistent folder to make it earier to testers to find where to go
if [ ! -z "$php" ] ; then
    if [ ! -z "$wordpress" ] ; then
        # sym link to the wordpress instance for this version of php
        ln -s /root/www/php-$php/WordPress-$wordpress /root/www/start_here
    else
        # sym link to the php version
        ln -s /root/www/php-$php /root/www/start_here
    fi

    file="/root/php_versions.conf"
    echo "<Directory /root/www/start_here/>" >> $file
    echo "    FCGIWrapper /root/phpfarm/inst/php-$php/bin/php-cgi .php" >> $file
    echo "</Directory>" >> $file
    echo "" >> $file
fi