#!/bin/bash

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
cp skin.less old-skin.less
cat > skin.less << EOL
/**
 * Vector modern stylesheets
 * See '../common/common.less' for common screen and print Vector stylesheets.
 */

@import '../common/variables.less';
@import 'mediawiki.mixins.less';

@media screen {
        // Layouts
        @import './layouts/screen.less';

        // Components
        @import './components/ArticleToolbar.less';
        @import './components/SearchBoxLoader.less';
        @import './components/VueEnhancedSearchBox.less';
        @import './components/Sidebar.less';
        @import './components/LanguageButton.less';
        @import './components/UserLinks.less';
        @import './components/Header.less';
        @import './components/Footer.less';
        @import './components/MenuDropdown.less';
        @import './components/MenuTabs.less';
        @import './components/MenuPortal.less';
        @import './components/StickyHeader.less';
        @import './components/TabWatchstarLink.less';
        @import './components/TableOfContents.less';
        @import './components/TableOfContentsCollapsed.less';

        // Custom Styles
        @import './custom/custom.less';
        @import './custom/ddos.less';
}

@media all {
        // Component styles that should apply in all media.
        @import './components/Logo.less';
}

@media print {
        @import './layouts/print.less';
}

@import './layouts/gradeC.less';
EOL

# Create a systemd service
cat > custom/custom.less << EOL
@font-face {
  font-family: "Sans";
  src: url("custom/fonts/sans/Atkinson-Hyperlegible-Regular.woff2") format("woff2"),
       url("custom/fonts/sans/Atkinson-Hyperlegible-Regular.woff") format("woff");
}

@font-face {
  font-family: "Sans Bold";
  src: url("custom/fonts/sans/Atkinson-Hyperlegible-Bold.woff2") format("woff2"),
       url("custom/fonts/sans/Atkinson-Hyperlegible-Bold.woff") format("woff");
}

@font-face {
  font-family: "Serif";
  src: url("custom/fonts/serif/Merriweather-Regular.woff2") format("woff2"),
       url("custom/fonts/serif/Merriweather-Regular.woff") format("woff");
}

::selection {
  background-color: #333;
  color: white;
}

body {
  background-color: white;
  color: #333;
  font-family: 'Sans', sans-serif;
}

.mw-logo-wordmark {
  font-family: 'Serif','Linux Libertine','Georgia','Times',serif;
  font-size: 1.25rem;
  font-weight: normal;
}

.mw-page-container {
  min-width: auto !important;
}

.mw-header {
  background-color: white;
  top: 0;
  display: flex;
  justify-self: stretch;
  justify-content: space-between;
  z-index: inherit !important;
}

.mw-body h1, .mw-body-content h1 {
  font-size: 3rem;
}

h1, h2, h3, h4, h5, h6 {
  color: #333;
}

.mw-body h1, .mw-body-content h1, .mw-body-content h2 {
  font-family: 'Serif','Linux Libertine','Georgia','Times',serif;
}

h1, h2 {
  border-bottom: 1px solid rgba(0,0,0,0.1) !important;
  margin: 2rem 0 1rem 0;
}

.mw-logo-container {
  max-width: initial !important;
}

.vector-body p {
  max-width: 640px;
  font-size: 1rem;
  line-height: 1.6;
  margin: 1rem 0;
}

.vector-body {
  font-size: 1rem;
  padding-top: .5rem;
}

.mw-content-ltr ul {
  margin: 1rem 0 1rem 1.3rem !important;
}

.vector-menu-tabs .mw-list-item > a {
  font-size: .875rem;
}

.vector-menu-heading-label {
  font-size: .875rem;
}

.vector-body .gallerytext p {
  font-size: .75rem;
}

body.page-Main_Page .mw-content-container {
  position: relative !important;
  top: -1rem;
}

.mw-header-content, .mw-header-aside {
  justify-content: flex-end;
}

