#!/bin/sh
rsa_key_size=4096

echo "hello $DOMAIN with $EMAIL staging $STAGING"
# if [ $staging != "0" ]; then staging_arg="--staging"; fi

if [ -n "${STAGING}" ]; then
  staging_arg="--test-cert"
fi

certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    -m $EMAIL  \
    -d $DOMAIN \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    -n \
    --force-renewal

echo "Certbot finished"
