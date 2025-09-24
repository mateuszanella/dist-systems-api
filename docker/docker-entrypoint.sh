#!/bin/bash
set -e

# Wait for MySQL to be ready
echo "Waiting for MySQL..."
while ! nc -z mysql 3306; do
  sleep 1
done
echo "MySQL is up - executing command"

cd /var/www/html

# Copy environment file if not exists
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Install dependencies if vendor directory doesn't exist
if [ ! -d vendor ]; then
    composer install --no-interaction --no-progress --prefer-dist
fi

# Generate application key if not set
php artisan key:generate --no-interaction --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Execute passed command
exec "$@"