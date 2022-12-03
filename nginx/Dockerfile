FROM alpine:latest as git
RUN apk add git

FROM git as fetch
WORKDIR /repo
ENV MOODLE_BRANCH MOODLE_311_STABLE
RUN git clone git://git.moodle.org/moodle.git && cd moodle && \
    git branch --track ${MOODLE_BRANCH} origin/${MOODLE_BRANCH} && \
    git checkout ${MOODLE_BRANCH}  

FROM ubuntu:jammy

RUN apt-get -qq update && apt-get -qq upgrade -y &&\
    apt-get -qq install -y software-properties-common cron

ENV PHP_VERSION 7.4

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
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mysqlnd \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xmlrpc \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-mbstring \
    nginx && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=fetch /repo/moodle/ /var/www/html/
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord
COPY imageFiles/moodleCron /moodleCronJob.txt
COPY imageFiles/certCron /certCronJob.txt

#set permissions for moodledata folder and also register the cron job
RUN mkdir /moodledata && mkdir /certs && mkdir /certChallenges &&\
    chmod -R 777 /moodledata && chmod -R 777 /certs && chmod -R 777 /certChallenges &&\
    /usr/bin/crontab -u www-data /moodleCronJob.txt && /usr/bin/crontab -u root /certCronJob.txt

#copy nginx and php configuration files
COPY imageFiles/nginx.conf /etc/nginx/nginx.conf
COPY imageFiles/nginx-site.conf /etc/nginx/sites-enabled/default
COPY imageFiles/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf
COPY imageFiles/php.ini /etc/php/7.4/fpm/php.ini

COPY imageFiles/supervisord.conf /etc/supervisor/supervisord.conf

VOLUME [ "/moodledata", "/certs" ]
CMD ["/usr/local/bin/supervisord"]
