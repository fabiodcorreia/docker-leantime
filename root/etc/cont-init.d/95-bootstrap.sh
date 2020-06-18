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


echo "**** set volume links ****"

# create directory structure
mkdir -p /config/www/userfiles
mkdir -p /config/www/logs
mkdir -p $APP_DIR/resources/logs
mkdir -p $APP_DIR/userfiles

# create symlinks
symlinks=( \
    $APP_DIR/resources/logs
    $APP_DIR/userfiles
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

echo "**** finish 95-bootstrap.sh ****"
