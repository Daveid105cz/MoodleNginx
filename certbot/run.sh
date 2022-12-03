#!/bin/bash

if [ -z "$CRONS" ]; then 
    CRONS="20 1 * * *"
fi

echo "Cron timings used: $CRONS"

echo -n "$CRONS " > /testTex.txt
echo "certbot renew > /proc/1/fd/1 2>&1" >> /testTex.txt

echo "Using this cronjob:"
cat /testTex.txt

/usr/bin/crontab -u root /testTex.txt


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
