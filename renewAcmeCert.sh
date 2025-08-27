#!/bin/bash

# import environment 
if [ -f .env ]; then
    source .env
else
    echo ".env file does not exist.  Please see .env.example for guidance"
    exit 1
fi

export PATH=${PATH}:${ACME_DIR}:${BASE_DIR}
chmod +x ${ACME_DIR}/acme.sh
mkdir -p ${CERT_DIR}

mkdir -p ${CERT_DIR}

if [ -d "$CERT_DIR" ]; then
    # Renew certificate
    acme.sh --renew -d ${DOMAIN_NAME}
else
    # Issue new certificate
    acme.sh --issue -k 4096 -ak 4096 --server letsencrypt --force --dns ${ACME_DEPLOY_HOOK} --cert-file "${CERT_FILE}" --key-file "${KEY_FILE}" --ca-file "${CA_FILE}" --fullchain-file "${FULLCHAIN_FILE}" -d ${DOMAIN_NAME}
fi

# Package certificate
openssl pkcs12 -export -out ${PFX_FILE} -passout pass:${PFX_PASSWORD} -inkey ${KEY_FILE} -in ${CERT_FILE}

# Deploy certificate
status=$(curl -ks -u "$PRINTER_USERNAME:$PRINTER_PASSWORD" \
  -F "certificate=@${PFX_FILE}" \
  -F "password=${PFX_PASSWORD}" \
  -w "%{http_code}" \
  "https://${DOMAIN_NAME}/Security/DeviceCertificates/NewCertWithPassword/Upload")

if [ "$status" != "201" ]; then
    echo "Error (Status Code: $status)"
    exit 1
fi
