#!/bin/sh

# Web Server Configuration

# HTTP_PORT is the port used by nginx for HTTP connections
export HTTP_PORT=${PORT:-8080}

# HTTPS_PORT is the port used by nginx for HTTPS connections
export HTTPS_PORT=${PORT:-8443}

# CERT_DIR is the directory that stores certificates required for the current
# container (normally should be a volume).
export CERT_DIR=${CERT_DIR:-/certs}

# SSL_CERT_FILE is the absolute path to the certificate file
export SSL_CERT_FILE=${SSL_CERT_FILE:-/certs/frontend/cert.pem}

# SSL_KEY_FILE is the absolute path to the key file
export SSL_KEY_FILE=${SSL_KEY_FILE:-/certs/frontend/key.pem}
