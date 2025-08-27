#!/bin/bash

# import environment 
if [ -f .env ]; then
    source .env
else
    echo ".env file does not exist.  Please see .env.example for guidance"
    exit 1
fi

# Main
export PATH=${PATH}:${_ACME_DIR}:${_BASE_DIR}
chmod +x ${_ACME_DIR}/acme.sh
mkdir -p ${_CERT_DIR}

# Main
mkdir -p ${_CERT_DIR}

if [ -d "$_CERT_DIR" ]; then
    # Renew certificate
    acme.sh --renew -d ${_DOMAIN_NAME}
else
    # Issue new certificate
    acme.sh --issue -k 4096 -ak 4096 --server letsencrypt --force --dns dns_namecheap --cert-file "${_CERT_FILE}" --key-file "${_KEY_FILE}" --ca-file "${_CA_FILE}" --fullchain-file "${_FULLCHAIN_FILE}" -d ${_DOMAIN_NAME}
fi

# Package certificate
openssl pkcs12 -export -out ${_PFX_FILE} -passout pass:${PFX_PASSWORD} -inkey ${_KEY_FILE} -in ${_CERT_FILE}

# Deploy certificate
status=$(curl -ks -u "$PRINTER_USERNAME:$PRINTER_PASSWORD" \
  -F "certificate=@${_PFX_FILE}" \
  -F "password=${PFX_PASSWORD}" \
  -w "%{http_code}" \
  "https://${_DOMAIN_NAME}/Security/DeviceCertificates/NewCertWithPassword/Upload")

if [ "$status" != "201" ]; then
    echo "Error (Status Code: $status)"
    exit 1
fi
