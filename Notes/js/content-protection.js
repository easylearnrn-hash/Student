/**
 * content-protection.js
 * Additional layer: disables print, drag, and developer shortcut keys.
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

  // Prevent drag of images/text
  document.addEventListener('dragstart', function (e) { e.preventDefault(); });

  // Overlay transparent div to block long-press select on mobile
  var shield = document.createElement('div');
  shield.style.cssText = [
    'position:fixed', 'top:0', 'left:0', 'width:100%', 'height:100%',
    'z-index:0', 'pointer-events:none', 'user-select:none',
    '-webkit-user-select:none'
  ].join(';');
  document.body.appendChild(shield);
})();
