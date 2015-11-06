#
# PHP Farm Docker image
#

# we use Debian as the host OS
FROM philcryer/min-wheezy:latest

MAINTAINER Andreas Gohr, andi@splitbrain.org
#WORKDIR /root

# add some build tools
RUN apt-get update && \
    apt-get install -y \
    apache2 \
    apache2-mpm-prefork \
    git \
    build-essential \
    wget \
    libxml2-dev \
    libssl-dev \
    libsslcommon2-dev \
    libcurl4-openssl-dev \
    pkg-config \
    curl \
    libapache2-mod-fcgid \
    libbz2-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libxpm-dev \
    libmcrypt-dev \
    libt1-dev \
    libltdl-dev \
    libmhash-dev \
    libmysqlclient-dev \
    mysql-server \
    vim

# clone phpfarm
RUN git clone https://github.com/cweiske/phpfarm.git /root/phpfarm

# add customized configuration
COPY phpfarm /root/phpfarm/src/
COPY wordpress_plugins /root/wordpress_plugins
COPY apache  /etc/apache2/

# compile, set up mysql & wp, clean up, enable/disable apache stuff
RUN /root/phpfarm/src/php.sh && \
    /root/phpfarm/src/mysql.sh && \
    /root/phpfarm/src/wordpress.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    a2dissite 000-default && \
    a2ensite super-php && \
    a2enmod rewrite

# set path
ENV PATH /root/phpfarm/inst/bin/:/usr/sbin:/usr/bin:/sbin:/bin

# expose the ports
EXPOSE 80

# run it
COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
