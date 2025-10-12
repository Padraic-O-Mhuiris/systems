// ==UserScript==
// @name           News Redirect to Archive
// @description    Automatically redirect paywalled news sites to archive.is
// @author         padraic
// @ignorecache
// ==/UserScript==

(function() {
  if (location != "chrome://browser/content/browser.xhtml") {
    return;
  }

  console.log('[News Redirect] Script loaded in browser chrome');

  // List of paywalled news domains to redirect
  const PAYWALLED_SITES = [
    'nytimes.com',
    'independent.ie',
    'ft.com',
    'businesspost.ie',
    'irishtimes.com'
  ];

  // Archive services (archive.is is primary, these are mirrors/alternatives)
  const ARCHIVE_SERVICES = [
    'https://archive.is/',
    'https://archive.ph/',
    'https://archive.today/'
  ];

  const PRIMARY_ARCHIVE = ARCHIVE_SERVICES[0];

  // Check if URL should be redirected
  function shouldRedirect(url) {
    try {
      const urlObj = new URL(url);
      const matches = PAYWALLED_SITES.some(site => urlObj.hostname.includes(site));
      console.log('[News Redirect] Checking URL:', url, 'hostname:', urlObj.hostname, 'matches:', matches);
      return matches;
    } catch (e) {
      console.log('[News Redirect] Invalid URL:', url, e);
      return false;
    }
  }

  // Check if an archive exists for a given URL
  async function checkArchiveExists(newsUrl) {
    // Use Memento timemap API to check for snapshots
    // Format: https://archive.is/timemap/[original-url]
    const timemapUrl = PRIMARY_ARCHIVE + 'timemap/' + newsUrl;

    try {
      console.log('[News Redirect] Checking for existing archive:', timemapUrl);
      const response = await fetch(timemapUrl, { method: 'HEAD' });

      // If timemap exists (200), there are snapshots
      // If 404, no snapshots exist
      const exists = response.ok;
      console.log('[News Redirect] Archive exists?', exists);
      return exists;
    } catch (e) {
      console.log('[News Redirect] Error checking archive:', e);
      return false;
    }
  }

  // Get archive URL for a given news URL
  function getArchiveUrl(newsUrl) {
    // Archive.is supports Memento API for finding snapshots
    // Using the "newest" endpoint gets the most recent snapshot
    // Format: https://archive.is/newest/[original-url]
    return PRIMARY_ARCHIVE + 'newest/' + newsUrl;
  }

  // Show loading indicator by injecting into about:blank
  function showLoadingIndicator(browser, message) {
    // Load a simple HTML page with the loading indicator
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Checking Archive...</title>
        <style>
          body {
            margin: 0;
            padding: 0;
            background: #1a1a1a;
            font-family: system-ui, -apple-system, sans-serif;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
          }
          .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 12px;
            text-align: center;
            backdrop-filter: blur(10px);
          }
          .message {
            font-size: 18px;
            margin-bottom: 20px;
          }
          .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto;
          }
          @keyframes spin {
            to { transform: rotate(360deg); }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="message">${message}</div>
          <div class="spinner"></div>
        </div>
      </body>
      </html>
    `;

    const dataURI = 'data:text/html;charset=utf-8,' + encodeURIComponent(html);
    browser.loadURI(Services.io.newURI(dataURI), {
      triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal(),
    });
  }

  // Update loading message (not used since we redirect after check)
  function updateLoadingMessage(browser, message, isSuccess) {
    // Not practical with data URI approach - just redirect immediately
  }

  // Remove loading indicator (not needed - redirect will replace it)
  function hideLoadingIndicator(browser) {
    // Not needed - redirect will replace the loading page
  }

  // Monitor tab for redirects
  function setupTabRedirect(tab) {
    const browser = tab.linkedBrowser;

    // Track the last URL we're processing to prevent immediate re-processing
    let processingUrl = null;
    let processingTimeout = null;

    // Listen for location changes in this tab
    const progressListener = {
      QueryInterface: ChromeUtils.generateQI([
        "nsIWebProgressListener",
        "nsISupportsWeakReference",
      ]),

      onStateChange: function(aWebProgress, aRequest, aStateFlags, aStatus) {
        // Only check top-level document loads, not iframes or sub-resources
        if (!(aStateFlags & Ci.nsIWebProgressListener.STATE_START &&
              aStateFlags & Ci.nsIWebProgressListener.STATE_IS_DOCUMENT &&
              aWebProgress.isTopLevel)) {
          return;
        }

        const url = aRequest?.QueryInterface(Ci.nsIChannel)?.URI?.spec;
        if (!url) return;

        console.log('[News Redirect] Top-level document load starting:', url);

        try {
          // Prevent processing the same URL multiple times in quick succession
          if (processingUrl === url) {
            console.log('[News Redirect] Already processing this URL, skipping to avoid loop');
            return;
          }

          // Avoid redirect loops
          if (ARCHIVE_SERVICES.some(service => url.startsWith(service))) {
            console.log('[News Redirect] Already on archive site, skipping');
            return;
          }

          if (shouldRedirect(url)) {
            // Mark this URL as being processed
            processingUrl = url;

            // Clear after 5 seconds to allow re-checking if user navigates back
            if (processingTimeout) {
              clearTimeout(processingTimeout);
            }
            processingTimeout = setTimeout(() => {
              processingUrl = null;
            }, 5000);
            console.log('[News Redirect] ✓ Paywalled article detected, checking for archive...');

            // Try to cancel the request (may not always work for all request types)
            try {
              aRequest.cancel(Components.results.NS_BINDING_ABORTED);
            } catch (e) {
              // If cancel fails, we'll redirect anyway
              console.log('[News Redirect] Could not cancel request, will redirect after check');
            }

            // Show loading indicator immediately
            showLoadingIndicator(browser, 'Checking for archived version...');

            // Check if archive exists asynchronously
            checkArchiveExists(url).then(exists => {
              if (exists) {
                const archiveUrl = getArchiveUrl(url);
                console.log(`[News Redirect] ✓ Archive found! Redirecting to ${archiveUrl}`);

                // Redirect to archive
                browser.loadURI(Services.io.newURI(archiveUrl), {
                  triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal(),
                });
              } else {
                console.log('[News Redirect] ✗ No archive found, loading original URL');

                // Load the original URL
                browser.loadURI(Services.io.newURI(url), {
                  triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal(),
                });
              }
            }).catch(e => {
              console.log('[News Redirect] Error checking archive, loading original URL:', e);

              // Load original on error
              browser.loadURI(Services.io.newURI(url), {
                triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal(),
              });
            });
          }
        } catch (e) {
          console.log('[News Redirect] Error processing URL:', e);
        }
      },

      onLocationChange: function(aWebProgress, aRequest, aLocation, aFlags) {
        // Backup: also check on location change (for edge cases)
        if (aFlags & Ci.nsIWebProgressListener.LOCATION_CHANGE_SAME_DOCUMENT) {
          return;
        }

        const url = aLocation.spec;
        console.log('[News Redirect] Location changed to:', url);
      },

      onProgressChange: function() {},
      onStatusChange: function() {},
      onSecurityChange: function() {},
      onContentBlockingEvent: function() {},
    };

    browser.addProgressListener(
      progressListener,
      Ci.nsIWebProgress.NOTIFY_STATE_DOCUMENT | Ci.nsIWebProgress.NOTIFY_LOCATION
    );
    console.log('[News Redirect] Progress listener attached to tab');

    // Also intercept link clicks at the content level
    browser.addEventListener("click", function(event) {
      const link = event.target.closest('a');
      if (!link || !link.href) return;

      const url = link.href;
      console.log('[News Redirect] Link clicked:', url);

      // Check if this is a paywalled site
      if (shouldRedirect(url)) {
        // Prevent default navigation
        event.preventDefault();
        event.stopPropagation();

        console.log('[News Redirect] ✓ Paywalled link clicked, checking for archive...');

        // Show loading indicator
        showLoadingIndicator(browser, 'Checking for archived version...');

        // Check if archive exists
        checkArchiveExists(url).then(exists => {
          if (exists) {
            const archiveUrl = getArchiveUrl(url);
            console.log(`[News Redirect] ✓ Archive found! Redirecting to ${archiveUrl}`);
            browser.loadURI(Services.io.newURI(archiveUrl), {
              triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal(),
            });
          } else {
            console.log('[News Redirect] ✗ No archive found, loading original URL');
            browser.loadURI(Services.io.newURI(url), {
              triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal(),
            });
          }
        }).catch(e => {
          console.log('[News Redirect] Error checking archive, loading original URL:', e);
          browser.loadURI(Services.io.newURI(url), {
            triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal(),
          });
        });
      }
    }, true);
  }

  // Setup redirect for existing and new tabs
  function init() {
    const browser = window.gBrowser || window._gBrowser;
    if (!browser) {
      console.error('[News Redirect] gBrowser not available!');
      return;
    }

    console.log('[News Redirect] Setting up for', browser.tabs.length, 'existing tabs');

    // Setup for all existing tabs
    for (let tab of browser.tabs) {
      setupTabRedirect(tab);
    }

    // Setup for new tabs
    browser.tabContainer.addEventListener("TabOpen", (event) => {
      console.log('[News Redirect] New tab opened, attaching listener');
      setupTabRedirect(event.target);
    });

    console.log('[News Redirect] ✓ Initialization complete. Watching:', PAYWALLED_SITES);
  }

  // Wait for browser to be ready
  if (document.readyState === "complete") {
    init();
  } else {
    window.addEventListener("load", init, { once: true });
  }

})();
