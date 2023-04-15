# Activate New Skin
file="/var/www/html/mediawiki/LocalSettings.php"
backup_file="/var/www/html/mediawiki/LocalSettings.php.bak"

# Create a backup of the original file
cd /var/www/html/mediawiki/
cp "$file" "$backup_file"

# Replace the line in the file
sed -i 's/\$wgDefaultSkin = "vector";/\$wgDefaultSkin = "vector-2022";/g' "$file"

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

# Create custom CSS
mkdir custom
# Create a systemd service
cat > custom/custom.less << EOL
body {
  background-color: white;
  color: #333;
}

.mw-logo-wordmark {
  font-family: 'Linux Libertine','Georgia','Times',serif;
  font-size: 1.25rem;
  font-weight: normal;
}

.mw-header {
  background-color: white;
  top: 0;
  display: flex;
  justify-self: stretch;
  justify-content: space-between;
}

.mw-body h1, .mw-body-content h1 {
  font-size: 3rem;
}

h1, h2, h3, h4, h5, h6 {
  color: #333;
}

h1, h2 {
  border-bottom: 1px solid rgba(0,0,0,0.1) !important;
  margin: 2rem 0 1rem 0;
}

.vector-body p {
  max-width: 640px;
  font-size: 1rem;
  line-height: 1.6;
  margin: 1rem 0;
}

.vector-body .gallerytext p {
  font-size: .75rem;
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

.mw-body .firstHeading {
  padding-bottom: 1rem;
  margin-bottom: 0;
}

.mw-body {
  padding-top: 3.5rem;
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
   font-family: 'Linux Libertine','Georgia','Times',serif;
   font-size: 1.125rem;
   color: #333;
}

.vector-toc-collapse-button {
  display: none !important;
}

#mw-sidebar-button::before {
  background-image: url("data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%2220%22 height=%2220%22 viewBox=%220 0 20 20%22%3E %3Ctitle%3E menu %3C/title%3E %3Cpath d=%22M1 3v2h18V3zm0 8h18V9H1zm0 6h18v-2H1z%22/%3E %3C/svg%3E");
}

.mw-sidebar {
  background-color: white;
  border: 1px solid rgba(0,0,0,0.1);
  border-radius: .325rem;
  box-shadow: 0 10px 1.5rem -1rem rgba(0,0,0,0.2);
  max-width: fit-content;
  position: fixed;
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

.sidebar-toc .sidebar-toc-text {
  padding: .5rem 0;
}

.sidebar-toc .sidebar-toc-toggle {
  top: .25rem;
}

@media only screen and (max-width: 999px) {
  .mw-table-of-contents-container .sidebar-toc {
    position: absolute !important;  
    top: 6rem;
    right: 1rem;
    left: inherit;
    background-color: white;
    border: 1px solid rgba(0,0,0,0.1);
    border-radius: .325rem;
    box-shadow: 0 10px 1.5rem -1rem rgba(0,0,0,0.2);
    padding: 1.5rem 1.5rem 1.5rem 2rem;
  }

  .vector-below-page-title #vector-toc-collapsed-button {
    display: none;
  }

  #vector-toc-collapsed-button {
    float: right;
    transform: translateY(50%);
  }
}
EOL
