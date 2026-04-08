/**
 * content-protection.js
 * Additional layer: disables print, drag, right-click, and developer shortcut keys.
 */
(function () {
  // Disable print via Ctrl/Cmd+P
  window.addEventListener('beforeprint', function (e) { e.stopImmediatePropagation(); });
  document.addEventListener('keydown', function (e) {
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'p') {
      e.preventDefault();
      e.stopPropagation();
    }
  });

  // Block right-click context menu on the entire page (prevents "Save Image As")
  document.addEventListener('contextmenu', function (e) { e.preventDefault(); });

  // Prevent drag of images/text
  document.addEventListener('dragstart', function (e) { e.preventDefault(); });

  // Disable long-press save on images (iOS/Android)
  document.addEventListener('touchstart', function (e) {
    if (e.target.tagName === 'IMG') { e.preventDefault(); }
  }, { passive: false });

  // Overlay transparent div to block long-press select on mobile
  var shield = document.createElement('div');
  shield.style.cssText = [
    'position:fixed', 'top:0', 'left:0', 'width:100%', 'height:100%',
    'z-index:0', 'pointer-events:none', 'user-select:none',
    '-webkit-user-select:none'
  ].join(';');
  document.body.appendChild(shield);
})();
