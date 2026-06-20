/**
 * content-protection.js
 * Additional layer: disables print, drag, right-click, and developer shortcut keys.
 * Text selection/copy is blocked for students; admin (hrachfilm@gmail.com) is exempt.
 */
(function () {
  /* ── Admin check ──────────────────────────────────────────────── */
  function extractEmail(v) {
    if (!v) return '';
    if (typeof v === 'string') {
      var t = v.trim();
      if (!t) return '';
      if (t[0] === '{') { try { return extractEmail(JSON.parse(t)); } catch(e){} }
      return t;
    }
    if (typeof v === 'object') {
      return v.email ||
             (v.user && v.user.email) ||
             (v.session && v.session.user && v.session.user.email) || '';
    }
    return '';
  }
  var currentEmail = '';
  try {
    currentEmail = (extractEmail(localStorage.getItem('arnoma:auth:user')) ||
                    extractEmail(localStorage.getItem('arnoma:auth:session'))).trim().toLowerCase();
  } catch(e) {}
  var isAdmin = currentEmail === 'hrachfilm@gmail.com';

  /* ── Print blocking (everyone) ────────────────────────────────── */
  window.addEventListener('beforeprint', function (e) { e.stopImmediatePropagation(); });
  document.addEventListener('keydown', function (e) {
    var key = e.key.toLowerCase();
    if ((e.ctrlKey || e.metaKey) && key === 'p') {
      e.preventDefault();
      e.stopPropagation();
    }
    /* Block copy/cut shortcuts for students */
    if (!isAdmin && (e.ctrlKey || e.metaKey) && (key === 'c' || key === 'x' || key === 'a')) {
      e.preventDefault();
      e.stopPropagation();
    }
  });

  /* ── Right-click & drag (everyone) ───────────────────────────── */
  document.addEventListener('contextmenu', function (e) { e.preventDefault(); });
  document.addEventListener('dragstart',   function (e) { e.preventDefault(); });

  /* ── Touch protection (everyone) ─────────────────────────────── */
  document.addEventListener('touchstart', function (e) {
    if (e.target.tagName === 'IMG') { e.preventDefault(); }
  }, { passive: false });

  /* ── Text selection / copy blocking (students only) ──────────── */
  if (!isAdmin) {
    /* CSS: disable selection on root and body */
    var noSelectStyle = document.createElement('style');
    noSelectStyle.textContent = '*, *::before, *::after { -webkit-user-select: none !important; user-select: none !important; }';
    document.head.appendChild(noSelectStyle);

    /* JS: intercept copy and cut events */
    document.addEventListener('copy',        function (e) { e.preventDefault(); e.stopImmediatePropagation(); }, true);
    document.addEventListener('cut',         function (e) { e.preventDefault(); e.stopImmediatePropagation(); }, true);
    document.addEventListener('selectstart', function (e) { e.preventDefault(); }, true);
  }

  /* ── Overlay shield (everyone — blocks long-press on mobile) ─── */
  var shield = document.createElement('div');
  shield.style.cssText = [
    'position:fixed', 'top:0', 'left:0', 'width:100%', 'height:100%',
    'z-index:0', 'pointer-events:none', 'user-select:none',
    '-webkit-user-select:none'
  ].join(';');
  document.body.appendChild(shield);
})();
