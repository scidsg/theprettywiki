#!/bin/bash

# Welcome message and ASCII art
cat << "EOF"
████████ ██   ██ ███████     ██████  ██████  ███████ ████████ ████████ ██    ██     ██     ██ ██ ██   ██ ██ 
   ██    ██   ██ ██          ██   ██ ██   ██ ██         ██       ██     ██  ██      ██     ██ ██ ██  ██  ██ 
   ██    ███████ █████       ██████  ██████  █████      ██       ██      ████       ██  █  ██ ██ █████   ██ 
   ██    ██   ██ ██          ██      ██   ██ ██         ██       ██       ██        ██ ███ ██ ██ ██  ██  ██ 
   ██    ██   ██ ███████     ██      ██   ██ ███████    ██       ██       ██         ███ ███  ██ ██   ██ ██ 
                                                                                                            
The Pretty Wiki is a free self-hosted publishing platform that makes owning your creative content a no brainer.
                                                            
https://thepretty.wiki
https://try.thepretty.wiki

EOF
sleep 3

# Download Science & Design brand resources
cd /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/
mkdir custom
cd custom/
git clone https://github.com/scidsg/brand-resources.git
mv brand-resources/fonts  .
rm -r brand-resources/

# Activate New Skin
file="/var/www/html/mediawiki/LocalSettings.php"
backup_file="/var/www/html/mediawiki/LocalSettings.php.bak"

# Create a backup of the original file
cd /var/www/html/mediawiki/
cp "$file" "$backup_file"

# Enable The Pretty Wiki
sed -i 's/\$wgDefaultSkin = "vector";/\$wgDefaultSkin = "vector-2022";/g' "$file"

# Mobile enablement and enhancements 
echo "Adding viewport meta tag, theme-color, and favicons to LocalSettings.php..."
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/favicon.ico
mkdir images/ images/favicon/
cd images/favicon/
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/images/favicon/android-chrome-192x192.png
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/images/favicon/android-chrome-512x512.png
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/images/favicon/apple-touch-icon.png
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/images/favicon/favicon-16x16.png
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/images/favicon/favicon-32x32.png
cat >> /var/www/html/mediawiki/LocalSettings.php << EOL
\$wgHooks["BeforePageDisplay"][] = "addViewportMetaTag";
function addViewportMetaTag( \$out, \$skin ) {
    \$out->addHeadItem( "viewport", "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" );
    \$out->addHeadItem( "theme-color", "<meta name=\"theme-color\" content=\"#333\">" );
    \$out->addHeadItem( "apple-touch-icon", "<link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"/images/favicon/apple-touch-icon.png\">" );
    \$out->addHeadItem( "favicon-32x32", "<link rel=\"icon\" type=\"image/png\" href=\"/images/favicon/favicon-32x32.png\" sizes=\"32x32\">" );
    \$out->addHeadItem( "favicon-16x16", "<link rel=\"icon\" type=\"image/png\" href=\"/images/favicon/favicon-16x16.png\" sizes=\"16x16\">" );
    \$out->addHeadItem( "android-chrome-192x192", "<link rel=\"icon\" type=\"image/png\" href=\"/images/favicon/android-chrome-192x192.png\" sizes=\"192x192\">" );
    \$out->addHeadItem( "android-chrome-512x512", "<link rel=\"icon\" type=\"image/png\" href=\"/images/favicon/android-chrome-512x512.png\" sizes=\"512x512\">" );
    return true;
}
EOL

# Back up Vector Skin
cd /var/www/html/mediawiki/skins
cp -r Vector/ Vector-Backup/

# Back up current less file
cd Vector/resources/skins.vector.styles/
mv skin.less old-skin.less
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/skin.less


# Create custom styles
cd custom/
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/custom.less
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/ddos.less
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/homepage.css

# Create custom homepage
cd /var/www/html/mediawiki/extensions/
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/homepage.php

# Append LocalSettings
cd /var/www/html/mediawiki
echo 'require_once "$IP/extensions/homepage.php";' >> LocalSettings.php
echo '$wgEnableAPI = true;' >> LocalSettings.php