.mw-header .vector-search-box {
  margin-left: 1.5rem;
}

.cdx-typeahead-search--show-thumbnail.cdx-typeahead-search--auto-expand-width:not(.cdx-typeahead-search--active) {
  margin-left: 0;
}

.client-js .vector-search-box-vue.vector-search-box-show-thumbnail.vector-search-box-auto-expand-width .searchButton {
  left: 0
}

.client-js .vector-search-box-vue.vector-search-box-show-thumbnail.vector-search-box-auto-expand-width .vector-search-box-input {
  margin-left: 0;
  width: 100%;
  max-width: 320px;
}

a {
  color: #333 !important;
}

a.extiw:visited, .mw-parser-output a.external:visited {
  color: #333;
}

#mw-content-text a {
  text-decoration: underline;
}

.mw-header #mw-sidebar-button {
  display: none;
}

.mw-body .firstHeading {
  padding-bottom: 1rem;
  margin-bottom: 0;
  border-bottom: none;
  order: -1;
}

.mw-body {
  padding-top: 3.5rem;
}

.mw-body-header {
  display: flex;
  width: 100%;
  border-bottom: 1px solid rgba(0,0,0,0.1);
  align-items: flex-start;
}

.mw-body .firstHeading {
  width: 100%;
  border-bottom: none !important;
}

#vector-toc-collapsed-button {
  order: 2;
}

.cdx-search-input--has-end-button {
  border: 1px solid rgba(0,0,0,0.1);
  border-radius: .25rem;
}

.cdx-text-input__input:enabled {
  border: 1px solid rgba(0,0,0,0.1);
  border-radius: .25rem;
}

.cdx-text-input__input:enabled:hover {
  border-color: rgba(0,0,0,0.1);
}

.cdx-typeahead-search--show-thumbnail.cdx-typeahead-search--auto-expand-width:not(.cdx-typeahead-search--active) {
  margin-left: 0;
}

.vector-search-box-input {
  border: 1px solid rgba(0,0,0,0.1);
  border-radius: .25rem;
  box-shadow: 0px 3px 12px -6px rgba(0,0,0,0.15);
}

.vector-body h2 {
  font-size: 2rem;
  padding-bottom: .5rem;
}

.vector-search-box-vue .searchButton {
  background-size: 1rem;
}

.vector-body h3 {
  font-size: 1.5rem;
}

.vector-body h3,
.vector-body h4,
.vector-body h5,
.vector-body h6 {
  line-height: 1.2;
}

.vector-menu-tabs .mw-list-item.selected a, .vector-menu-tabs .mw-list-item.selected a:visited {
  color: #333;
  border-bottom: 3px solid black;
}

.vector-menu-tabs .mw-list-item > a, .mw-article-toolbar-container .vector-menu-dropdown > a, .vector-menu-tabs .mw-list-item .vector-menu-heading, .mw-article-toolbar-container .vector-menu-dropdown .vector-menu-heading {
  padding: 1rem;
  max-height: fit-content;
}

.vector-menu-tabs .mw-list-item, .mw-article-toolbar-container .vector-menu-dropdown {
  margin: 0;
}

#left-navigation {
  margin-left: 0;
}

.vector-page-titlebar,
.vector-page-toolbar-container,
.mw-article-toolbar-container {
  box-shadow: none;
  border-bottom: 1px solid rgba(0,0,0,0.1);
}

.mw-table-of-contents-container .sidebar-toc {
  position: absolute;
}

.sidebar-toc .sidebar-toc-title {
   font-family: 'Serif','Linux Libertine','Georgia','Times',serif;
   font-size: 1.125rem;
   color: #333;
}

.vector-toc-collapse-button {
  display: none !important;
}

.sidebar-toc {
  overflow-x: hidden;
}

