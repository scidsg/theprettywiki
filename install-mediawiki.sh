#!/bin/bash

# Update the system
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y autoremove

# Install necessary packages
sudo apt install -y nginx php-fpm mariadb-server php-mysql php-xml php-mbstring php-apcu php-intl imagemagick php-gd php-cli curl php-curl git whiptail libnginx-mod-http-geoip geoip-database

# Get the latest MediaWiki version and tarball URL
MW_TARBALL_URL=$(curl -s https://www.mediawiki.org/wiki/Download | grep -oP '(?<=href=")[^"]+(?=\.tar\.gz")' | head -1)
MW_VERSION=$(echo $MW_TARBALL_URL | grep -oP '(?<=mediawiki-)[^/]+')

# Download MediaWiki
wget -O mediawiki-${MW_VERSION}.tar.gz "${MW_TARBALL_URL}.tar.gz"
tar xvzf mediawiki-${MW_VERSION}.tar.gz

# Move MediaWiki to the web server directory
sudo mv mediawiki-${MW_VERSION} /var/www/html/mediawiki

# Set appropriate permissions
sudo chown -R www-data:www-data /var/www/html/mediawiki
sudo chmod -R 755 /var/www/html/mediawiki

# Create a MediaWiki Nginx configuration file
sudo bash -c 'cat > /etc/nginx/sites-available/pretty.nginx << EOL
server {
    listen 80;
    server_name localhost;
    location / {
        location / {
        root /var/www/html/mediawiki;
        try_files \$uri \$uri/ @mediawiki;
        proxy_pass http://127.0.0.1:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
    
        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header Content-Security-Policy "default-src 'self'; frame-ancestors 'none'";
        add_header Permissions-Policy "geolocation=(), midi=(), notifications=(), push=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), speaker=(), vibrate=(), fullscreen=(), payment=(), interest-cohort=()";
        add_header Referrer-Policy "no-referrer";
        add_header X-XSS-Protection "1; mode=block";
}

EOL'

# Enable the MediaWiki site and disable the default site
sudo ln -s /etc/nginx/sites-available/pretty.nginx /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Configure Nginx with privacy-preserving logging
cat > /etc/nginx/nginx.conf << EOL
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events {
        worker_connections 768;
        # multi_accept on;
}
http {
        ##
        # Basic Settings
        ##
        sendfile on;
        tcp_nopush on;
        types_hash_max_size 2048;
        # server_tokens off;
        # server_names_hash_bucket_size 64;
        # server_name_in_redirect off;
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        ##
        # SSL Settings
        ##
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;
        ##
        # Logging Settings
        ##
        # access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
        ##
        # Gzip Settings
        ##
        gzip on;
        # gzip_vary on;
        # gzip_proxied any;
        # gzip_comp_level 6;
        # gzip_buffers 16 8k;
        # gzip_http_version 1.1;
        # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
        ##
        # Virtual Host Configs
        ##
        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
        ##
        # Enable privacy preserving logging
        ##
        geoip_country /usr/share/GeoIP/GeoIP.dat;
        log_format privacy '0.0.0.0 - \$remote_user [\$time_local] "\$request" \$status \$body_bytes_sent "\$http_referer" "-" \$geoip_country_code';
        access_log /var/log/nginx/access.log privacy;
}
EOL

sudo ln -sf /etc/nginx/sites-available/pretty.nginx /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx

if [ -e "/etc/nginx/sites-enabled/default" ]; then
    rm /etc/nginx/sites-enabled/default
fi
ln -sf /etc/nginx/sites-available/pretty.nginx /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx || error_exit

# Restart Nginx
sudo systemctl restart nginx

# Get user input using whiptail
db_name=$(whiptail --inputbox "Please enter your desired database name for MediaWiki:" 8 78 --title "Database Name" 3>&1 1>&2 2>&3)
db_user=$(whiptail --inputbox "Please enter your desired database username for MediaWiki:" 8 78 --title "Database Username" 3>&1 1>&2 2>&3)
db_pass=$(whiptail --passwordbox "Please enter your desired database password for MediaWiki:" 8 78 --title "Database Password" 3>&1 1>&2 2>&3)

# Create the database and user
sudo mysql -e "CREATE DATABASE \`${db_name}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Done
echo "MediaWiki has been installed."
