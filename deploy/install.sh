#!/bin/bash
set -euo pipefail

DOMAIN="crossnet.tech"
WEBROOT="/var/www/${DOMAIN}"
REPO="https://github.com/ghias70/crossnet-it-solutions.git"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this as root on the server."
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  if command -v dnf >/dev/null 2>&1; then dnf install -y git
  elif command -v yum >/dev/null 2>&1; then yum install -y git
  elif command -v apt-get >/dev/null 2>&1; then apt-get update && apt-get install -y git
  else
    echo "git is not installed."
    exit 1
  fi
fi

mkdir -p /var/www
if [[ -d "${WEBROOT}/.git" ]]; then
  git -C "${WEBROOT}" pull --ff-only
else
  rm -rf "${WEBROOT}"
  git clone --depth 1 "${REPO}" "${WEBROOT}"
fi
chmod -R a+rX "${WEBROOT}"

if [[ -d /etc/nginx/sites-available ]]; then
  CONF="/etc/nginx/sites-available/${DOMAIN}"
  mkdir -p /etc/nginx/sites-enabled
  ln -sfn "${CONF}" "/etc/nginx/sites-enabled/${DOMAIN}"
else
  mkdir -p /etc/nginx/conf.d
  CONF="/etc/nginx/conf.d/${DOMAIN}.conf"
fi

cat > "${CONF}" <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name crossnet.tech www.crossnet.tech;
    root /var/www/crossnet.tech;
    index index.html;

    location ~ /\. {
        deny all;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF

if command -v getenforce >/dev/null 2>&1 && [[ "$(getenforce)" == "Enforcing" ]]; then
  chcon -R -t httpd_sys_content_t "${WEBROOT}" || true
fi

nginx -t
systemctl reload nginx

if command -v certbot >/dev/null 2>&1; then
  certbot --nginx -d crossnet.tech -d www.crossnet.tech --non-interactive --agree-tos --register-unsafely-without-email --redirect
else
  echo "nginx is serving http://${DOMAIN}. Install certbot to add HTTPS."
fi

echo "Crossnet is deployed for ${DOMAIN}"