#mw-sidebar-button::before {
  background-image: url("data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%2220%22 height=%2220%22 viewBox=%220 0 20 20%22%3E %3Ctitle%3E menu %3C/title%3E %3Cpath d=%22M1 3v2h18V3zm0 8h18V9H1zm0 6h18v-2H1z%22/%3E %3C/svg%3E");
}

.mw-sidebar {
  display: none !important;
}

.mw-sidebar {
  background-color: white;
  border: 1px solid rgba(0,0,0,0.1);
  border-radius: .325rem;
  box-shadow: 0 10px 1.5rem -1rem rgba(0,0,0,0.2);
  max-width: fit-content;
  position: absolute;
  z-index: 2;
  top: 4.5rem;
}

.vector-toc-not-collapsed #mw-sidebar-checkbox:not(:checked) ~ .mw-table-of-contents-container .vector-sticky-toc-container {
  margin-top: 0;
}

.vector-menu-portal .vector-menu-content ul {
  padding-top: 0;
}

.vector-menu-portal .vector-menu-content li {
  margin: .425rem 0;
}

.vector-menu-portal .vector-menu-heading {
  font-size: .825rem;
  font-weight: bold;
  color: #333;
}

.vector-menu-dropdown .vector-menu-content {
  border: 1px solid rgba(0,0,0,0.1);
  border-radius: .325rem;
  box-shadow: 0 10px 1.5rem -1rem rgba(0,0,0,0.2);
}

.sidebar-toc .sidebar-toc-text {
  padding: .5rem 0;
}

.sidebar-toc .sidebar-toc-toggle {
  top: .25rem;
}

.mw-footer {
  border-top: 1px solid rgba(0,0,0,0.1);
}

.mw-footer-container {
  padding-bottom: 1rem;
}

.spinner {
  border: 3px solid #fff;
  border-top: 3px solid #999;
  border-radius: 50%;
  width: 1.5rem;
  height: 1.5rem;
  animation: spin 2s linear infinite;
  margin: 2rem auto 0 auto;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.mw-header .mw-header-content #p-search.vector-search-box {
     margin-left: 5rem !important;
  }

@media (max-width: 1199px) {
  .mw-header .mw-header-content #p-search.vector-search-box {
     margin-left: 1.75rem !important;
  }
}

@media (max-width: 999px) {
  .mw-table-of-contents-container .sidebar-toc {
    position: absolute !important;
    top: 6.5rem;
    right: 1rem;
    left: inherit;
    background-color: white;
    border: 1px solid rgba(0,0,0,0.1);
    border-radius: .325rem;
    box-shadow: 0 10px 1.5rem -1rem rgba(0,0,0,0.2);
    padding: 1.5rem 1.5rem 1.5rem 2rem;
  }

  .mw-page-container {
    padding-left: 2rem !important;
    padding-right: 2rem !important;
  }

  .vector-below-page-title #vector-toc-collapsed-button {
    display: none !important;
  }

  .mw-body {
    padding-left: 0;
    padding-right: 0;
  }
}

@media (max-width: 768px) {
  .mw-body h1 {
    font-size: 2.5rem;
  }
}

@media (max-width: 640px) {
  .mw-page-container {
    padding-left: 1.5rem !important;
    padding-right: 1.5rem !important;
  }
}

@media (max-width: 480px) {
  .mw-page-container {
    padding-left: 1.25rem !important;
    padding-right: 1.25rem !important;
  }

  .mw-header {
    padding: .625rem 0;
  }

  .mw-body h1 {
    font-size: 2rem;
  }
}

EOL

# DDoSecrets-specific styles
cat > custom/ddos.less << EOL
.mw-parser-output table {
  width: 300px !important;
  border: 1px solid rgba(0,0,0,0.1) !important;;
  color: #333 !important;
  border-radius: .25rem !important;
  padding-bottom: 1rem;
} 
  
.mw-parser-output table, 
.mw-parser-output table th,
.mw-parser-output table tr,
.mw-parser-output table td {
    background: #f2f2f2 !important;
    color: #333 !important;
    border: 0px !important;
    padding: .625rem 1rem !important;
    text-align: left !important;;
}
 
