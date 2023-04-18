#!/bin/bash 

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root. Use 'sudo' to run it."
  exit 1
fi

# Create the homepage.php file
echo "Creating homepage.php..."
cat > /var/www/html/mediawiki/extensions/homepage.php << 'EOF'
<?php

$wgHooks['MediaWikiPerformAction'][] = 'onMediaWikiPerformAction';

function onMediaWikiPerformAction($output, $article, $title, $user, $request, $mediaWiki) {
    if ($title->isMainPage()) {
        global $wgScriptPath;

        // Load custom CSS
        $output->addStyle("$wgScriptPath/skins/Vector/resources/skins.vector.styles/custom/homepage.css");

        // Load custom JavaScript
        $output->addScriptFile("$wgScriptPath/skins/Vector/resources/skins.vector.styles/custom/homepage.js");

        // Add custom homepage content
        $content = <<<HTML
<div id="custom-homepage">
  <div class="category-filters"></div>
  <div class="columnGroup">
    <div class="column" id="most-viewed">
      <h2>Most Viewed</h2>
      <ul>
        <!-- Populate this list using JavaScript -->
      </ul>
    </div>
    <div class="column" id="recent-articles">
      <h2>Recently Published</h2>
      <ul>
        <!-- Populate this list using JavaScript -->
      </ul>
    </div>
    <div class="column" id="recently-edited">
      <h2>Recently Edited</h2>
      <ul>
        <!-- Populate this list using JavaScript -->
      </ul>
    </div>
  </div>
</div>
HTML;

        $output->addHTML($content);

        // Prevent further processing
        $mediaWiki->restInPeace();
        return false;
    }

    return true;
}
EOF

# Create the homepage.css file
echo "Creating homepage.css..."
cat > /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/homepage.css << 'EOF'
#custom-homepage .columnGroup {
  display: flex;
  justify-content: space-between;
}

#custom-homepage .column {
  flex: 1;
  margin: 0 10px;
}

#custom-homepage .column h2 {
  text-align: center;
}

#custom-homepage .category-filters {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  margin-bottom: 20px;
}

#custom-homepage .category-filters a {
  padding: 5px 10px;
  background-color: #f8f9fa;
  border: 1px solid #eaecf0;
  margin

EOF

# Create the homepage.js file
echo "Creating homepage.js..."
cat > /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/homepage.js << 'EOF'
function apiUrl(params) {
  const queryParams = new URLSearchParams(params).toString();
  return `/api.php?${queryParams}&format=json`;
}

async function fetchApiData(params) {
  const url = apiUrl(params);
  const response = await fetch(url);
  return await response.json();
}

async function loadCategories() {
  const params = {
    action: 'query',
    list: 'allcategories',
    aclimit: 10,
  };
  const data = await fetchApiData(params);
  const categories = data.query.allcategories;

  const categoryFilters = document.querySelector('.category-filters');
  categories.forEach(category => {
    const link = document.createElement('a');
    link.href = `/Category:${encodeURIComponent(category['*'])}`;
    link.textContent = category['*'];
    categoryFilters.appendChild(link);
  });
}

async function loadMostViewed() {
  const params = {
    action: 'query',
    list: 'mostviewed',
    pvilimit: 5,
  };
  const data = await fetchApiData(params);
  const mostViewed = data.query.mostviewed;

  const mostViewedEl = document.querySelector('#most-viewed ul');
  mostViewed.forEach(article => {
    const listItem = document.createElement('li');
    listItem.textContent = article.title;
    mostViewedEl.appendChild(listItem);
  });
}

async function loadRecentlyPublished() {
  const params = {
    action: 'query',
    list: 'recentchanges',
    rcshow: '!minor',
    rctype: 'new',
    rcnamespace: 0,
    rclimit: 5,
  };
  const data = await fetchApiData(params);
  const recentlyPublished = data.query.recentchanges;

  const recentlyPublishedEl = document.querySelector('#recent-articles ul');
  recentlyPublished.forEach(article => {
    const listItem = document.createElement('li');
    listItem.textContent = article.title;
    recentlyPublishedEl.appendChild(listItem);
  });
}

async function loadRecentlyEdited() {
  const params = {
    action: 'query',
    list: 'recentchanges',
    rcshow: '!minor',
    rctype: 'edit',
    rcnamespace: 0,
    rclimit: 5,
  };
  const data = await fetchApiData(params);
  const recentlyEdited = data.query.recentchanges;

  const recentlyEditedEl = document.querySelector('#recently-edited ul');
  recentlyEdited.forEach(article => {
    const listItem = document.createElement('li');
    listItem.textContent = article.title;
    recentlyEditedEl.appendChild(listItem);
  });
}

EOF

# Append LocalSettings
echo "Updating LocalSettings.php..."
cd /var/www/html/mediawiki
echo 'require_once "$IP/extensions/homepage.php";' >> LocalSettings.php
echo '$wgEnableAPI = true;' >> LocalSettings.php

echo "Homepage installation complete."