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
  <!-- Populate this list using JavaScript -->
</div>
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

function truncateText(text, maxLength) {
  return text.length > maxLength ? text.substr(0, maxLength - 1) + "…" : text;
}

async function fetchArticleSnippet(title) {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&prop=extracts|info&titles=${encodeURIComponent(title)}&exsections=0&explaintext=1&inprop=url|displaytitle|created|touched|modified&formatversion=2&origin=*`
  );
  const data = await response.json();
  const pages = data.query.pages;
  const pageInfo = pages[0];

  const lastModified = pageInfo.touched ? new Date(pageInfo.touched) : null;

  const fullText = pageInfo.extract;
  const paragraphs = fullText.split('\n').filter(paragraph => !paragraph.match(/Template:/));
  const firstRelevantParagraph = paragraphs[0] || '';

  return {
    title: pageInfo.title,
    firstSentence: truncateText(firstRelevantParagraph, 150),
    lastModified: lastModified,
    url: pageInfo.fullurl,
  };
}

async function populateArticleList(listElement, articles, existingIds = new Set(), limit = 10) {
  let addedArticles = 0;
  for (const article of articles) {
    const articleId = generateArticleId(article.title);
    if (existingIds.has(articleId) || addedArticles >= limit || article.title === 'Main Page') {
      continue;
    }

    const snippet = await fetchArticleSnippet(article.title);
    const listItem = document.createElement("li");

    const displayDate = snippet.lastModified
      ? `Last modified: ${snippet.lastModified.toLocaleDateString()}`
      : snippet.firstPublished
      ? `First published: ${snippet.firstPublished.toLocaleDateString()}`
      : "Unknown";

    listItem.innerHTML = `
      <h3><a href="${snippet.url}">${snippet.title}</a></h3>
      <small>${displayDate}</small>
      <p>${snippet.firstSentence}</p>
    `;

    listElement.appendChild(listItem);
    existingIds.add(articleId);

    addedArticles++;
  }
}

async function fetchPopularArticles(existingTitles) {
  const popularArticlesList = document.querySelector("#most-viewed ul");
  let addedArticles = 0;
  let offset = 0;
  const limit = 10;
  const batchSize = 10;

  while (addedArticles < limit) {
    const response = await fetch(
      `${apiEndpoint}?action=query&format=json&list=allpages&aplimit=${batchSize}&apfilterredir=nonredirects&apnamespace=0&approp=categories&apdir=descending&apoffset=${offset}&formatversion=2&origin=*`
    );
    const data = await response.json();
    const articles = data.query.allpages;

    for (const article of articles) {
      if (!existingTitles.has(article.title)) {
        const snippet = await fetchArticleSnippet(article.title);
        const listItem = document.createElement("li");

        listItem.innerHTML = `
          <h3><a href="${snippet.url}">${snippet.title}</a></h3>
          <small>Last modified: ${snippet.lastModified.toLocaleDateString()}</small>
          <p>${snippet.firstSentence}</p>
        `;

        popularArticlesList.appendChild(listItem);
        existingTitles.add(article.title);
        addedArticles++;

        if (addedArticles >= limit) {
          break;
        }
      }
    }

    offset += batchSize;
  }
  return existingTitles;
}

function generateArticleId(title) {
  return title.trim().toLowerCase().replace(/\s+/g, "-");
}

async function fetchRecentArticles(existingTitles) {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&list=allpages&aplimit=50&apdir=descending&apfilterredir=nonredirects&apnamespace=0&approp=creation%7Ctimestamp&aporderby=creation&formatversion=2&origin=*`
  );
  const data = await response.json();
  const articles = data.query.allpages;
  const recentArticlesList = document.querySelector("#recent-articles ul");

  populateArticleList(recentArticlesList, articles, existingTitles, 10);
}

async function fetchRecentlyEditedArticles(existingTitles) {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&list=recentchanges&rclimit=50&rcprop=title&rcshow=!minor&formatversion=2&origin=*`
  );
  const data = await response.json();
  const articles = data.query.recentchanges;
  const recentlyEditedArticlesList = document.querySelector("#recently-edited ul");

  populateArticleList(recentlyEditedArticlesList, articles, existingTitles, 10);
}

async function fetchHomepageContent() {
  const existingTitles = new Set();

  const popularArticlesPromise = fetchPopularArticles(existingTitles);
  const recentArticlesPromise = fetchRecentArticles(existingTitles);
  const recentlyEditedArticlesPromise = fetchRecentlyEditedArticles(existingTitles);

  // Await the promises to ensure that recentArticles is defined
  const [ , recentArticles] = await Promise.all([
    popularArticlesPromise,
    recentArticlesPromise,
    recentlyEditedArticlesPromise,
  ]);

}

document.addEventListener("DOMContentLoaded", fetchHomepageContent);

EOF

cat > /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/homepage.css << 'EOF'
#custom-homepage {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  margin: 0 0 20px 0 !important;
}

body.page-Main_Page .mw-content-container {
  max-width: 100% !important;
}

.category-filters {
  width: 100%;
  display: flex;
  flex-wrap: wrap;
}

.category-filters {
  display: flex;
  flex-wrap: nowrap;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: thin;
  white-space: nowrap;
}

.category-filters::-webkit-scrollbar {
  height: 8px;
}

.category-filters::-webkit-scrollbar-thumb {
  background-color: rgba(0, 0, 0, 0.2);
  border-radius: 4px;
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

.column h3 {
  margin-bottom: .5rem;
}

.column h3 + small {
  color: #595959;
}

.column h3 + small + p {
   margin-top: .25rem;
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

.more-categories {
  position: relative;
}

.more-categories .dropdown-menu {
  position: absolute;
  top: 100%;
  left: 0;
  z-index: 1000;
  display: none;
  min-width: 160px;
  padding: 5px 0;
  margin: 2px 0 0;
  font-size: 14px;
  text-align: left;
  list-style: none;
  background-color: #fff;
  background-clip: padding-box;
  border: 1px solid rgba(0, 0, 0, 0.15);
  border-radius: 4px;
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.175);
}

.more-categories .dropdown-menu.show {
  display: block;
}

.more-categories a {
  padding: .5rem 1rem;
  text-decoration: none !important;
  font-size: .875rem;
}

.more-categories .dropdown-item {
  display: block;
  width: 100%;
  padding: 3px 20px;
  clear: both;
  font-weight: normal;
  line-height: 1.42857143;
  color: #333;
  white-space: nowrap;
  cursor: pointer;
  text-decoration: none;
}

.more-categories .dropdown-item:hover {
  background-color: #f5f5f5;
  text-decoration: none;
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