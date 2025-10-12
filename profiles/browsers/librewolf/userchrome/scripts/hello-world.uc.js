// ==UserScript==
// @name           Hello World
// @description    Simple hello world test for userChrome.js
// @author         padraic
// ==/UserScript==

(function() {
  // Wait for browser window to be fully loaded
  if (location != "chrome://browser/content/browser.xhtml") {
    return;
  }

  // Show alert on first browser window load
  setTimeout(() => {
    alert("Hello World from userChrome.js!\n\nThe modular loader is working!");
  }, 1000);

})();
