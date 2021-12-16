FROM debian:bullseye-slim

ENV \
APP_ENV="prod" \
APP_DEBUG="0" \
APP_SECRET="76e5df6cee257fb639cf8fb3f950a60d" \
DATABASE_URL="mysql://rootless:nopassword@mysql:3306/database?serverVersion=5.7" \
MYSQL_HOST="mysql" \
MYSQL_PORT="3306" \
MYSQL_ROOT_PASSWORD="nopassword" \
MYSQL_USER="www-data" \
MYSQL_PASSWORD="www-password" \
MYSQL_DATABASE="worker" \
MEMORY_LIMIT="2G" \
REALPATH_CACHE_SIZE="4096K" \
REALPATH_CACHE_TTL="600" \
XDEBUG_MODE="off" \
OPCACHE_ENABLE="1" \
OPCACHE_ENABLE_CLI="1" \
OPCACHE_MEMORY_CONSUMPTION="256" \
OPCACHE_INTERNED_STRINGS_BUFFER="8" \
OPCACHE_MAX_ACCELERATED_FILES="20000" \
OPCACHE_MAX_WASTED_PERCENTAGE="5" \
OPCACHE_USE_CWD="1" \
OPCACHE_VALIDATE_TIMESTAMPS="0" \
OPCACHE_REVALIDATE_FREQ="2" \
OPCACHE_REVALIDATE_PATH="0" \
OPCACHE_SAVE_COMMENTS="1" \
OPCACHE_RECORDS_WARNING="0" \
OPCACHE_ENABLE_FILE_OVERRIDE="0" \
OPCACHE_OPTIMIZATION_LEVEL="0x7FFFBFFF" \
OPCACHE_DUPS_FIX="0" \
OPCACHE_BLACKLIST_FILENAME="/etc/php/8.0/opcache-*.blacklist" \
OPCACHE_MAX_FILE_SIZE="0" \
OPCACHE_CONSISTENCY_CHECKS="0" \
OPCACHE_FORCE_RESTART_TIMEOUT="180" \
OPCACHE_ERROR_LOG="/var/log/opcache" \
OPCACHE_LOG_VERBOSITY_LEVEL="1" \
OPCACHE_PREFERRED_MEMORY_MODEL="" \
OPCACHE_PROTECT_MEMORY="0" \
OPCACHE_RESTRICT_API="" \
OPCACHE_MMAP_BASE="" \
OPCACHE_CACHE_ID="" \
OPCACHE_FILE_CACHE="/var/cache/opcache" \
OPCACHE_FILE_CACHE_ONLY="0" \
OPCACHE_FILE_CACHE_CONSISTENCY_CHECKS="1" \
OPCACHE_FILE_CACHE_FALLBACK="1" \
OPCACHE_HUGE_CODE_PAGE="1" \
OPCACHE_VALIDATE_PERMISSION="0" \
OPCACHE_VALIDATE_ROOT="0" \
OPCACHE_OPT_DEBUG_LEVEL="0" \
OPCACHE_PRELOAD="/var/www/html/config/preload.php" \
OPCACHE_PRELOAD_USER="rootless" \
OPCACHE_LOCKFILE_PATH="/var/lock/opcache" \
OPCACHE_JIT="1255" \
OPCACHE_JIT_BUFFER_SIZE="250MB"

RUN apt-get update \
&&  apt-get install -y --no-install-recommends \
software-properties-common \
apt-transport-https \
lsb-release \
ca-certificates \
gnupg \
gnupg1 \
gnupg2 \
wget \
git \
curl \
unzip

RUN set -eux; \
adduser -h /home/rootless -g 'rootless' -D -u 1000 rootless; \
echo 'rootless:65533:65534' >> /etc/subuid; \
echo 'rootless:65533:65534' >> /etc/subgid; \
echo 'rootless:rootless:65533:65534:/root:/bin' >> /etc/passwd; \
echo 'rootless::65533:rootless' >> /etc/group

RUN apt-get update \
&&  wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - \
&&  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update \
&&  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
supervisor \
nginx \
php8.0 \
php8.0-cli \
php8.0-fpm \
php8.0-common \
php8.0-bcmath \
php8.0-opcache \
php8.0-apcu \
php8.0-xdebug \
php8.0-curl \
php8.0-mbstring \
php8.0-mysql \
php8.0-xml \
php8.0-xsl \
php8.0-gd \
php8.0-intl \
php8.0-iconv \
php8.0-ftp \
php8.0-zip

RUN set -eux; \
rm -rf /etc/php/8.0/fpm/pool.d/*; \
rm -rf /etc/nginx/sites-available/*; \
rm -rf /etc/nginx/sites-enabled/*

COPY --chown=rootless:rootless server .

RUN set -eux; \
ln -sf \
/etc/php/8.0/90-php.ini \
/etc/php/8.0/cli/conf.d/90-php.ini; \
ln -sf \
/etc/php/8.0/90-php.ini \
/etc/php/8.0/fpm/conf.d/90-php.ini; \
ln -sf \
/etc/nginx/sites-available/symfony.conf \
/etc/nginx/sites-enabled/symfony.conf

RUN set -eux; \
mkdir -p /etc/supervisor; \
chmod 777 -R /etc/supervisor; \
chown rootless:rootless /etc/supervisor; \
mkdir -p /etc/php; \
chmod 777 -R /etc/php; \
chown rootless:rootless /etc/php; \
mkdir -p /etc/nginx; \
chmod 777 -R /etc/nginx; \
chown rootless:rootless /etc/nginx; \
mkdir -p /var/pid; \
chmod 777 -R /var/pid/; \
chown rootless:rootless /var/pid; \
mkdir -p /var/run; \
chmod 777 -R /var/run/; \
chown rootless:rootless /var/run; \
mkdir -p /var/lock; \
mkdir -p /var/lock/opcache; \
chmod 777 -R /var/lock/; \
chown rootless:rootless /var/lock; \
mkdir -p /var/log; \
mkdir -p /var/log/supervisor; \
chmod 777 -R -R /var/log; \
chown rootless:rootless /var/log; \
mkdir -p /var/cache; \
mkdir -p /var/cache/composer; \
mkdir -p /var/cache/opcache; \
chmod 777 -R /var/cache; \
chown rootless:rootless /var/cache; \
mkdir -p /var/lib; \
mkdir -p /var/lib/nginx; \
mkdir -p /var/lib/nginx/body; \
chmod 777 -R /var/lib; \
chown rootless:rootless /var/lib; \
mkdir -p /var/www/html; \
chmod 777 -R /var/www/html; \
chown rootless:rootless /var/www/html; \
mkdir -p /bin; \
chmod 777 -R /bin; \
chown rootless:rootless /bin; \
touch /dev/stdout; \
chmod 777 -R /dev/stdout; \
chown rootless:rootless /dev/stdout

RUN set -eux; \
rm -rf /etc/apt/sources.list.d/*; \
rm -f /var/www/html/*;

COPY --chown=rootless:rootless src /var/www/html

COPY --chown=rootless:rootless docker/* /usr/bin

RUN set -eux; \
chmod +x -R /usr/bin; \
chmod +x -R /usr/sbin; \
chmod +x -R /var/www/html/bin

WORKDIR /var/www/html

ENTRYPOINT ["docker-entrypoint"]

STOPSIGNAL SIGQUIT

EXPOSE 80

CMD ["supervisord"]

USER rootless
