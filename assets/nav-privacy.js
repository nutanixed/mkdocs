(function () {

  function normalizePath(href) {
    try {
      var url = new URL(href, window.location.href);
      return url.pathname.replace(/\/+$/, "") || "/";
    } catch (e) {
      return "";
    }
  }

  function isInternalRoot(path) {
    return /^\/Internal(?:\/index)?$/i.test(path);
  }

  function isInternalChild(path) {
    return /^\/Internal\/.+/i.test(path) && !isInternalRoot(path);
  }

  function applyInternalNavVisibility() {
    var inInternalSection = /^\/Internal(\/|$)/i.test(window.location.pathname);
    var navItems = document.querySelectorAll(".md-sidebar .md-nav__item");

    navItems.forEach(function (item) {
      item.style.display = "";
    });

    if (inInternalSection) return;

    navItems.forEach(function (item) {
      var links = Array.prototype.slice.call(
        item.querySelectorAll("a.md-nav__link[href]")
      );
      if (!links.length) return;

      var paths = links.map(function (link) {
        return normalizePath(link.getAttribute("href"));
      });

      var hasInternalRoot = paths.some(isInternalRoot);
      var hasInternalChild = paths.some(isInternalChild);

      if (hasInternalChild && !hasInternalRoot) {
        item.style.display = "none";
        return;
      }

      if (hasInternalRoot) {
        var descendants = item.querySelectorAll(".md-nav__item");
        descendants.forEach(function (child) {
          child.style.display = "none";
        });
      }
    });
  }

  function applyNavRules() {
    applyInternalNavVisibility();
  }

  var observer = new MutationObserver(function () {
    applyNavRules();
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true,
  });

  if (window.document$ && typeof window.document$.subscribe === "function") {
    window.document$.subscribe(function () {
      applyNavRules();
    });
  } else {
    document.addEventListener("DOMContentLoaded", applyNavRules);
  }

  window.addEventListener("popstate", applyNavRules);
  window.addEventListener("hashchange", applyNavRules);
})();
