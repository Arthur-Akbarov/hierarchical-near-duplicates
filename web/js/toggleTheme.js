var toggleThemeButton = document.getElementById("toggleTheme");

function toggleTheme() {
    if (toggleThemeButton.innerHTML == "dark theme") {
        toggleThemeButton.innerHTML = "light theme";
        setActiveStyleSheet("dark");
    } else {
        toggleThemeButton.innerHTML = "dark theme";
        setActiveStyleSheet("light");
    }
}
