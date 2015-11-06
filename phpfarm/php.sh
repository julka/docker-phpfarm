#!/bin/bash

file="/root/php_versions.conf"
touch $file

php_versions=(
    "5.2.4"
    "5.2.17"
    "5.3.29"
    "5.4.44"
    "5.5.29"
    "5.6.14"
)

chmod ugo+x /root
chmod ugo+x /root/www

for php_version in "${php_versions[@]}"
do
    :

    mkdir -p /root/www/php-$php_version
    chmod ugo+x /root/www/php-$php_version

    echo "<?php phpinfo() ?>" > /root/www/php-$php_version/php_info.php

    /root/phpfarm/src/compile.sh $php_version

    # cat directory stuff into a file for apache
    echo "<Directory /root/www/php-$php_version/>" >> $file
    echo "    FCGIWrapper /root/phpfarm/inst/php-$php_version/bin/php-cgi .php" >> $file
    echo "</Directory>" >> $file
    echo "" >> $file
done