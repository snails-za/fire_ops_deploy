#!/bin/sh
set -eu

HOST_NAME="${1:-}"

if [ -z "$HOST_NAME" ]; then
  echo "Usage: $0 <domain-or-ip>"
  echo "Example: $0 192.168.101.155"
  echo "Example: $0 admin.example.com"
  exit 1
fi

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CERT_DIR="$SCRIPT_DIR/data/front_html"
KEY_FILE="$CERT_DIR/private.key"
CERT_FILE="$CERT_DIR/cert.pem"
OPENSSL_CONF="$(mktemp)"

mkdir -p "$CERT_DIR"

if printf '%s' "$HOST_NAME" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
  ALT_NAME="IP:$HOST_NAME"
else
  ALT_NAME="DNS:$HOST_NAME"
fi

cat > "$OPENSSL_CONF" <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = $HOST_NAME

[v3_req]
subjectAltName = $ALT_NAME
EOF

openssl req \
  -x509 \
  -nodes \
  -days 3650 \
  -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CERT_FILE" \
  -config "$OPENSSL_CONF"

rm -f "$OPENSSL_CONF"

echo "Generated:"
echo "  $CERT_FILE"
echo "  $KEY_FILE"
