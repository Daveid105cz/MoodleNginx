#!/bin/bash

# check if a file called .isInit has been created in the /etc/letsencrypt folder
# if it has, then we have already initialized the certbot, so we can just start the cron daemon
# if it has not, then we need to initialize the certbot, and then start the cron daemon
# this is done to avoid having to initialize the certbot every time the container is started

# use a specific file for staging and production
if [ -n "${STAGING}" ]; then
    INITFILE="/etc/letsencrypt/.isInitStaging"
else
    INITFILE="/etc/letsencrypt/.isInitProduction"
fi

if [ ! -f "$INITFILE" ]; then
    /init.sh
    # check if the init script was successful
    if [ $? -ne 0 ]; then
        echo "Initialization failed, fix the issue and then restart the container manually"
        # blocking loop to keep the container alive
        while true; do sleep 1; done
    fi
    touch /etc/letsencrypt/.isInit
fi

if [ -z "$CRONS" ]; then 
    CRONS="20 1 * * *"
fi

echo "Cron timings used: $CRONS"

echo -n "$CRONS " > /cronSettings.txt
echo 'certbot renew --deploy-hook "cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/letsencrypt/live/$DOMAIN/privkey.pem /etc/letsencrypt/" > /proc/1/fd/1 2>&1' >> /cronSettings.txt

echo "Using this cronjob:"
cat /cronSettings.txt

echo "Installing cronjob"
/usr/bin/crontab -u root /cronSettings.txt


# A magical way of killing a child process when the shell receives SIGTERM
# For some reason, the cron daemond does not respond to SIGTERM, so using "exec /usr/sbin/crond -f" does not help
# Trust me, I tried.... several times...
# Also, this code is mainly yoinked from Stackoverflow
_term() { 
  echo "Caught SIGTERM signal! Killing children" 
  kill -TERM "$child" 2>/dev/null
}

trap _term SIGTERM

echo "Starting the cron daemon in the foreground";
/usr/sbin/crond -f &

child=$! 
wait "$child"
