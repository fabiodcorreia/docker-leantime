#!/usr/bin/with-contenv bash

CONFIG="$APP_PATH/config/configuration.php"

if [ -f "$CONFIG" ]; then
  echo "**** config file already exists ****"
else
  echo "**** creating configuration file ****"
  cd $APP_PATH || exit 1
  cp config/configuration.sample.php ${CONFIG}

  env-alias "SESSION_KEY" "LEAN_SESSION_PASSWORD"

  if [ -z "$LEAN_SESSION_PASSWORD" ]; then
    SESSION_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1)
    sed -i 's/$sessionpassword = "3evBlq9zdUEuzKvVJHWWx3QzsQhturBApxwcws2m"/$sessionpassword = "'"${SESSION_PASSWORD}"'"/g' ${CONFIG}
  fi

  echo "***** delete base /config/www/index.php *****"
  rm -fr /config/www/index.php
fi

echo "**** mapping environment variables ****"

env-alias "DATABASE_HOST" "LEAN_DB_HOST"
env-alias "DATABASE_NAME" "LEAN_DB_DATABASE"
env-alias "DATABASE_USER" "LEAN_DB_USER"
env-alias "DATABASE_PASS" "LEAN_DB_PASSWORD"
env-alias "DOMAIN_NAME" "LEAN_APP_URL"
env-alias "EMAIL_ENABLE" "LEAN_EMAIL_USE_SMTP"
env-alias "EMAIL_HOST" "LEAN_EMAIL_SMTP_HOSTS"
env-alias "EMAIL_PORT" "LEAN_EMAIL_SMTP_PORT"
env-alias "EMAIL_USER" "LEAN_EMAIL_SMTP_USERNAME"
env-alias "EMAIL_PASS" "LEAN_EMAIL_SMTP_PASSWORD"
env-alias "EMAIL_SECURE" "LEAN_EMAIL_SMTP_SECURE"

echo "**** set volume links ****"

# create directory structure
mkdir -p /config/www/userfiles
mkdir -p /config/www/logs
mkdir -p $APP_PATH/resources/logs
mkdir -p $APP_PATH/userfiles

# create symlinks
symlinks=( \
    $APP_PATH/resources/logs
    $APP_PATH/userfiles
)

for i in "${symlinks[@]}"
do
[[ -e "$i" && ! -L "$i" ]] && rm -rf "$i"
[[ ! -L "$i" ]] && ln -s /config/www/"$(basename "$i")" "$i"
done


echo "**** chown /config and /var/www ****"
chown -R abc:abc \
	/config \
	/var/www/
