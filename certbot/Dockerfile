FROM certbot/certbot:latest

# RUN apk update && apk add --no-cache cron
RUN apk add --no-cache --upgrade bash

# COPY certbotCron /certCronJob.txt
COPY init.sh /init.sh
COPY run.sh /run.sh

#register the cron job
# RUN /usr/bin/crontab -u root /certCronJob.txt && \
RUN chmod +x /init.sh && chmod +x /run.sh


# CMD [ "/run.sh" ]
# ENTRYPOINT [ "/usr/sbin/crond","-f" ]
ENTRYPOINT [ "/run.sh" ]