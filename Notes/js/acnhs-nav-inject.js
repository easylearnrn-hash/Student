/**
 * acnhs-nav-inject.js
 * Upgrades any HTML note page that uses the old .note-header pattern
 * to the full ACNHS premium site-nav + doc-hero design system.
 *
 * Included automatically via <script src="../js/acnhs-nav-inject.js" defer>
 * on all note pages. No per-file edits needed.
 */
(function () {

  /* ─── 1. INJECT GOOGLE FONTS if not present ─────────────────── */
  function ensureFonts() {
    if (document.querySelector('link[href*="Playfair+Display"]')) return;
    var lk = document.createElement('link');
    lk.rel = 'stylesheet';
    lk.href = 'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800&family=Inter:wght@300;400;500;600;700;800&display=swap';
    document.head.appendChild(lk);
  }

  /* ─── 2. INJECT NAV + HERO CSS (once per page) ───────────────── */
  var STYLE_ID = 'acnhs-nav-inject-styles';

  function ensureStyles() {
    if (document.getElementById(STYLE_ID)) return;
    var s = document.createElement('style');
    s.id = STYLE_ID;
    s.textContent = [
      /* reset body for nav height */
      'body.acnhs-nav-injected { font-family: \'Inter\', system-ui, -apple-system, sans-serif !important; }',
      'body.acnhs-nav-injected { padding-top: 72px !important; }',

      /* ── NAV ── */
      '.acnhs-site-nav {',
      '  position: fixed; top: 0; left: 0; right: 0; height: 72px;',
      '  background: rgba(2,10,24,0.96);',
      '  backdrop-filter: blur(24px) saturate(1.5);',
      '  -webkit-backdrop-filter: blur(24px) saturate(1.5);',
      '  border-bottom: 1px solid rgba(201,168,76,0.22);',
      '  box-shadow: 0 4px 32px rgba(0,0,0,0.6);',
      '  z-index: 2000;',
      '}',
      '.acnhs-nav-inner {',
      '  max-width: 1200px; margin: 0 auto; height: 100%;',
      '  padding: 0 40px;',
      '  display: flex; align-items: center; justify-content: space-between; gap: 20px;',
      '}',
      '.acnhs-nav-brand {',
      '  display: flex; align-items: center; gap: 12px;',
      '  text-decoration: none; flex-shrink: 0;',
      '}',
      '.acnhs-nav-logo {',
      '  width: 34px; height: 34px; border-radius: 50%;',
      '  border: 1.5px solid rgba(201,168,76,0.35);',
      '  object-fit: contain; padding: 2px;',
      '  flex-shrink: 0;',
      '}',
      '.acnhs-nav-brand-text { line-height: 1.2; }',
      '.acnhs-nav-brand-text .acnhs-t1 {',
      '  font-family: \'Playfair Display\', Georgia, serif;',
      '  font-size: 13.5px; font-weight: 700;',
      '  color: #c9a84c; letter-spacing: .01em; display: block;',
      '}',
      '.acnhs-nav-brand-text .acnhs-t2 {',
      '  font-size: 9.5px; font-weight: 600;',
      '  color: #4a4030; letter-spacing: .06em;',
      '  text-transform: uppercase; display: block;',
      '}',
      '.acnhs-nav-crumb {',
      '  display: flex; align-items: center; gap: 6px;',
      '  font-size: 11px; font-weight: 700; letter-spacing: .07em;',
      '  text-transform: uppercase; color: #4a4030;',
      '  flex: 1; justify-content: center;',
      '}',
      '.acnhs-nav-crumb .sep { color: #c9a84c; }',
      '.acnhs-nav-crumb .curr { color: #d4b56a; }',
      '.acnhs-nav-back {',
      '  display: inline-flex; align-items: center; gap: 7px;',
      '  background: rgba(201,168,76,0.08);',
      '  border: 1px solid rgba(201,168,76,0.28);',
      '  color: #d4b56a;',
      '  padding: 8px 20px; border-radius: 999px;',
      '  font-size: 12px; font-weight: 700; letter-spacing: .04em;',
      '  text-decoration: none;',
      '  transition: background .2s, border-color .2s, color .2s, transform .2s, box-shadow .2s;',
      '  flex-shrink: 0; white-space: nowrap;',
      '}',
      '.acnhs-nav-back:hover {',
      '  background: rgba(201,168,76,0.16);',
      '  border-color: #c9a84c; color: #fff;',
      '  transform: translateY(-1px);',
      '  box-shadow: 0 6px 18px rgba(201,168,76,0.18);',
      '}',

      /* ── HERO ── */
      '.acnhs-doc-hero {',
      '  position: relative;',
      '  max-width: 880px; margin: 0 auto;',
      '  padding: 52px 40px 44px;',
      '  border-bottom: 1px solid rgba(201,168,76,0.22);',
      '  margin-bottom: 48px;',
      '  overflow: hidden;',
      '}',
      '.acnhs-doc-hero::before {',
      '  content: \'\'; position: absolute; top: -80px; right: -80px;',
      '  width: 340px; height: 340px;',
      '  background: radial-gradient(circle, rgba(201,168,76,.07), transparent 65%);',
      '  pointer-events: none;',
      '}',
      '.acnhs-doc-hero::after {',
      '  content: \'\'; position: absolute; bottom: -1px; left: 0;',
      '  width: 100px; height: 2px;',
      '  background: linear-gradient(90deg, #c9a84c, transparent);',
      '}',
      '.acnhs-hero-eyebrow {',
      '  display: inline-flex; align-items: center; gap: 8px;',
      '  background: rgba(201,168,76,0.08);',
      '  border: 1px solid rgba(201,168,76,0.28);',
      '  color: #d4b56a;',
      '  font-size: 10px; font-weight: 800; letter-spacing: .14em;',
      '  text-transform: uppercase; padding: 6px 14px;',
      '  border-radius: 999px; margin-bottom: 18px;',
      '}',
      '.acnhs-hero-eyebrow::before {',
      '  content: \'\'; width: 6px; height: 6px;',
      '  background: #c9a84c; border-radius: 50%;',
      '}',
      '.acnhs-hero-title {',
      '  font-family: \'Playfair Display\', Georgia, serif;',
      '  font-size: clamp(1.85rem, 4vw, 2.7rem);',
      '  font-weight: 800; color: #f0ece3;',
      '  letter-spacing: -.4px; line-height: 1.15;',
      '  margin-bottom: 14px;',
      '}',
      '.acnhs-hero-subtitle {',
      '  font-size: 15px; color: #8a8070;',
      '  line-height: 1.7; max-width: 640px;',
      '  margin-bottom: 22px;',
      '}',
      '.acnhs-hero-meta {',
      '  display: flex; align-items: center; gap: 16px;',
      '  flex-wrap: wrap; font-size: 11px; font-weight: 600;',
      '  color: #4a4030; letter-spacing: .04em; text-transform: uppercase;',
      '}',
      '.acnhs-hero-pill {',
      '  display: inline-flex; align-items: center; gap: 5px;',
      '  background: rgba(255,255,255,.04);',
      '  border: 1px solid rgba(255,255,255,.07);',
      '  padding: 4px 12px; border-radius: 999px;',
      '}',

      /* ── PRINT ── */
      '@media print { .acnhs-site-nav { display: none !important; } body.acnhs-nav-injected { padding-top: 0 !important; } }',

      /* ── MOBILE ── */
      '@media (max-width: 768px) {',
      '  .acnhs-nav-inner { padding: 0 20px; }',
      '  .acnhs-nav-crumb { display: none; }',
      '  .acnhs-doc-hero { padding: 36px 20px 32px; margin-bottom: 32px; }',
      '  .acnhs-hero-title { font-size: 1.65rem; }',
      '}'
    ].join('\n');
    document.head.appendChild(s);
  }

  /* ─── 3. BUILD PORTAL URL (same logic as med-abbr-tooltip.js) ── */
  function buildPortalUrl() {
    try {
      var href = window.location.href;
      var notesIdx = href.search(/\/[Nn]otes\//);
      if (notesIdx !== -1) return href.slice(0, notesIdx) + '/student-portal.html';
      var origin = window.location.origin;
      if (origin && origin !== 'null') return origin + '/student-portal.html';
      var parts = window.location.pathname.split('/');
      parts.pop(); parts.pop(); parts.pop();
      return 'file://' + parts.join('/') + '/student-portal.html';
    } catch (e) {
      return '/student-portal.html';
    }
  }

  /* ─── 4. BUILD LOGO URL relative to note depth ───────────────── */
  function buildLogoUrl() {
    try {
      var href = window.location.href;
      var notesIdx = href.search(/\/[Nn]otes\//);
      if (notesIdx !== -1) return href.slice(0, notesIdx) + '/Notes/img/acnhs-seal.png';
    } catch (e) {}
    return '';
  }

  /* ─── 5. MAIN: replace .note-header with premium nav + hero ─── */
  function upgradeHeader() {
    var oldHeader = document.querySelector('header.note-header');
    if (!oldHeader) return; // already premium or no old header

    /* Extract data from old header */
    var tagEl      = oldHeader.querySelector('.note-tag');
    var titleEl    = oldHeader.querySelector('h1');
    var subtitleEl = oldHeader.querySelector('.subtitle, p.subtitle, .note-subtitle');

    var category = tagEl      ? tagEl.textContent.trim()      : 'ACNHS Notes';
    var title    = titleEl    ? titleEl.textContent.trim()     : document.title.replace(/\s*\|.*$/, '').trim();
    var subtitle = subtitleEl ? subtitleEl.textContent.trim()  : '';

    var portalUrl = buildPortalUrl();
    var logoUrl   = buildLogoUrl();

    /* ── Build the nav ── */
    var nav = document.createElement('nav');
    nav.className = 'acnhs-site-nav';
    nav.setAttribute('aria-label', 'Primary');
    nav.innerHTML =
      '<div class="acnhs-nav-inner">' +
        '<a href="' + portalUrl + '" class="acnhs-nav-brand">' +
          (logoUrl ? '<img class="acnhs-nav-logo" src="' + logoUrl + '" alt="ACNHS Seal" onerror="this.style.display=\'none\'">' : '') +
          '<div class="acnhs-nav-brand-text">' +
            '<span class="acnhs-t1">Armenian College of Nursing</span>' +
            '<span class="acnhs-t2">&amp; Health Sciences</span>' +
          '</div>' +
        '</a>' +
        '<nav class="acnhs-nav-crumb" aria-label="Breadcrumb">' +
          '<span>ACNHS</span>' +
          '<span class="sep">&rsaquo;</span>' +
          '<span>Notes</span>' +
          '<span class="sep">&rsaquo;</span>' +
          '<span class="curr">' + _esc(category) + '</span>' +
        '</nav>' +
        '<a href="' + portalUrl + '" class="acnhs-nav-back">' +
          '<svg width="13" height="13" viewBox="0 0 13 13" fill="none" aria-hidden="true">' +
            '<path d="M8 2.5L4 6.5L8 10.5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>' +
          '</svg>' +
          '&#8592; Back to Portal' +
        '</a>' +
      '</div>';

    /* ── Build the hero ── */
    var hero = document.createElement('div');
    hero.className = 'acnhs-doc-hero';
    hero.innerHTML =
      '<div class="acnhs-hero-eyebrow">' + _esc(category) + '</div>' +
      '<h1 class="acnhs-hero-title">' + _esc(title) + '</h1>' +
      (subtitle ? '<p class="acnhs-hero-subtitle">' + _esc(subtitle) + '</p>' : '') +
      '<div class="acnhs-hero-meta">' +
        '<span class="acnhs-hero-pill">ACNHS &middot; 2026</span>' +
        '<span class="acnhs-hero-pill">Study Guide</span>' +
      '</div>';

    /* ── Replace old header ── */
    var parent = oldHeader.parentNode;
    parent.insertBefore(nav, oldHeader);
    parent.insertBefore(hero, oldHeader);
    parent.removeChild(oldHeader);

    /* ── Mark body so padding-top CSS kicks in ── */
    document.body.classList.add('acnhs-nav-injected');

    /* ── Wire up click listeners for portal navigation ── */
    [nav.querySelector('.acnhs-nav-brand'), nav.querySelector('.acnhs-nav-back')].forEach(function (el) {
      if (!el) return;
      el.addEventListener('click', function (e) {
        e.preventDefault();
        window.location.href = portalUrl;
      });
    });
  }

  /* ─── 6. HTML-escape helper ─────────────────────────────────── */
  function _esc(str) {
    return (str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  /* ─── 7. INIT ────────────────────────────────────────────────── */
  function init() {
    ensureFonts();
    ensureStyles();
    upgradeHeader();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
