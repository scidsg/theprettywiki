#!/bin/bash 

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
  <div class="category-filters">
    <a href="#" data-category="all" class="active">All</a>
    <a href="#" data-category="technology">Technology</a>
    <a href="#" data-category="science">Science</a>
    <a href="#" data-category="history">History</a>
    <a href="#" data-category="culture">Culture</a>
  </div>
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
EOF

cat > /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/homepage.js << 'EOF'
const apiEndpoint = "/api.php";

async function fetchArticleSnippet(title) {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&prop=extracts|info&titles=${encodeURIComponent(title)}&exsentences=1&explaintext=1&inprop=url|displaytitle|created|modified&formatversion=2&origin=*`
  );
  const data = await response.json();
  const pages = data.query.pages;
  const pageInfo = pages[0];

  return {
    title: pageInfo.title,
    firstSentence: pageInfo.extract,
    lastModified: new Date(pageInfo.modified),
  };
}

async function populateArticleList(listElement, articles) {
  for (const article of articles) {
    const snippet = await fetchArticleSnippet(article.title);
    const listItem = document.createElement("li");
    listItem.innerHTML = `
      <h3>${snippet.title}</h3>
      <p>${snippet.firstSentence}</p>
      <small>Last modified: ${snippet.lastModified.toLocaleDateString()}</small>
    `;
    listElement.appendChild(listItem);
  }
}

async function fetchPopularArticles() {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&list=querypage&qppage=Mostviewed&qpoffset=0&qplimit=10&formatversion=2&origin=*`
  );
  const data = await response.json();
  console.log("fetchPopularArticles data:", data); // Log the data
  const articles = data.query.querypage.results;
  const popularArticlesList = document.querySelector("#most-viewed ul");

  populateArticleList(popularArticlesList, articles);
}

async function fetchRecentArticles() {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&list=recentchanges&rclimit=10&rcprop=title&rcshow=!minor&formatversion=2&origin=*`
  );
  const data = await response.json();
  const articles = data.query.recentchanges;
  const recentArticlesList = document.querySelector("#recent-articles ul");

  populateArticleList(recentArticlesList, articles);
}

async function fetchRecentlyEditedArticles() {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&list=recentchanges&rclimit=10&rcprop=title&rcshow=!minor&formatversion=2&origin=*`
  );
  const data = await response.json();
  const articles = data.query.recentchanges;
  const recentlyEditedArticlesList = document.querySelector("#recently-edited ul");

  populateArticleList(recentlyEditedArticlesList, articles);
}

function filterArticlesByCategory(category) {
  const columns = document.querySelectorAll(".column");
  for (const column of columns) {
    const articles = column.querySelectorAll("li");
    for (const article of articles) {
      if (category === "all" || article.dataset.category === category) {
        article.style.display = "";
      } else {
        article.style.display = "none";
      }
    }
  }
}

function setupCategoryFilters() {
  const filters = document.querySelectorAll(".category-filters a");
  for (const filter of filters) {
    filter.addEventListener("click", (event) => {
      event.preventDefault();
      const category = filter.dataset.category;

      // Remove active class from other filters
      for (const otherFilter of filters) {
        otherFilter.classList.remove("active");
      }
      filter.classList.add("active");

      filterArticlesByCategory(category);
    });
  }
}

function fetchHomepageContent() {
  fetchPopularArticles();
  fetchRecentArticles();
  fetchRecentlyEditedArticles();
  setupCategoryFilters();
}

document.addEventListener("DOMContentLoaded", () => {
  fetchHomepageContent();
});

EOF

cat > /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/homepage.css << 'EOF'
#custom-homepage {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  margin: 0 0 20px 0 !important;
}

.category-filters {
  width: 100%;
  display: flex;
  flex-wrap: wrap;
}

.category-filters a {
  background-color: none;
  padding: .5rem 1rem;
  text-decoration: none !important;
  font-size: .875rem;
}

.category-filters a.active {
  border-bottom: 3px solid rgba(0,0,0,1);
}

.column {
  flex: 1;
}

.column h2 {
  margin-bottom: 10px;
  font-size: 1.125rem;
}

.column ul {
  list-style-type: none;
  padding: 0;
  margin-left: 0 !important;
}

.column li {
  margin-bottom: 5px;
  list-style: none;
}

body.page-Main_Page .vector-article-toolbar {
  display: none;
}

body.page-Main_Page .mw-body-header {
  display: none;
}

body.page-Main_Page .mw-body {
  padding-top: 0;
}

body.page-Main_Page .mw-body-content {
  margin-top: 0;
}

/* Responsive styles */
@media (max-width: 768px) {
  #custom-homepage {
    flex-direction: column;
  }
}
EOF

# Append LocalSettings
cd /var/www/html/mediawiki
echo 'require_once "$IP/extensions/homepage.php";' >> LocalSettings.php
echo '$wgEnableAPI = true;' >> LocalSettings.php