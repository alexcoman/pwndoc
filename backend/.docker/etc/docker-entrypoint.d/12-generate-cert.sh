#!/bin/sh
set -eu

_ensure_dir(){
    local dir_path=$1;
    if [ ! -d "${dir_path}" ]; then
        mkdir -p "${dir_path}"
    fi
}

_generate_cert(){
    local target=$1
    local cert_cn=$2
    local cert_days=$3

    if [ -f "${CERT_DIR}/${target}/.renew" ]; then
        rm -f "${CERT_DIR}/${target}/*"
    fi

    _ensure_dir "${CERT_DIR}/${target}"
    if [ ! -s "${CERT_DIR}/${target}/cert.pem" ]; then
        openssl req -new -newkey rsa:4096 -x509 -sha256 -nodes \
            -days "${cert_days}"  \
            -subj "/CN=${cert_cn}" \
            -out "${CERT_DIR}/${target}/cert.pem" \
            -keyout "${CERT_DIR}/${target}/key.pem"
    fi
}

_generate_cert 'backend' 'api.pwndoc' '365'
