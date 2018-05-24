function loadScript(url) {
    var js = document.createElement("script");
    js.src = url;
    document.head.appendChild(js);
}

loadScript('js/addCopyLineNumberHandler.js');
loadScript('js/anchor.js');
loadScript('js/loadInsertSource.js');
loadScript('js/pageLoadTime.js');
loadScript('js/freezeSidebar.js');
loadScript('js/resizer.js');
loadScript('js/styleSwitcher.js');
loadScript('js/toggleSourcePane.js');
loadScript('js/toggleTheme.js');

