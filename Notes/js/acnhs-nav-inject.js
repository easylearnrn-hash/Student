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

      /* ── PRINT BUTTON ── */
      '.acnhs-print-btn {',
      '  display: inline-flex; align-items: center; gap: 7px;',
      '  background: rgba(201,168,76,0.08);',
      '  border: 1px solid rgba(201,168,76,0.28);',
      '  color: #d4b56a;',
      '  padding: 8px 16px; border-radius: 999px;',
      '  font-size: 12px; font-weight: 700; letter-spacing: .04em;',
      '  cursor: pointer;',
      '  transition: background .2s, border-color .2s, color .2s, transform .2s, box-shadow .2s;',
      '  flex-shrink: 0; white-space: nowrap;',
      '}',
      '.acnhs-print-btn:hover {',
      '  background: rgba(201,168,76,0.16);',
      '  border-color: #c9a84c; color: #fff;',
      '  transform: translateY(-1px);',
      '  box-shadow: 0 6px 18px rgba(201,168,76,0.18);',
      '}',
      '.acnhs-print-btn svg { flex-shrink: 0; }',

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
    /* Skip if nav already injected */
    if (document.querySelector('.acnhs-site-nav')) return;

    var oldHeader = document.querySelector('header.note-header');
    var category, title, subtitle;

    if (oldHeader) {
      /* ── Old-style header: extract from <header class="note-header"> ── */
      var tagEl      = oldHeader.querySelector('.note-tag, .category, [class*="tag"]');
      var titleEl    = oldHeader.querySelector('h1');
      var subtitleEl = oldHeader.querySelector('.subtitle, p.subtitle, .note-subtitle');

      category = tagEl      ? tagEl.textContent.trim()      : 'ACNHS Notes';
      title    = titleEl    ? titleEl.textContent.trim()     : document.title.replace(/\s*[\|–-].*$/, '').trim();
      subtitle = subtitleEl ? subtitleEl.textContent.trim()  : '';
    } else {
      /* ── New-style: bare <h1> + <p class="subtitle"> directly in body ── */
      var h1El  = document.querySelector('body > div h1, body > h1, .container h1, header h1');
      var subEl = document.querySelector('body > div p.subtitle, body > p.subtitle, .container p.subtitle, header p.subtitle');

      /* Try to infer category from page title or subtitle text */
      var rawTitle = document.title || '';
      var dashIdx  = rawTitle.search(/[\|–-]/);
      category = dashIdx !== -1 ? rawTitle.slice(dashIdx + 1).trim() : 'ACNHS Notes';
      title    = h1El  ? h1El.textContent.trim()  : rawTitle.replace(/\s*[\|–-].*$/, '').trim();
      subtitle = subEl ? subEl.textContent.replace(/^Maternal Health\s*[·\-]\s*/i, '').trim() : '';

      /* Hide the bare h1 + subtitle so they don't double-render under the hero */
      if (h1El)  h1El.style.display  = 'none';
      if (subEl) subEl.style.display = 'none';
    }

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
        '<button class="acnhs-print-btn" onclick="acnhsPrintNote()" title="Print this note">' +
          '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' +
            '<polyline points="6 9 6 2 18 2 18 9"/>' +
            '<path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/>' +
            '<rect x="6" y="14" width="12" height="8"/>' +
          '</svg>' +
          'Print' +
        '</button>' +
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

    /* ── Replace old header OR prepend to body ── */
    if (oldHeader) {
      var parent = oldHeader.parentNode;
      parent.insertBefore(nav, oldHeader);
      parent.insertBefore(hero, oldHeader);
      parent.removeChild(oldHeader);
    } else {
      /* No old header — prepend nav + hero at the very top of <body> */
      document.body.insertBefore(hero, document.body.firstChild);
      document.body.insertBefore(nav, document.body.firstChild);
    }

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

  /* ─── 6b. Get student name from URL params (portal passes ?studentName=) ── */
  function _getStudentName() {
    try {
      // 1. URL param — portal appends ?studentName= when opening the note
      var fromUrl = new URLSearchParams(window.location.search).get('studentName');
      if (fromUrl && fromUrl.trim()) return fromUrl.trim();

      // 2. Fallback: portal caches session in localStorage under 'arnoma:auth:user'
      //    and the full session under 'arnoma:auth:session'
      var sessionRaw = localStorage.getItem('arnoma:auth:session');
      if (sessionRaw) {
        try {
          var session = JSON.parse(sessionRaw);
          var name = session && session.user && (session.user.user_metadata && session.user.user_metadata.full_name || session.user.email);
          if (name && name.trim()) return name.trim();
        } catch (e) {}
      }
      // 3. Try the plain email key
      var email = localStorage.getItem('arnoma:auth:user');
      if (email && email.trim()) return email.trim();

      return 'Student';
    } catch (e) { return 'Student'; }
  }

  /* ─── 6c. PRINT NOTE ────────────────────────────────────────── */
  // Opens a new window that mirrors the EXACT layout of the live note page:
  // carries over all <style> and <link> tags from the original page, outputs
  // the raw content HTML (skipping nav/hero), then overlays a diagonal
  // watermark (ARNOMA · student name · date) before triggering window.print().

  window.acnhsPrintNote = function () {
    var studentName = _getStudentName();
    var noteTitle   = (document.querySelector('.acnhs-hero-title') || document.querySelector('h1') || {}).textContent
                   || document.title || 'Class Notes';
    noteTitle = noteTitle.trim();
    var printDate = new Date().toLocaleDateString('en-US', { year:'numeric', month:'long', day:'numeric' });
    var wmText    = 'ARNOMA  \u00b7  ' + studentName + '  \u00b7  ' + printDate;

    /* ── Collect the page's own styles so the layout is identical ── */
    var styleBlocks = '';

    // Carry over every <link rel="stylesheet"> href (skip Google Fonts — optional cosmetic)
    document.querySelectorAll('link[rel="stylesheet"]').forEach(function (lk) {
      var href = lk.getAttribute('href') || '';
      // Resolve relative URLs against the current page location
      try {
        href = new URL(href, window.location.href).href;
      } catch (e) {}
      styleBlocks += '<link rel="stylesheet" href="' + href.replace(/"/g, '&quot;') + '">\n';
    });

    // Carry over every inline <style> block (skip the injected nav styles)
    document.querySelectorAll('style').forEach(function (st) {
      if (st.id === 'acnhs-nav-inject-styles') return; // skip nav-only styles
      styleBlocks += '<style>\n' + st.textContent + '\n</style>\n';
    });

    /* ── Collect content HTML — skip nav / hero / guard layers ── */
    var skipClasses = ['acnhs-site-nav', 'acnhs-doc-hero', 'page-shield', 'acnhs-print-btn'];

    function isNavOrHero(el) {
      var cls = el.className || '';
      for (var i = 0; i < skipClasses.length; i++) {
        if (cls.indexOf(skipClasses[i]) !== -1) return true;
      }
      if (el.id === 'acnhs-guard-hide') return true;
      return false;
    }

    var contentRoot = document.querySelector('.note-body')
                   || document.querySelector('.container')
                   || document.querySelector('main')
                   || document.body;

    var contentHtml = '';
    if (contentRoot === document.body) {
      // body — skip nav/hero children, collect the rest as raw innerHTML
      for (var ci = 0; ci < document.body.children.length; ci++) {
        var child = document.body.children[ci];
        if (!isNavOrHero(child)) contentHtml += child.outerHTML;
      }
    } else {
      contentHtml = contentRoot.outerHTML;
    }

    var pw = window.open('', '_blank', 'width=960,height=800');
    if (!pw) { alert('Pop-up blocked. Please allow pop-ups for this site and try again.'); return; }

    pw.document.write(
      '<!DOCTYPE html>\n<html lang="en">\n<head>\n' +
      '<meta charset="UTF-8"/>\n' +
      '<title>' + noteTitle.replace(/</g, '&lt;') + ' \u2014 Print</title>\n' +
      /* ── Carry over all original styles ── */
      styleBlocks +
      /* ── Small set of print-only overrides: hide interactive chrome ── */
      '<style>\n' +
      /* Hide anything that shouldn't appear on paper */
      '.acnhs-site-nav, .acnhs-doc-hero, .page-shield, .acnhs-print-btn,' +
        ' .back-btn, .note-back, button { display: none !important; }\n' +
      /* Watermark layer */
      '.arnoma-wm { position: fixed; top: 0; left: 0; right: 0; bottom: 0;' +
        ' pointer-events: none; z-index: 9999; overflow: hidden; }\n' +
      '.arnoma-wm-inner { display: flex; flex-wrap: wrap; align-content: flex-start;' +
        ' width: 200%; height: 200%; transform: rotate(-38deg) translate(-25%, -10%); }\n' +
      '.arnoma-wm span { display: inline-block; font-size: 10px; font-weight: 700;' +
        ' color: rgba(0,0,0,0.07); padding: 22px 12px; white-space: nowrap;' +
        ' font-family: Arial, sans-serif; letter-spacing: 0.5px; }\n' +
      /* Print header strip */
      '.arnoma-print-header { display: flex; justify-content: space-between; align-items: flex-end;' +
        ' border-bottom: 2px solid #111; padding-bottom: 10px; margin-bottom: 28px;' +
        ' font-family: Georgia, serif; }\n' +
      '.arnoma-print-header .ph-title { font-size: 19px; font-weight: 800; color: #111; }\n' +
      '.arnoma-print-header .ph-meta  { font-size: 10px; color: #555; text-align: right; line-height: 1.8; }\n' +
      /* Page setup */
      '@media print {\n' +
      '  @page { margin: 12mm 10mm; size: A4; }\n' +
      '  body { padding-top: 0 !important; }\n' +
      '  .arnoma-wm { position: fixed; }\n' +
      '  .arnoma-print-header { page-break-inside: avoid; }\n' +
      '}\n' +
      '</style>\n' +
      '</head>\n<body>\n' +
      /* Watermark layer */
      '<div class="arnoma-wm"><div class="arnoma-wm-inner" id="arnoma-wm-inner"></div></div>\n' +
      /* Header strip */
      '<div class="arnoma-print-header">' +
        '<div class="ph-title">' + noteTitle.replace(/</g, '&lt;') + '</div>' +
        '<div class="ph-meta"><strong>ARNOMA University</strong><br>' +
          studentName.replace(/</g, '&lt;') + '<br>Printed ' + printDate +
        '</div>' +
      '</div>\n' +
      /* ── Raw content — identical to what the student sees on screen ── */
      contentHtml +
      '<script>\n' +
      '(function(){\n' +
      '  var c = document.getElementById("arnoma-wm-inner");\n' +
      '  var t = ' + JSON.stringify(wmText) + ';\n' +
      '  var h = "";\n' +
      '  for (var i = 0; i < 300; i++) h += "<span>" + t + "</span>";\n' +
      '  c.innerHTML = h;\n' +
      '  setTimeout(function () {\n' +
      '    window.focus();\n' +
      '    window.print();\n' +
      '    setTimeout(function () { window.close(); }, 1800);\n' +
      '  }, 400);\n' +
      '})();\n' +
      '<\/script>\n' +
      '</body></html>'
    );
    pw.document.close();
  };

  /* ─── 7. INIT ────────────────────────────────────────────────── */
  function init() {
    ensureFonts();
    ensureStyles();
    upgradeHeader();

    /* ── Rewire ALL back-navigation links to go to the portal ──
       Covers .back-btn (new files) and .note-back (older files).
       Sets href="#" immediately so Safari never attempts file:// load,
       then navigates to the portal on click.                         */
    var portalUrl = buildPortalUrl();
    document.querySelectorAll('a.back-btn, a.note-back').forEach(function (btn) {
      btn.setAttribute('href', '#');
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        window.location.href = portalUrl;
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