.mw-parser-output table {
    border: 1px solid rgba(0,0,0,0.1) !important;
    border-collapse: inherit !important;
    margin-left: 1.5rem !important;
}
  
.mw-parser-output table th {
    font-family: 'Serif', serif;
    padding: 1rem 0 .5rem 0 !important;
}
  
.mw-parser-output table tr:first-of-type th {
    font-family: 'Serif', serif;
    padding: .5rem 0 !important;
}

.mw-parser-output table th a {
    font-size: .75rem;
    font-weight: normal;
}

.mw-parser-output table td {
    padding: .25rem 0 !important;
    word-break: break-word !important;
}

@media (max-width: 640px) {
  .mw-parser-output table {
    width: 33% !important;
  } 
} 

@media (max-width: 480px) {
  .mw-parser-output table {
    width: 100% !important;
    margin-left: 0 !important;
  } 
}  

EOL

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
<!--   <div id="banner"> -->
<!--     <div class="banner-content"> -->
<!--       <p>❤️  Support DDoSecrets by donating today! <a href="#">Donate Now</a></p> -->
<!--     </div> -->
<!--     <button id="close-banner" aria-label="Close">
<!--      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width=">
<!--        <line x1="18" y1="6" x2="6" y2="18"></line>  -->
<!--        <line x1="6" y1="6" x2="18" y2="18"></line>  -->
<!--     </svg> -->
<!--     </button> -->
<!--   </div> -->
  <div class="category-filters"></div>
  <div class="columnGroup">
    <div class="column" id="featured-articles">
      <h2>Featured Articles</h2>
      <ul>
      </ul>
      <div class="spinner"></div>
    </div>
    <div class="column" id="recent-articles">
      <h2>Recently Published</h2>
      <ul>
      </ul>
      <div class="spinner"></div>
    </div>
    <div class="column" id="recently-edited">
      <h2>Recently Edited</h2>
      <ul>
      </ul>
      <div class="spinner"></div>
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
    return text.length > maxLength ? text.substr(0, maxLength - 1) + "..." : text;
}

async function fetchArticleSnippet(title) {
    const response = await fetch(
        `${apiEndpoint}?action=query&format=json&prop=extracts|info&titles=${encodeURIComponent(title)}&exsections=0&explaintext=1&inprop=url|displaytitle|created|touched|modified&formatversion=2&origin=*`
    );
    const data = await response.json();
    const pages = data.query.pages;
    const pageInfo = pages[0];
    const created = pageInfo.created ? new Date(pageInfo.created) : null;
    const lastModified = pageInfo.touched ? new Date(pageInfo.touched) : null;
    const fullText = pageInfo.extract;
    if (!fullText) {
        console.warn(`No extract found for ${title}`);
        return {
            title: pageInfo.title,
            firstSentence: '',
            created: created,
            lastModified: lastModified,
            url: pageInfo.fullurl,
        };
    }
    const paragraphs = fullText.split('\n').filter(paragraph => !paragraph.match(/Template:/));
    const firstRelevantParagraph = paragraphs[0] || '';
    return {
        title: pageInfo.title,
        firstSentence: truncateText(firstRelevantParagraph, 150),
        created: created,
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
        if (existingIds.has(articleId) || addedArticles >= limit || article.title === 'Featured articles') {
            continue;
        }
        const snippet = await fetchArticleSnippet(article.title);
        const listItem = document.createElement("li");
        const displayDate = snippet.lastModified ?
            `Last modified: ${snippet.lastModified.toLocaleDateString()}` :
            snippet.firstPublished ?
            `First published: ${snippet.firstPublished.toLocaleDateString()}` :
            "Unknown";
        listItem.innerHTML = `
<h3><a href="${snippet.url}">${snippet.title}</a></h3>
<small>${displayDate}</small>
<p>${snippet.firstSentence}</p>
`;
        listElement.appendChild(listItem);
        existingIds.add(articleId);
        addedArticles++;
    }
    listElement.nextElementSibling.style.display = "none";
}

