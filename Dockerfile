FROM lsiobase/nginx:3.12

ARG VERSION
ARG LEAN_VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="fabiodcorreia"

ENV LEAN_VERSION=2.1.4
ENV LEANTIME_PATH=/var/www/html

WORKDIR ${LEANTIME_PATH}

RUN apk update && apk add --no-cache \
  curl \
  php7-exif \
  php7-pcntl \
  php7-pdo_mysql \
  php7-pdo \
  php7-bcmath \
  php7-mbstring \
  php7-gd \
  php7-mysqli \
  php7-curl \
  mysql-client \
  freetype \
  libpng \
  libjpeg-turbo \
  freetype-dev \
  libpng-dev \
  libjpeg-turbo-dev \
  icu-libs \
  jpegoptim \
  optipng \
  pngquant \
  gifsicle

RUN \
  echo "**** download leantime ****" && \
    curl -LJO \
      "https://github.com/Leantime/leantime/releases/download/v${LEAN_VERSION}/Leantime-v${LEAN_VERSION}.tar.gz" && \
  echo "**** extrat leantime ****" && \
    tar -zxvf "Leantime-v${LEAN_VERSION}.tar.gz" --strip-components 1 && \
  echo "**** clean leantime package ****" && \
    rm "Leantime-v${LEAN_VERSION}.tar.gz" && \
  echo "**** configure php-fpm and php ****" && \
    sed -i 's/;clear_env = no/clear_env = no/g' /etc/php7/php-fpm.d/www.conf && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf && \
	  sed -i 's/max_execution_time = 30/max_execution_time = 600/' /etc/php7/php.ini && \
    sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php7/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php7/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php7/php.ini && \
	  sed -i 's/pm = dynamic/pm = static/' /etc/php7/php-fpm.d/www.conf && \
	  sed -i 's/pm.max_children = 5/pm.max_children = 1/' /etc/php7/php-fpm.d/www.conf && \
    echo "error_log /dev/stdout" >> /etc/php7/php.ini && \
  echo "**** installation and setup completed ****"

# Copy local files
COPY root/ /

# Ports and Volumes
VOLUME /config
