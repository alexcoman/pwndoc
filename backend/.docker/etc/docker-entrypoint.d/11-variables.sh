#!/bin/sh

# Web Server Configuration

# HOST is the IP address on which the server shoud bind to.
export HOST=${HOST:-0.0.0.0}

# PORT is refering to the port on which the Pwndoc backend will listen.
export PORT=${PORT:-4242}

# CERT_DIR is the directory that stores certificates required for the current
# container (normally should be a volume).
export CERT_DIR=${CERT_DIR:-/certs}

# SSL_CERT_FILE is the absolute path to the certificate file
export SSL_CERT_FILE=${SSL_CERT_FILE:-/certs/backend/cert.pem}

# SSL_KEY_FILE is the absolute path to the key file
export SSL_KEY_FILE=${SSL_KEY_FILE:-/certs/backend/key.pem}

# MongoDB Configuration

# DB_HOST is the fully qualified domain name (FQDN), hostname or the IP address
# of the MongoDB database.
export DB_HOST=${DB_HOST:-mongodb}

# DB_PORT is the MongoDB exposed port.
export DB_PORT=${DB_PORT:-27017}

# DB_NAME is the name of the database used by the Pwndoc project.
export DB_NAME=${DB_NAME:-pwndoc}
