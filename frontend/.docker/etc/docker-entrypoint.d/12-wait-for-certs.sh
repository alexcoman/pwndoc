#!/bin/sh

until [ -s "${TLS_CERT_FILE}" ] && [ -s "${TLS_KEY_FILE}" ]; do
    echo 'Waiting for the certificates.';
    sleep 1;
done
