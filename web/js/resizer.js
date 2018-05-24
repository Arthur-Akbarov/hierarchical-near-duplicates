window.addEventListener("load", function() {
    var prevY;
    var top = document.getElementById("top");
    var bottom = document.getElementById("bottom");
    var resizer = document.getElementById("resizer");

    var documentPx = parseFloat(window.getComputedStyle(document.documentElement).height);
    var topPx = parseFloat(window.getComputedStyle(top).height);
    var bottomPx = parseFloat(window.getComputedStyle(bottom).height);
    var resizerPx = parseFloat(window.getComputedStyle(resizer).height);

    top.style.height = topPx / documentPx * 100 + "vh";
    bottom.style.height = bottomPx / documentPx * 100 + "vh";
    var resizerVh = resizerPx / documentPx * 100;

    resizer.addEventListener("mousedown", initResize, false);

    function initResize(e) {
        documentPx = parseFloat(window.getComputedStyle(document.documentElement).height);
        prevY = e.clientY;
        window.addEventListener("mousemove", Resize, false);
        window.addEventListener("mouseup", stopResize, false);
    }
    function Resize(e) {
        var delta = e.clientY - prevY;
        prevY = e.clientY;

        top.style.height = top.clientHeight + delta + "px";
        bottom.style.height = documentPx - top.clientHeight - delta - resizerPx + "px";
    }
    function stopResize(e) {
        topVh = top.clientHeight / documentPx * 100;
        topVh = Math.min(topVh, 100 - resizerVh);

        top.style.height = topVh + "vh";
        bottom.style.height = 100 - topVh - resizerVh + "vh";

        window.removeEventListener("mousemove", Resize, false);
        window.removeEventListener("mouseup", stopResize, false);
    }
});
