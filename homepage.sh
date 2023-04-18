#!/bin/bash 

cat > /var/www/html/mediawiki/extensions/homepage.php << 'EOL'
<?php
$wgHooks['MediaWikiPerformAction'][] = 'onMediaWikiPerformAction';
function onMediaWikiPerformAction($output, $article, $title, $user, $request, $mediaWiki) {
    error_log("onMediaWikiPerformAction called");
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
EOL

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
  if (!fullText) {
    console.warn(`No extract found for ${title}`);
    return {
      title: pageInfo.title,
      firstSentence: '',
      lastModified: lastModified,
      url: pageInfo.fullurl,
    };
  }
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
    // Stop the loop if there are no more articles to fetch
    if (articles.length < batchSize) {
      break;
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
  const existingIds = new Set();
  const popularArticlesPromise = fetchPopularArticles(existingIds);
  const recentArticlesPromise = fetchRecentArticles(existingIds);
  const recentlyEditedArticlesPromise = fetchRecentlyEditedArticles(existingIds);
  // Await the promises to ensure that recentArticles is defined
  await Promise.all([
    popularArticlesPromise,
    recentArticlesPromise,
    recentlyEditedArticlesPromise,
  ]);
  generateCategoryFilterList();
}

async function fetchTopCategories(limit = 3) {
  try {
    const response = await fetch(
      `${apiEndpoint}?action=query&format=json&generator=allcategories&gacnamespace=14&gacdir=descending&gacminsize=1&gacprop=size&prop=info&inprop=displaytitle&formatversion=2&origin=*&gacminsize=5`
    );
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();
    if (!data.query) {
      console.error('Error fetching top categories: data.query is undefined');
      return [];
    }
    const categories = Object.values(data.query.pages);
    let topCategories = [];
    for (let i = 0; i < categories.length && topCategories.length < limit; i++) {
      const category = categories[i];
      if (!category.hidden) {
        topCategories.push({
          title: category.title.replace("Category:", ""),
        });
      }
    }
    return topCategories;
  } catch (error) {
    console.error('Error fetching top categories:', error);
    return [];
  }
}

async function generateCategoryFilterList() {
  const topCategories = await fetchTopCategories();
  const categoryFilters = document.querySelector(".category-filters");
  const filterList = document.createElement("ul");
  // Add the "All" category
  const allItem = document.createElement("li");
  allItem.innerHTML = '<a href="#" data-category="all">All</a>';
  filterList.appendChild(allItem);
  // Add the fetched categories
  for (const category of topCategories) {
    const listItem = document.createElement("li");
    listItem.innerHTML = `<a href="#" data-category="${category.title}">${category.title}</a>`;
    filterList.appendChild(listItem);
  }
  categoryFilters.appendChild(filterList);
}

async function fetchHomepageContent() {
  const existingIds = new Set();
  const popularArticlesPromise = fetchPopularArticles(existingIds);
  const recentArticlesPromise = fetchRecentArticles(existingIds);
  const recentlyEditedArticlesPromise = fetchRecentlyEditedArticles(existingIds);
  // Await the promises to ensure that recentArticles is defined
  await Promise.all([
    popularArticlesPromise,
    recentArticlesPromise,
    recentlyEditedArticlesPromise,
  ]);
  generateCategoryFilterList();
}

function applyCategoryFilter(category) {
  const allCategories = document.querySelectorAll(".category-filters a");
  allCategories.forEach((cat) => cat.classList.remove("active"));
  if (category === "all") {
    document.querySelector(".category-filters a[data-category='all']").classList.add("active");
  } else {
    document.querySelector(`.category-filters a[data-category='${category}']`).classList.add("active");
  }
  const allColumns = document.querySelectorAll(".column ul");
  allColumns.forEach((column) => {
    column.innerHTML = "";
  });
  const existingIds = new Set();
  if (category === "all") {
    fetchPopularArticles(existingIds);
    fetchRecentArticles(existingIds);
    fetchRecentlyEditedArticles(existingIds);
  } else {
    fetchArticlesByCategory(category, existingIds);
  }
}

async function fetchArticlesByCategory(category, existingIds) {
  const response = await fetch(
    `${apiEndpoint}?action=query&format=json&list=categorymembers&cmtitle=Category:${encodeURIComponent(category)}&cmlimit=50&cmnamespace=0&formatversion=2&origin=*`
  );
  const data = await response.json();
  const articles = data.query.categorymembers;
  const popularArticlesList = document.querySelector("#most-viewed ul");
  const recentArticlesList = document.querySelector("#recent-articles ul");
  const recentlyEditedArticlesList = document.querySelector("#recently-edited ul");
  populateArticleList(popularArticlesList, articles, existingIds, 10);
  populateArticleList(recentArticlesList, articles, existingIds, 10);
  populateArticleList(recentlyEditedArticlesList, articles, existingIds, 10);
}

async function generateCategoryFilterList() {
  console.log('Generating category filter list...');
  const topCategories = await fetchTopCategories();
  const categoryFilters = document.querySelector(".category-filters");
  const filterList = document.createElement("ul");
  // Add the "All" category
  const allItem = document.createElement("li");
  allItem.innerHTML = '<a href="#" data-category="all" class="active">All</a>';
  filterList.appendChild(allItem);
  // Add the fetched categories
  for (const category of topCategories) {
    const listItem = document.createElement("li");
    listItem.innerHTML = `<a href="#" data-category="${category.title}">${category.title}</a>`;
    filterList.appendChild(listItem);
  }

  categoryFilters.appendChild(filterList);
  // Add click event listeners to filter categories
  const filterLinks = document.querySelectorAll(".category-filters a");
  filterLinks.forEach((link) => {
    link.addEventListener("click", (event) => {
      event.preventDefault();
      const category = event.target.dataset.category;
      applyCategoryFilter(category);
    });
  });
}

document.addEventListener("DOMContentLoaded", fetchHomepageContent);

EOF

cat > /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/homepage.css << EOL
#custom-homepage {
  display: flex;
  flex-wrap: wrap;
  margin: 0 0 20px 0 !important;
}
body.page-Main_Page .mw-content-container {
  max-width: 100% !important;
}
.columnGroup {
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 2rem;
  width: 100%;
}
.category-filters {
  display: flex;
  width: 100%;
  overflow-x: auto ;
  flex-direction: row;
  justify-content: center;
  margin-bottom: 1rem;
  justify-content: flex-start;
}
.category-filters ul {
  display: flex;
  flex-wrap: nowrap;
  list-style-type: none;
  padding: 1rem 0;
  margin: 0 !important;
}
.category-filters ul li {
  white-space: nowrap;
  list-style: none;
  font-size: .875rem;
}
.category-filters ul li a {
  text-decoration: none !important;
  padding: 1rem;
}
.category-filters a.active {
  border-bottom: 3px solid #333;
  background-color: #fff;
}
#mw-sidebar-checkbox:not(:checked) ~ .vector-sidebar-container-no-toc ~ .mw-content-container {
  padding-left: 0;
}
.column {
  flex: 1;
  max-width: 100%;
}
.column h2 {
  margin-bottom: 1rem;
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
  padding-right: 0;
}
body.page-Main_Page .mw-body-content {
  margin-top: 0;
}
.mw-header #mw-sidebar-button {
  display: none;
}
/* Responsive styles */
@media (max-width: 768px) {
  #custom-homepage .columnGroup {
    flex-direction: column;
  }
}

EOL

# Append LocalSettings
cd /var/www/html/mediawiki
echo 'require_once "$IP/extensions/homepage.php";' >> LocalSettings.php
echo '$wgEnableAPI = true;' >> LocalSettings.php