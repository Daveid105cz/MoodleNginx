#!/bin/sh

#generate a snakeoil certificate for nginx
openssl req -x509 -newkey rsa:4096 -nodes -sha256 -keyout /certificates/privkey.pem -out /certificates/fullchain.pem -days 3650 -subj "/CN=<publiceIP>"