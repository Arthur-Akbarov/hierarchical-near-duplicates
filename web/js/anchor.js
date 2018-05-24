window.addEventListener("load", function() {
    var defaultTdColor = window.getComputedStyle(document.querySelector("td:first-of-type")).color;
    var highlightTdColor = "#ef9b0f";

    var startNumber, endNumber;

    document.querySelectorAll("#top tr").forEach(function(row) {
        row.addEventListener("dblclick", function() {
            if (typeof startNumber !== "undefined")
                for (var i = startNumber; i <= endNumber; i++) {
                    document.getElementsByName(i)[0].parentNode.style.color = defaultTdColor;

                    context = document.getElementsByName(i)[0].parentNode.nextElementSibling;
                    context.innerHTML = context.textContent;
                }

            var curRow = row;
            var startRow = curRow;
            while (true) {
                curRow = curRow.previousElementSibling;

                if (curRow == null || curRow.classList.contains("padding"))
                    break;

                // console.log("curRowNumber = " + parseInt(curRow.firstElementChild.textContent));
                startRow = curRow;
            }
            startNumber = parseInt(startRow.firstElementChild.textContent);
            // console.log("startNumber = " + startNumber);

            var endRow = curRow = row;
            while (true) {
                curRow = curRow.nextElementSibling;

                if (curRow == null || curRow.classList.contains("padding"))
                    break;

                // console.log("curRowNumber = " + parseInt(curRow.firstElementChild.textContent));
                endRow = curRow;
            }
            endNumber = parseInt(endRow.firstElementChild.textContent);
            // console.log("endNumber = " + endNumber);

            for (i = startNumber; i <= endNumber; i++)
                document.getElementsByName(i)[0].parentNode.style.color = highlightTdColor;

            for (curRow = startRow; curRow !== endRow; curRow = curRow.nextElementSibling)
                highlightSource(curRow);

            var url = location.href;                 // save down the URL without hash
            location.href = "#" + startNumber;       // go to the target element
            history.replaceState(null, null, url);   // don't like hashes, changing it back
        });
    });
});

function highlightSource(row) {
    var lineNumber = parseInt(row.firstElementChild.textContent);
    // console.log("lineNumber = " + lineNumber);

    var highlightedTerm = row.children[1].innerHTML;
    // console.log("highlightedTerm = " + highlightedTerm);

    textNode = document.getElementsByName(lineNumber)[0].parentNode.nextElementSibling;
    textNode.innerHTML = highlightedTerm;
}
