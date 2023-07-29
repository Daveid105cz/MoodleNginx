FROM alpine:latest as git
RUN apk add git

# Multistage build, first installs GIT and then clones the official moodle repo
# and switches branch to the desired version
FROM git as fetch
WORKDIR /repo
ENV MOODLE_BRANCH MOODLE_402_STABLE
RUN git clone git://git.moodle.org/moodle.git && cd moodle && \
    git branch --track ${MOODLE_BRANCH} origin/${MOODLE_BRANCH} && \
    git checkout ${MOODLE_BRANCH}  

FROM ubuntu:jammy

# Install software-properties-common(needed for adding APT repo) and CRON
RUN apt-get -qq update && apt-get -qq upgrade -y &&\
    apt-get -qq install -y software-properties-common cron

ENV PHP_VERSION 8.1

# Install all required PHP packages and packages needed for moodle to work(graphviz, aspell, ghostscript, ...)
# also NGINX itself
RUN LC_ALL=C.UTF-8 apt-add-repository ppa:ondrej/php -y && \
    apt-get update && apt-get install -y \
    graphviz \
    aspell \
    ghostscript \
    clamav \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-pspell \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mysqlnd \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xmlrpc \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-gd \
    nginx && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# copy the cloned Moodle source code to the output stage from the clone stage
COPY --from=fetch /repo/moodle/ /var/www/html/
# "install" supervisord to allow running multiple processes under one container
# installed by extraction from its official docker image (as reccomended)
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
# copy CRON job configurations for moodle CRON job and NGINX reload (for certificate reload)
COPY imageFiles/moodleCron /moodleCronJob.txt
COPY imageFiles/certCron /certCronJob.txt

# copy the script for generating the snakeoil certificate
COPY imageFiles/genSnakeOilCert.sh /genSnakeOilCert.sh

# set permissions for moodledata folder
# also registers the CRON jobs for specific users by CRONTABs
RUN mkdir /moodledata && mkdir /certificates && mkdir /certificateChallenges &&\
    chmod -R 777 /moodledata && chmod -R 777 /certificates && chmod -R 777 /certificateChallenges &&\
    chmod +r /var/www/html &&\
    /usr/bin/crontab -u www-data /moodleCronJob.txt &&\
    /usr/bin/crontab -u root /certCronJob.txt &&\
    chmod +x /genSnakeOilCert.sh

# copy nginx main and site configuration
COPY imageFiles/nginx.conf /etc/nginx/nginx.conf
COPY imageFiles/nginx-site.conf /etc/nginx/sites-enabled/default
# copy php-fpm config (contains the listen unix socket configuration)
COPY imageFiles/php-fpm.conf /etc/php/8.1/fpm/php-fpm.conf
# copy php.ini config (contains the OPCache settings and send limits)
COPY imageFiles/php.ini /etc/php/8.1/fpm/php.ini

# copy the supervisord config
# it specifies which processes it should run at startup
# more info about Supervisord-GO here: https://github.com/ochinchina/supervisord
COPY imageFiles/supervisord.conf /etc/supervisor/supervisord.conf

VOLUME [ "/moodledata", "/certificates" ]
CMD ["/usr/local/bin/supervisord"]
