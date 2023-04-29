const apiEndpoint = "/api.php";

function truncateText(text, maxLength) {
    return text.length > maxLength ? text.substr(0, maxLength - 1) + "..." : text;
}

async function fetchArticleSnippet(title) {
    const response = await fetch(
        `${apiEndpoint}?action=query&format=json&prop=extracts|info|pageimages&titles=${encodeURIComponent(title)}&exsections=0&explaintext=1&inprop=url|displaytitle|created|touched|modified&piprop=original&formatversion=2&origin=*`
    );
    const data = await response.json();
    const pages = data.query.pages;
    const pageInfo = pages[0];
    const created = pageInfo.created ? new Date(pageInfo.created) : null;
    const lastModified = pageInfo.touched ? new Date(pageInfo.touched) : null;
    const fullText = pageInfo.extract;
    const imageUrl = pageInfo.original ? pageInfo.original.source : null;

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

    // Remove section headers
    const cleanedParagraphs = paragraphs.map(paragraph => paragraph.replace(/==(.*)==/, '').trim());

    const firstRelevantParagraph = cleanedParagraphs.find(paragraph => paragraph.length > 0) || '';
    
    return {
        title: pageInfo.title,
        firstSentence: truncateText(firstRelevantParagraph, 150),
        created: created,
        lastModified: lastModified,
        url: pageInfo.fullurl,
        imageUrl: imageUrl,
    };
}

async function populateArticleList(listElement, articles, existingIds = new Set(), limit = 10, includeImages = false) {
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
${includeImages && snippet.imageUrl ? `<div class="img-container"><img src="${snippet.imageUrl}" alt="${snippet.title}"></div>` : ''}
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

    const featuredArticleObjects = featuredArticleTitles.map(title => ({ title: title }));

    const featuredArticlesList = document.querySelector("#featured-articles ul");
    const existingIds = new Set();
    await populateArticleList(featuredArticlesList, featuredArticleObjects, existingIds, 5, true);
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
    generateCategoryFilterList();

    const recentArticlesPromise = fetchRecentArticles(new Set());
    const recentlyEditedArticlesPromise = fetchRecentlyEditedArticles(new Set());
    const featuredArticlesPromise = fetchFeaturedArticles();

    await Promise.all([
        recentArticlesPromise,
        recentlyEditedArticlesPromise,
        featuredArticlesPromise,
    ]);
}

async function fetchTopCategories(limit = 3) {
    try {
        const response = await fetch(
            `${apiEndpoint}?action=query&format=json&generator=allcategories&gacnamespace=14&gacdir=ascending&gacminsize=1&gacprop=size&prop=info&inprop=displaytitle&formatversion=2&origin=*&gacminsize=5&gaclimit=${limit}`
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
        return topCategories.reverse();
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

        return categories.map((category) => {
            return { title: category.category };
        });

    } catch (error) {
        console.error('Error fetching all categories:', error);
        return [];
    }
}

async function generateCategoryFilterList() {
    const topCategories = await fetchTopCategories();
    const allCategories = await fetchAllCategories();

    const categoryFilters = document.querySelector(".category-filters");
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
            menu.classList.remove('show');
        });
    });
});

document.addEventListener('DOMContentLoaded', function() {
    const closeBannerBtn = document.getElementById('close-banner');
    const banner = document.getElementById('banner');
    const body = document.querySelector('body');

    if (banner) {
        body.classList.add('banner-present');

        closeBannerBtn.addEventListener('click', function() {
            banner.style.display = 'none';
            body.classList.remove('banner-present');
        });
    }
});

document.addEventListener("DOMContentLoaded", fetchHomepageContent);