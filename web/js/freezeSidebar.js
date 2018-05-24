window.addEventListener("load", function() {
    var sidebar = document.querySelector("#sidebar");
    var sidebarStyle = window.getComputedStyle(sidebar);

    var sidebarPx = parseFloat(sidebarStyle.width);
    var documentWidthPx = parseFloat(window.getComputedStyle(document.documentElement).width);
    var documentHeightPx = parseFloat(window.getComputedStyle(document.documentElement).height);

    var sidebarVh = sidebarPx / documentWidthPx * 100;
    sidebar.style.width = sidebarVh + "%";

    var top = document.querySelector("#top");
    var topStyle = window.getComputedStyle(top);
    top.style.marginLeft = parseFloat(topStyle.marginLeft) / documentWidthPx * 100 + "vw";

    var resizer = document.querySelector("#resizer");
    if (resizer !== null) {
        var resizerStyle = window.getComputedStyle(resizer);
        resizer.style.marginLeft = parseFloat(resizerStyle.marginLeft) / documentWidthPx * 100 + "vw";
    }

    var bottom = document.querySelector("#bottom");
    if (bottom !== null) {
        var bottomStyle = window.getComputedStyle(bottom);
        bottom.style.marginLeft = parseFloat(bottomStyle.marginLeft) / documentWidthPx * 100 + "vw";
    }

    document.querySelectorAll("button").forEach(function(button) {
        var style = window.getComputedStyle(button);

        button.style.marginTop = parseFloat(style.marginTop) / documentHeightPx * 100 + "vh";
        button.style.marginBottom = parseFloat(style.marginBottom) / documentHeightPx * 100 + "vh";
        button.style.height = parseFloat(style.height) / documentHeightPx * 100 + "vh";
        button.style.fontSize = parseFloat(style.fontSize) / documentHeightPx * 100 + "vh";
        button.style.borderTopWidth = parseFloat(style.borderTopWidth) / documentHeightPx * 100 + "vh";
        button.style.borderBottomWidth = parseFloat(style.borderTopWidth) / documentHeightPx * 100 + "vh";
        button.style.borderRightWidth = parseFloat(style.borderRightWidth) / documentWidthPx * 100 + "vw";
        button.style.borderLeftWidth = parseFloat(style.borderLeftWidth) / documentWidthPx * 100 + "vw";
    });
});
