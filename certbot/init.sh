#!/bin/sh
rsa_key_size=4096

echo "Starting certbot initialization"
echo "Using the following settings:"
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo "Staging: $STAGING"
echo "rsa-key-size: $rsa_key_size"

if [ -n "${STAGING}" ]; then
  staging_arg="--test-cert"
fi

echo "Is staging: $staging_arg"

certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    -m $EMAIL  \
    -d $DOMAIN \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    -n \
    --force-renewal

# check if the certbot command was successful and copy the resulting certificates to a folder that is shared with the nginx container
if [ $? -eq 0 ]; then
    echo "Certbot initialization successful"
    echo "Copying certificates to shared folder"
    cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/letsencrypt/live/$DOMAIN/privkey.pem /etc/letsencrypt/
    echo "Done copying certificates"
else
    echo "Certbot initialization failed"
    exit 1
fi