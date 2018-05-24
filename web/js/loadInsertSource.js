var startLoadInsertSource, endLoadInsertSource;

function loadInsertSource() {
    startLoadInsertSource = new Date().getTime() / 1000;
    sourceTitle = document.head.querySelector("meta[name=sourceTitle]").content;
    var js = document.createElement("script");
    js.src = "../../../js/sources/" + sourceTitle + ".js";
    js.setAttribute("onload", "insertSource()")
    document.body.appendChild(js);
}

function insertSource() {
    var insertSource = setInterval(function() { if (document.readyState === "complete") {
        clearInterval(insertSource);

        document.getElementById('bottom').innerHTML =
            '<div id="loader">source is loading<span>.</span><span>.</span><span>.</span></div>';

        var appendSource = setInterval(function() { if (document.readyState === "complete") {
            clearInterval(appendSource);

            document.getElementById('bottom').innerHTML = getSource();

            var measureTime = setInterval(function() { if (document.readyState === "complete") {
                clearInterval(measureTime);

                endLoadInsertSource = new Date().getTime() / 1000;
                console.log("source load time "+ (endLoadInsertSource - startLoadInsertSource) + "s");
                addCopyLineNumberHandler("#bottom td:first-of-type", "click");
            }}, 50);
        }}, 50);
    }}, 50);
}
