(function () {
  function addLogoffButton() {
    var header = document.querySelector(".md-header__inner");
    if (!header) return;
    if (document.querySelector(".ntnx-logoff-btn")) return;

    var button = document.createElement("a");
    button.className = "ntnx-logoff-btn";
    button.href = "https://auth.nutanixed.com/logout";
    button.textContent = "Log off";
    button.setAttribute("aria-label", "Log off");

    header.appendChild(button);
  }

  function scheduleAdd() {
    addLogoffButton();
    // Material may re-render header after route changes; retry briefly.
    setTimeout(addLogoffButton, 100);
    setTimeout(addLogoffButton, 500);
  }

  var observer = new MutationObserver(function () {
    addLogoffButton();
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true,
  });

  if (window.document$ && typeof window.document$.subscribe === "function") {
    window.document$.subscribe(function () {
      scheduleAdd();
    });
  } else {
    document.addEventListener("DOMContentLoaded", scheduleAdd);
  }

  window.addEventListener("load", scheduleAdd);
})();