async function fetchFeaturedArticles() {
    const response = await fetch(
        `${apiEndpoint}?action=query&format=json&prop=extracts|info&titles=${encodeURIComponent('Featured articles')}&explaintext=1&formatversion=2&origin=*`
    );
    const data = await response.json();
    const pages = data.query.pages;
    const pageInfo = pages[0];
    const fullText = pageInfo.extract;

    if (!fullText) {
        console.warn("No extract found for Featured articles");
        return [];
    }

    const featuredArticleTitles = fullText
        .split("\n")
        .filter((title) => title.trim().length > 0);

    const featuredArticlesList = document.querySelector("#featured-articles ul");
    const existingIds = new Set();
    await populateArticleList(featuredArticlesList, featuredArticleTitles.map(title => ({ title })), existingIds, 10);
}

function generateArticleId(title) {
    return title.trim().toLowerCase().replace(/\s+/g, "-");
}

async function fetchRecentArticles(existingTitles) {
    const response = await fetch(
        `${apiEndpoint}?action=query&format=json&list=recentchanges&rclimit=100&rcprop=title%7Ctimestamp&rcshow=!minor%7C!redirect&rcnamespace=0&formatversion=2&origin=*`
    );
    const data = await response.json();
    const recentChanges = data.query.recentchanges;

    const newPages = recentChanges.filter(change => change.type === "new");
    newPages.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    const recentArticlesList = document.querySelector("#recent-articles ul");
    populateArticleList(recentArticlesList, newPages, existingTitles, 10);
}

async function fetchRecentlyEditedArticles(existingTitles) {
    const response = await fetch(
        `${apiEndpoint}?action=query&format=json&list=recentchanges&rclimit=100&rcprop=title%7Ctimestamp&rcshow=!minor%7C!redirect&rcnamespace=0&formatversion=2&origin=*`
    );
    const data = await response.json();
    const recentChanges = data.query.recentchanges;

    const editedPages = recentChanges.filter(change => change.type !== "new");
    editedPages.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

    const recentlyEditedArticlesList = document.querySelector("#recently-edited ul");
    populateArticleList(recentlyEditedArticlesList, editedPages, existingTitles, 10);
}

async function fetchHomepageContent() {
    // Call generateCategoryFilterList before fetching articles
    generateCategoryFilterList();

    const recentArticlesPromise = fetchRecentArticles(new Set());
    const recentlyEditedArticlesPromise = fetchRecentlyEditedArticles(new Set());
    const featuredArticlesPromise = fetchFeaturedArticles();

    // Await the promises to ensure that recentArticles is defined
    await Promise.all([
        recentArticlesPromise,
        recentlyEditedArticlesPromise,
        featuredArticlesPromise,
    ]);
}

