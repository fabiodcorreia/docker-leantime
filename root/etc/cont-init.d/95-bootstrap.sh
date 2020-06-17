#!/usr/bin/with-contenv bash

echo "**** start 95-bootstrap.sh ****"

APP_DIR="/var/www/html"
CONFIG="/var/www/html/config/configuration.php"

if [ -f "$CONFIG" ]; then
  echo "**** config file already exists ****"
else
  echo "**** creating configuration file ****"
  cd $APP_DIR || exit 1
  cp config/configuration.sample.php ${CONFIG}

  if [ -z "$LEAN_SESSION_PASSWORD" ]; then
    #generating 32 character string for session password
    SESSION_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1)
    sed -i 's/$sessionpassword = "3evBlq9zdUEuzKvVJHWWx3QzsQhturBApxwcws2m"/$sessionpassword = "'"${SESSION_PASSWORD}"'"/g' ${CONFIG}
  fi
fi

echo "**** chown /config and /var/www ****"
chown -R abc:abc \
	/config \
	/var/www/

echo "**** finish 95-bootstrap.sh ****"
