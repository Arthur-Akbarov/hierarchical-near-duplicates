var toggleSourcePaneButton = document.getElementById("toggleSourcePane");

function toggleSourcePane() {
    if (toggleSourcePaneButton.innerHTML == "show source") {
        if (document.getElementById('bottom').innerHTML.trim().length == 0)
            loadInsertSource();

        toggleSourcePaneButton.innerHTML = "hide source";
        document.getElementById("top").style.height = "49vh";
        document.getElementById("bottom").style.height = "49vh";
    } else {
        toggleSourcePaneButton.innerHTML = "show source";
        document.getElementById("top").style.height = "98vh";
        document.getElementById("bottom").style.height = "0vh";
    }
}
