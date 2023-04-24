#!/bin/bash

# Welcome message and ASCII art
cat << "EOF"
████████  ██████  ██████  ██ ███████ ██    ██ 
   ██    ██    ██ ██   ██ ██ ██       ██  ██  
   ██    ██    ██ ██████  ██ █████     ████   
   ██    ██    ██ ██   ██ ██ ██         ██    
   ██     ██████  ██   ██ ██ ██         ██    
                                              
🧅 Make your wiki available as an onion site.
                                                            
https://thepretty.wiki
https://try.thepretty.wiki

EOF
sleep 3

# Update the system
sudo apt update
sudo apt -y upgrade
sudo apt -y autoremove

# Install Tor
sudo apt install -y tor

# Configure Tor to create a new onion service
sudo bash -c 'cat >> /etc/tor/torrc << EOL
HiddenServiceDir /var/lib/tor/mediawiki_onion_service/
HiddenServicePort 80 127.0.0.1:8080
EOL'

# Configure Apache to listen on the local IP and the onion service port
sudo bash -c 'cat >> /etc/apache2/ports.conf << EOL
Listen 127.0.0.1:8080
EOL'

# Create a new Apache configuration file for the onion service
sudo bash -c 'cat > /etc/apache2/sites-available/mediawiki_onion.conf << EOL
<VirtualHost 127.0.0.1:8080>
    ServerName localhost
    DocumentRoot /var/www/html/mediawiki
    <Directory /var/www/html/mediawiki/>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL'

# Enable the onion service configuration and restart Apache
sudo a2ensite mediawiki_onion

# Restart Apache and Tor
sudo systemctl restart apache2
sudo systemctl restart tor

# Retrieve the onion service hostname
sleep 10
onion_hostname=$(sudo cat /var/lib/tor/mediawiki_onion_service/hostname)

# Update MediaWiki's LocalSettings.php to use the onion hostname
sudo bash -c "echo -e \"\\\$wgServer = 'http://$onion_hostname';\" >> /var/www/html/mediawiki/LocalSettings.php"

# Display the onion service URL
function display_service_status() {
    local tor_status=$(systemctl is-active tor)
    local apache_status=$(systemctl is-active apache2)

    if [[ $tor_status == "active" && $apache_status == "active" ]]; then
        echo -e "\033[32m●\033[0m The MediaWiki Tor onion service is running."
    else
        echo -e "\033[31m●\033[0m The MediaWiki Tor onion service is not running."
    fi

    local onion_hostname=$(sudo cat /var/lib/tor/mediawiki_onion_service/hostname 2>/dev/null)
    if [[ -n $onion_hostname ]]; then
        echo "Onion address: http://${onion_hostname}"
    else
        echo "Onion address not found."
    fi
}

# Wait a few seconds for the onion service to start
sleep 5
display_service_status

cat << 'EOL' >> ~/.bashrc
function display_service_status() {
    local tor_status=$(systemctl is-active tor)
    local apache_status=$(systemctl is-active apache2)

    if [[ $tor_status == "active" && $apache_status == "active" ]]; then
        echo -e "\033[32m●\033[0m The MediaWiki Tor onion service is running."
    else
        echo -e "\033[31m●\033[0m The MediaWiki Tor onion service is not running."
    fi

    local onion_hostname=$(sudo cat /var/lib/tor/mediawiki_onion_service/hostname 2>/dev/null)
    if [[ -n $onion_hostname ]]; then
        echo "Onion address: http://${onion_hostname}"
    else
        echo "Onion address not found."
    fi
}
display_service_status
EOL
