#!/bin/bash

# Create main directories
mkdir -p .github/workflows
mkdir -p grafana/dashboards
mkdir -p grafana/provisioning/dashboards
mkdir -p grafana/provisioning/datasources
mkdir -p migrations
mkdir -p postman
mkdir -p prometheus
mkdir -p traefik/config
mkdir -p vault-setup

# Create files
touch .github/workflows/deploy-dev.yml
touch .gitignore
touch .env.example
touch Makefile
touch README.md
touch docker-compose.local.yml
touch docker-compose.prod.yml
touch grafana/dashboards/golden-signals-dashboard.json
touch grafana/provisioning/dashboards/dashboard-provider.yml
touch grafana/provisioning/datasources/datasources.yml
touch migrations/000001_create_users_table.down.sql
touch migrations/000001_create_users_table.up.sql
touch migrations/000016_add_soft_delete_to_files.up.sql
touch postman/Prism\ Enterprise\ Services.postman_collection.json
touch postman/POSTMAN_GUIDE.md
touch prometheus/prometheus.yml
touch traefik/config/dynamic.yml
touch traefik/traefik.yml
touch vault-setup/Dockerfile
touch vault-setup/setup.sh

# Make setup.sh executable
chmod +x vault-setup/setup.sh

echo "Directory structure created successfully!"
