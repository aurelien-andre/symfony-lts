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
PHP_MEMORY_LIMIT="2G" \
PHP_REALPATH_CACHE_SIZE="4096K" \
PHP_REALPATH_CACHE_TTL="600" \
PHP_XDEBUG_MODE="off" \
PHP_OPCACHE__ENABLE="1" \
PHP_OPCACHE__ENABLE_CLI="1" \
PHP_OPCACHE__MEMORY_CONSUMPTION="256" \
PHP_OPCACHE__INTERNED_STRINGS_BUFFER="8" \
PHP_OPCACHE__MAX_ACCELERATED_FILES="20000" \
PHP_OPCACHE__MAX_WASTED_PERCENTAGE="5" \
PHP_OPCACHE__USE_CWD="1" \
PHP_OPCACHE__VALIDATE_TIMESTAMPS="0" \
PHP_OPCACHE__REVALIDATE_FREQ="2" \
PHP_OPCACHE__REVALIDATE_PATH="0" \
PHP_OPCACHE__SAVE_COMMENTS="1" \
PHP_OPCACHE__RECORDS_WARNING="0" \
PHP_OPCACHE__ENABLE_FILE_OVERRIDE="0" \
PHP_OPCACHE__OPTIMIZATION_LEVEL="0x7FFFBFFF" \
PHP_OPCACHE__DUPS_FIX="0" \
PHP_OPCACHE__BLACKLIST_FILENAME="/etc/php/8.0/opcache-*.blacklist" \
PHP_OPCACHE__MAX_FILE_SIZE="0" \
PHP_OPCACHE__CONSISTENCY_CHECKS="0" \
PHP_OPCACHE__FORCE_RESTART_TIMEOUT="180" \
PHP_OPCACHE__ERROR_LOG="/var/log/opcache" \
PHP_OPCACHE__LOG_VERBOSITY_LEVEL="1" \
PHP_OPCACHE__PREFERRED_MEMORY_MODEL="" \
PHP_OPCACHE__PROTECT_MEMORY="0" \
PHP_OPCACHE__RESTRICT_API="" \
PHP_OPCACHE__MMAP_BASE="" \
PHP_OPCACHE__CACHE_ID="" \
PHP_OPCACHE__FILE_CACHE="/var/cache/opcache" \
PHP_OPCACHE__FILE_CACHE_ONLY="0" \
PHP_OPCACHE__FILE_CACHE_CONSISTENCY_CHECKS="1" \
PHP_OPCACHE__FILE_CACHE_FALLBACK="1" \
PHP_OPCACHE__HUGE_CODE_PAGE="1" \
PHP_OPCACHE__VALIDATE_PERMISSION="0" \
PHP_OPCACHE__VALIDATE_ROOT="0" \
PHP_OPCACHE__OPT_DEBUG_LEVEL="0" \
PHP_OPCACHE__PRELOAD="/var/www/html/config/preload.php" \
PHP_OPCACHE__PRELOAD_USER="rootless" \
PHP_OPCACHE__LOCKFILE_PATH="/var/lock/opcache" \
PHP_OPCACHE__JIT="" \
PHP_OPCACHE__JIT_BUFFER_SIZE="250MB"

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
