FROM ruby:3.2.2-slim

# Installer les dépendances système nécessaires
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    nodejs \
    npm \
    git \
    curl \
    libvips \
    && rm -rf /var/lib/apt/lists/*

# Installer Yarn
RUN npm install -g yarn

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances
COPY web/Gemfile web/Gemfile.lock ./

# Installer les gems
RUN bundle install --jobs 4

# Copier le reste de l'application
COPY web/ .

# Installer les dépendances JavaScript
RUN yarn install

# Précompiler les assets pour la production
RUN SECRET_KEY_BASE=placeholder RAILS_ENV=production bundle exec rails assets:precompile

# Exposer le port pour l'application Rails
EXPOSE 3000

# Ajouter un script d'entrée pour attendre que la base de données soit prête
COPY web/docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Commande pour démarrer l'application Rails
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]