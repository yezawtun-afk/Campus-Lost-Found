/* Campus Lost & Found - page behaviour.
   Two small jobs: fade the page blocks in on load, and let the
   "Recently reported" chapter switch between Lost, Found and Claimed.
   Everything works without this file: sections are visible and the switch
   links through to the search page. */
(function () {
    "use strict";

    var root = document.documentElement;

    /* --- 1. Section entrances --------------------------------------------
       Blocks fade in together, in document order, one beat apart. Nothing is
       held back until a scroll position is reached, so content can never stay
       hidden if a script does not run. */
    var reveals = Array.prototype.slice.call(document.querySelectorAll("[data-reveal]"));

    reveals.forEach(function (element, index) {
        if (!element.style.getPropertyValue("--reveal-delay")) {
            element.style.setProperty("--reveal-delay", Math.min(index, 5) * 70 + "ms");
        }
    });

    /* Two frames: the first paints the hidden state, the second starts the fade. */
    window.requestAnimationFrame(function () {
        window.requestAnimationFrame(function () {
            reveals.forEach(function (element) {
                element.classList.add("is-in");
            });
        });
    });

    /* Tell the watchdog in the page head that the reveal script is running,
       so it never strips the "js" class from under a working page. */
    root.setAttribute("data-motion-ready", "true");

    /* --- 2. Recent-items status switch ----------------------------------- */
    var switcher = document.querySelector("[data-field-switch]");
    var chapter = document.getElementById("recent");

    if (!switcher || !chapter) {
        return;
    }

    var buttons = Array.prototype.slice.call(switcher.querySelectorAll("[data-filter]"));
    var cards = Array.prototype.slice.call(document.querySelectorAll("[data-recent] [data-status]"));
    var empty = document.querySelector("[data-recent-empty]");

    var apply = function (status) {
        var shown = 0;

        chapter.setAttribute("data-field", status ? status.toLowerCase() : "all");

        cards.forEach(function (card) {
            var matches = !status || card.getAttribute("data-status") === status;
            card.hidden = !matches;
            if (matches) {
                shown += 1;
            }
        });

        if (empty) {
            var label = empty.querySelector("[data-empty-label]");
            if (label) {
                label.textContent = status ? status.toLowerCase() : "listed";
            }
            empty.hidden = shown !== 0;
        }

        buttons.forEach(function (button) {
            var isOn = button.getAttribute("data-filter") === status;
            button.classList.toggle("is-active", isOn);
            if (isOn) {
                button.setAttribute("aria-current", "true");
            } else {
                button.removeAttribute("aria-current");
            }
        });
    };

    buttons.forEach(function (button) {
        button.addEventListener("click", function (event) {
            event.preventDefault();
            apply(button.getAttribute("data-filter"));
        });
    });
}());
