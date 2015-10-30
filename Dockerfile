#
# PHP Farm Docker image
#

# we use Debian as the host OS
FROM philcryer/min-wheezy:latest

MAINTAINER Andreas Gohr, andi@splitbrain.org

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

# install and run the phpfarm script
RUN git clone -b mysql https://github.com/julka/phpfarm.git phpfarm
#COPY phpfarm.git phpfarm

# add customized configuration
COPY phpfarm /phpfarm/src/

# compile, then delete sources (saves space)
RUN cd /phpfarm/src && \
    ./compile.sh 5.2.17 && \
    ./compile.sh 5.3.29 && \
    ./compile.sh 5.4.44 && \
    ./compile.sh 5.5.28 && \
    ./compile.sh 5.6.12 && \
    rm -rf /phpfarm/src && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# reconfigure Apache
RUN rm -rf /var/www/*

COPY var-www /var/www/
COPY apache  /etc/apache2/

#RUN /phpfarm/src/mysql.sh
#RUN /phpfarm/src/wordpress.sh

RUN a2ensite php-5.2 php-5.3 php-5.4 php-5.5 php-5.6
RUN a2enmod rewrite

# set path
ENV PATH /phpfarm/inst/bin/:/usr/sbin:/usr/bin:/sbin:/bin

# expose the ports
EXPOSE 8052 8053 8054 8055 8056

# run it
COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