async function fetchTopCategories(limit = 3) {
    try {
        const response = await fetch(
            `${apiEndpoint}?action=query&format=json&generator=allcategories&gacnamespace=14&gacdir=descending&gacminsize=1&gacprop=size&prop=info&inprop=displaytitle&formatversion=2&origin=*&gacminsize=5&gaclimit=${limit}`
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

async function fetchAllCategories() {
    try {
        const response = await fetch(
            `${apiEndpoint}?action=query&format=json&list=allcategories&aclimit=max&formatversion=2&origin=*`
        );
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        if (!data.query) {
            console.error('Error fetching all categories: data.query is undefined');
            return [];
        }
        const categories = data.query.allcategories;

        // Add this console.log statement
        console.log("Fetched all categories:", categories);

        return categories.map((category) => {
            return { title: category.category }; // Change this line
        });

    } catch (error) {
        console.error('Error fetching all categories:', error);
        return [];
    }
}

async function generateCategoryFilterList() {
    console.log('Generating category filter list...');
    const topCategories = await fetchTopCategories();
    const allCategories = await fetchAllCategories();

    console.log("Top categories:", topCategories);
    console.log("All categories:", allCategories);

    const categoryFilters = document.querySelector(".category-filters");
    console.log("Category Filters:", categoryFilters);
    const filterList = document.createElement("ul");

    const allItem = document.createElement("li");
    allItem.innerHTML = '<a href="#" data-category="all" class="active">All</a>';
    filterList.appendChild(allItem);
    for (const category of topCategories) {
        const listItem = document.createElement("li");
        const categoryTitle = category.title || "";
        listItem.innerHTML = `<a href="#" data-category="${categoryTitle}">${categoryTitle.replace("Category:", "")}</a>`;

        filterList.appendChild(listItem);
    }

    const moreItem = document.createElement("li");
    moreItem.innerHTML = `<a href="#" class="more-categories">More</a>`;
    filterList.appendChild(moreItem);

    const dropdownList = document.createElement("ul");
    dropdownList.classList.add("dropdown-list");
    dropdownList.style.display = "none";
    for (const category of allCategories) {
        const listItem = document.createElement("li");
        const categoryTitle = category.title || "";
        listItem.innerHTML = `<a href="#" data-category="${categoryTitle}">${categoryTitle.replace("Category:", "")}</a>`;
        dropdownList.appendChild(listItem);
    }

    console.log("Dropdown list:", dropdownList);

    categoryFilters.appendChild(filterList);
    categoryFilters.appendChild(dropdownList);

    const filterLinks = document.querySelectorAll(".category-filters a");
    filterLinks.forEach((link) => {
        link.addEventListener("click", (event) => {
            event.preventDefault();
            const moreCategoriesLink = document.querySelector('.more-categories');
            if (event.target.classList.contains("more-categories")) {
                dropdownList.style.display = dropdownList.style.display === "none" ? "block" : "none";
            } else {
                const category = event.target.dataset.category;
                applyCategoryFilter(category);
                if (dropdownList.contains(event.target)) {
                    dropdownList.style.display = "none";
                }
                if (moreCategoriesLink) {
                    moreCategoriesLink.classList.remove("active");
                }
            }
        });
    });
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
        fetchFeaturedArticles(existingIds);
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

    const featuredArticles = await fetchFeaturedArticles();
    const recentArticles = await fetchRecentArticles(existingIds);
    const recentlyEditedArticles = await fetchRecentlyEditedArticles(existingIds);

    const featuredArticlesList = document.querySelector("#featured-articles ul");
    const recentArticlesList = document.querySelector("#recent-articles ul");
    const recentlyEditedArticlesList = document.querySelector("#recently-edited ul");

    const filteredFeaturedArticles = articles.filter(article =>
        featuredArticles.some(featuredArticle => featuredArticle.title === article.title)
    );
    const filteredRecentArticles = articles.filter(article =>
        recentArticles.some(recentArticle => recentArticle.title === article.title)
    );
    const filteredRecentlyEditedArticles = articles.filter(article =>
        recentlyEditedArticles.some(recentlyEditedArticle => recentlyEditedArticle.title === article.title)
    );

    populateArticleList(featuredArticlesList, filteredFeaturedArticles, existingIds, 10);
    populateArticleList(recentArticlesList, filteredRecentArticles, existingIds, 10);
    populateArticleList(recentlyEditedArticlesList, filteredRecentlyEditedArticles, existingIds, 10);
}

document.addEventListener('DOMContentLoaded', function() {
    const menuToggle = document.querySelector('.menu-toggle');
    const menu = document.querySelector('.nav-menu');
    const menuLinks = document.querySelectorAll('.nav-menu a');

    if (menuToggle) {
        menuToggle.addEventListener('click', function() {
            menu.classList.toggle('show');
        });
    } else {
        console.warn("menuToggle is not found");
    }

    menuLinks.forEach(link => {
        link.addEventListener('click', function() {
            console.log('Category link clicked');
            menu.classList.remove('show');
        });
    });
});

document.addEventListener('DOMContentLoaded', function() {
    const closeBannerBtn = document.getElementById('close-banner');
    const banner = document.getElementById('banner');
    const body = document.querySelector('body');

    console.log('DOMContentLoaded'); // Debug log

    if (banner) {
        body.classList.add('banner-present');

        console.log('Banner found'); // Debug log

        closeBannerBtn.addEventListener('click', function() {
            console.log('Close button clicked'); // Debug log
            banner.style.display = 'none';
            // Remove the banner-present class from the body
            body.classList.remove('banner-present');
        });
    }
});

document.addEventListener("DOMContentLoaded", fetchHomepageContent);
EOF

cat > /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/homepage.css << EOL
#banner {
    background-color: #333;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 100;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 40px;
}

#banner p {
    margin: 0;
    color: white;
    font-size: .875rem;
}

#banner a {
    color: white !important;
}

