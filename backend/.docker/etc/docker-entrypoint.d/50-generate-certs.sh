#!/bin/sh
set -eu

_ensure_dir(){
    local dir_path=$1;
    if [ ! -d "${dir_path}" ]; then
        mkdir -p "${dir_path}"
    fi
}

_ensure_pkey(){
    local key_path=$1
    if [ ! -s "${key_path}" ]; then
        openssl genrsa -out "${key_path}" 4096 &> /dev/null
    fi
}

_generate_cert(){
    local target=$1
    local cert_cn=$2
    local cert_days=$3

    _ensure_dir "${CERT_DIR}/${target}"
    _ensure_pkey "${CERT_DIR}/${target}/key.pem"

    if [ ! -s "${CERT_DIR}/${target}/cert.pem" ]; then
        openssl req -new \
            -key "${CERT_DIR}/${target}/key.pem" \
            -out "${CERT_DIR}/${target}/csr.pem" \
            -subj "/CN=${cert_cn}" &> /dev/null
        openssl x509 -req \
            -in "${CERT_DIR}/${target}/csr.pem" \
            -CA "${CERT_DIR}/ca/cert.pem" \
            -CAkey "${CERT_DIR}/ca/key.pem" \
            -CAcreateserial \
            -out "${CERT_DIR}/${target}/cert.pem" \
            -days "365"  &> /dev/null
        openssl verify -CAfile "${CERT_DIR}/ca/cert.pem" "${CERT_DIR}/${target}/cert.pem"
    fi
}

_generate_certs() {
    # Note: Do not use a value greater than 825. More details on the following url:
    #       https://github.com/FiloSottile/mkcert/issues/174
    local cert_days='800'

    _ensure_dir "${CERT_DIR}/ca"
    _ensure_pkey "${CERT_DIR}/ca/key.pem"
    if [ ! -s "${CERT_DIR}/ca/cert.pem" ]; then
        openssl req -new -key "${CERT_DIR}/ca/key.pem" \
            -out "${CERT_DIR}/ca/cert.pem" \
            -subj '/CN=Pwndoc Internal CA' \
            -x509 -days "${cert_days}" &> /dev/null
    fi

    _generate_cert 'backend' 'api.pwndoc' "${cert_days}"
    _generate_cert 'frontend' 'pwndoc' "${cert_days}"
}

_generate_certs
