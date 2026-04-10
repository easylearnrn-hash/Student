/**
 * no-copy.js
 * Prevents text selection, copy, and right-click on note pages.
 */
(function () {
  document.addEventListener('contextmenu', function (e) { e.preventDefault(); });
  document.addEventListener('selectstart', function (e) { e.preventDefault(); });
  document.addEventListener('copy', function (e) { e.preventDefault(); });
  document.addEventListener('cut',  function (e) { e.preventDefault(); });
  document.addEventListener('keydown', function (e) {
    // Block Ctrl/Cmd + C, A, S, P, U and F12
    if ((e.ctrlKey || e.metaKey) && ['c','a','s','p','u'].includes(e.key.toLowerCase())) {
      e.preventDefault();
    }
    if (e.key === 'F12') e.preventDefault();
  });
})();
