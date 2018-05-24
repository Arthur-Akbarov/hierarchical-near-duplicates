function loadScript(url) {
    var js = document.createElement("script");
    js.src = url;
    document.head.appendChild(js);
}

loadScript('../js/pageLoadTime.js');
loadScript('../js/freezeSidebar.js');
loadScript('../js/styleSwitcher.js');
loadScript('../js/toggleTheme.js');
