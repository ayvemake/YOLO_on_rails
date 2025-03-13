#!/bin/bash
set -e

# Attendre que PostgreSQL soit prêt
until PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c '\q'; do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

>&2 echo "PostgreSQL is up - executing command"

# Exécuter les migrations si nécessaire
if [ "${RAILS_ENV}" = "production" ]; then
  bundle exec rails db:migrate
fi

# Exécuter la commande fournie
exec "$@"