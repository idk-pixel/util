#!/bin/bash
# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use 'sudo' or switch to the root user."
   exit 1
fi
# Simple upgrades
apt update && apt upgrade -y && apt install curl -y
# Install panel
curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | sudo bash
sudo apt-get install pufferpanel
sudo systemctl enable pufferpanel
# Install nginx
sudo apt-get install nginx
# Create Nginx configuration file
echo 'server {
    listen 80;
    root /var/www/pufferpanel;
    server_name panel.examplehost.com;
    location ~ ^/\.well-known {
        root /var/www/html;
        allow all;
    }
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Nginx-Proxy true;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        client_max_body_size 100M;
    }
}' > /etc/nginx/sites-available/pufferpanel.conf
# Reload Nginx configuration
sudo systemctl reload nginx
