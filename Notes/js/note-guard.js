/**
 * note-guard.js
 * Removes the body-hide guard style so the note page becomes visible.
 * This must be the last script in <body> so the DOM is ready.
 */
(function () {
  var guard = document.getElementById('acnhs-guard-hide');
  if (guard) guard.parentNode.removeChild(guard);
})();
