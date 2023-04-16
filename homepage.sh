#!/bin/bash 

cat > /var/www/html/mediawiki/extensions/homepage.php << EOL
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
  <div class="column" id="most-viewed">
    <h2>Most Viewed</h2>
    <ul>
      <!-- Populate this list using JavaScript -->
    </ul>
  </div>
  <div class="column" id="recent-articles">
    <h2>Recent</h2>
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
HTML;

        $output->addHTML($content);

        // Prevent further processing
        $mediaWiki->restInPeace();
        return false;
    }

    return true;
}
EOL

cat > /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/homepage.js << EOL
const apiEndpoint = "/api.php";

async function fetchPopularArticles() {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&list=querypage&qppage=Mostlinked&qpoffset=0&qplimit=10&formatversion=2&origin=*`  
  );
  const data = await response.json();
  const articles = data.query.querypage.results;
  const popularArticlesList = document.querySelector("#most-viewed ul");

  articles.forEach((article) => {
    const listItem = document.createElement("li");
    listItem.textContent = article.title;
    popularArticlesList.appendChild(listItem);
  });
}

async function fetchRecentArticles() {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&list=querypage&qppage=Mostlinked&qpoffset=0&qplimit=10&formatversion=2&origin=*`  
  );
  const data = await response.json();
  const articles = data.query.recentchanges;
  const recentArticlesList = document.querySelector("#recent-articles ul");

  articles.forEach((article) => {
    const listItem = document.createElement("li");
    listItem.textContent = article.title;
    recentArticlesList.appendChild(listItem);
  });
}

async function fetchRecentlyEditedArticles() {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&list=querypage&qppage=Mostlinked&qpoffset=0&qplimit=10&formatversion=2&origin=*`
    );
  const data = await response.json();
  const articles = data.query.recentchanges;
  const recentlyEditedArticlesList = document.querySelector("#recently-edited ul");

  articles.forEach((article) => {
    const listItem = document.createElement("li");
    listItem.textContent = article.title;
    recentlyEditedArticlesList.appendChild(listItem);
  });
}

function fetchHomepageContent() {
  fetchPopularArticles();
  fetchRecentArticles();
  fetchRecentlyEditedArticles();
}

document.addEventListener("DOMContentLoaded", () => {
  createCategoryFilterLinks();
  fetchHomepageContent();
});

EOL

cat > /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/homepage.css << EOL
#custom-homepage {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  margin: 20px 0;
}

.category-filters {
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 20px;
}

.category-filters a {
  background-color: #333;
  color: #fff;
  padding: 6px 12px;
  border-radius: 4px;
  text-decoration: none;
}

.column {
  flex: 1;
}

.column h2 {
  margin-bottom: 10px;
  font-size: 1.5rem;
}

.column ul {
  list-style-type: none;
  padding: 0;
}

.column li {
  margin-bottom: 5px;
}

#recent-articles li:first-child {
  font-size: 1.2em;
}

/* Responsive styles */
@media (max-width: 768px) {
  #custom-homepage {
    flex-direction: column;
  }
}
EOL

# Append LocalSettings
cd /var/www/html/mediawiki
echo 'require_once "$IP/extensions/homepage.php";' >> LocalSettings.php
echo '$wgEnableAPI = true;' >> LocalSettings.php