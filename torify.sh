#!/bin/bash

# Install Tor
sudo apt install -y tor

# Configure Tor for onion service
sudo bash -c 'cat >> /etc/tor/torrc << EOL
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:80
EOL'

# Restart Tor to apply the configuration
sudo systemctl restart tor

# Wait for the onion service to be created
sleep 10

# Get the onion service address
onion_address=$(sudo cat /var/lib/tor/hidden_service/hostname)

# Edit mediawiki-onion.conf with the onion address
sudo bash -c "cat > /etc/nginx/sites-available/mediawiki-onion << EOL
server {
    listen 80;
    server_name ${onion_address};

    root /var/www/html/mediawiki;
    index index.php;

    location / {
        try_files \$uri \$uri/ @mediawiki;
    }

    location @mediawiki {
        rewrite ^/([^?]*)(?:\?(.*))? /index.php?title=\$1&\$2 last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOL"

# Enable the mediawiki-onion site and reload the Nginx configuration
sudo ln -s /etc/nginx/sites-available/mediawiki-onion /etc/nginx/sites-enabled/
sudo systemctl reload nginx

# Print the onion service address
echo "Your MediaWiki onion service is available at: ${onion_address}"
