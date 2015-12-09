Read Me
==================

Building the image
------------------
```bash
    docker build .
```

Changing PHP Versions
------------------
Before building, you can change the versions of PHP that are compiled by adding or removing from a variable in the phpfarm/php.sh file. There is a variable in that file named php_versions. You can add or reomve versions into that array. The more PHP versions there are in that list, the longer it will take to build the image.

That array is duplicated in phpfarm/wordpress.sh. If you want to run WordPress on more than one version of PHP, be sure to update the list in that file as well, before building.

Changing WordPress Versions
------------------
If you only want to run one version of WordPress on the image, you can specify that when running the container. See the section about specifying versions when running the container.

If you want to run multiple ones at a time, there is a variable in phpfarm/wordpress.sh specifying WordPress versions. That variable is named wp_versions. You can add and remove items from that list. Here, you can use any name avaiable in the WordPress git repository as a branch or a tag (including master).

Running the container
---------------------

The following will run the container, set up WordPress for every included PHP version and map port 80 on the local machine.

```bash
    docker run --rm -t -i \
    -e APACHE_UID=$UID \
    -p 80:80 \
    hashFromBuildHere
```

Above command will also remove the container again when the process is aborted with
CTRL-C. While running the Apache and PHP error log is shown on STDOUT.

Note: the entry point for this image has been defined as ''/bin/bash'' and it will
run our ''run.sh'' by default. You can specify other parameters to be run by bash
of course.

Specifying Versions When Running The Container.
---------------------

If you only want to run WordPress on one version of PHP, or if you only want one version of WordPress, you can specify that when running the docker.

Note: For PHP versions, you are restrictied to only using the versions of PHP the image was initally build with. For WordPress versions, you can specify any name avaiable in the WordPress git repository as a branch or a tag (including master). The example below uses PHP version 5.2.4 and WordPress version 4.3.1.

```bash
    docker run --rm -t -i \
    -e APACHE_UID=$UID \
    -e php="5.2.4" \
    -e wordpress="4.3.1" \
    -p 80:80 \
    hashFromBuildHere
```

Installing WordPress Automatically
---------------------
WordPress versions of 3.5.2 and higher on PHP versions 5.3.2 and higher can be installed automatically if you provide the base URL for the docker image.

```bash
    docker run --rm -t -i \
    -e APACHE_UID=$UID \
    -e base_url="http://example.lcl" \
    -p 80:80 \
    hashFromBuildHere
```

It is important not to include a trailing / for the base_url paramater.

Loading in WordPress Plugins from WordPress.org (and URLs)
---------------------

In phpfarm/wordpress.sh there is a variable named plugins. It is an array of plugin slugs (from WordPress.org) and URLs of zips. These plugins will automatically be installed for any WordPress versions of 3.5.2 and higher running on PHP versions 5.3.2 and higher.

Loading in WordPress Plugins from your local environment
---------------------
The plugins all get loaded in from the /root/wordpress_plugins/ folder. Each WordPress instance sym links to it. You have three ways to put things into this folder.

1. Before building, you can make a folder called wordpress_plugins as a sibling with the Dockerfile and put your plugins (the unzipped plugin folders) there.

2. copy it in after the container is running

3. mount a folder on our machine into the container when you run it. The below will mount your current working directory in /root/wordpress_plugins/

```bash
    docker run --rm -t -i \
    -e APACHE_UID=$UID \
    -v $PWD:/root/wordpress_plugins:rw \
    -p 80:80 \
    hashFromBuildHere
```

Running a Detatched Container
==================
alternately, switch out
```
-rm -t -i
```
for
```
-d
```
in any of the examples in this document to run the container detached

Default PHP Versions
==================

* 5.2.4
* 5.2.17
* 5.3.29
* 5.4.44
* 5.5.29
* 5.6.16
* 7.0.0

Default WordPress Versions
==================

* master
* 3.0
* 3.0.1
* 3.0.6
* 3.1.4
* 3.2.1
* 3.3.3
* 3.4.2
* 3.5.2
* 3.6.1
* 3.7.11
* 3.8.11
* 3.9.9
* 4.0.8
* 4.1.8
* 4.2.5
* 4.3.1
* 4.4