var loadTime = window.performance.timing.domContentLoadedEventEnd - window.performance.timing.navigationStart;
console.log("page load time "+ loadTime / 1000 + "s");