.banner-content {
    max-width: 80%;
}

#close-banner {
    background: transparent;
    border: none;
    font-size: 1.5rem;
    font-weight: bold;
    color: #fff;
    cursor: pointer;
    position: absolute;
    right: .5rem;
}

body.banner-present {
    padding-top: 40px;
}

#custom-homepage {
    display: flex;
    flex-wrap: wrap;
    margin: 0 0 20px 0 !important;
}

body.page-Main_Page .mw-content-container {
    max-width: 100% !important;
    grid-column: sidebar / content;
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
    width: fit-content;
    overflow: inherit;
    flex-direction: row;
    justify-content: center;
    margin-bottom: 1rem;
    justify-content: flex-start;
    max-width: calc(100% + 1.5rem);
}

.category-filters ul {
    display: flex;
    flex-wrap: nowrap;
    list-style-type: none;
    padding: 1rem 0;
    margin: 0 !important;
    overflow-x: auto;
    padding-right: 1.5rem;
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

.category-filters {
    position: relative;
}

.dropdown-list {
    display: none;
    position: relative;
    z-index: 100;
    background-color: white;
    border: 1px solid rgba(0,0,0,0.1);
    border-radius: .325rem;
    box-shadow: 0 10px 1.5rem -1rem rgba(0,0,0,0.2);
    padding: .5rem 0 !important;
    width: fit-content;
    max-width: 300px;
    position: absolute;
    height: 240px;
    overflow: scroll;
    top: 3rem;
    right: 1.5rem;
}

.dropdown-list li {
    display: block;
    white-space: inherit !important;
}

.dropdown-list a {
    display: block;
    padding: .5rem 1rem !important;
}

.dropdown-list a.active {
  border-left: 3px solid #333;
  border-bottom: none;
}

.dropdown-list li:last-child {
    margin-bottom: 0;
}

#mw-sidebar-checkbox:not(:checked)~.vector-sidebar-container-no-toc~.mw-content-container {
    padding-left: 0;
}

.hide {
    display: none;
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

.column h3+small {
    color: #595959;
}

.column h3+small+p {
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
    padding-left: 0;
}

body.page-Main_Page .mw-body-content {
    margin-top: 0;
}

.mw-header #mw-sidebar-button {
    display: none;
}

@media (max-width: 768px) {
    #custom-homepage .columnGroup {
        flex-direction: column;
    }
}

@media (max-width: 480px) {
    .category-filters {
        max-width: calc(100% + 1.25rem);
    }

    .dropdown-list {
        right: 1.25rem;
    }

    #banner p {
      font-size: .75rem;
  }
}

EOL

# Append LocalSettings
cd /var/www/html/mediawiki
echo 'require_once "$IP/extensions/homepage.php";' >> LocalSettings.php
echo '$wgEnableAPI = true;' >> LocalSettings.php
