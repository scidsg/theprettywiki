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
        $mediaWiki->restInPeace();
        return false;
    }
    return true;
}