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
  // Opens a print window that mirrors the exact page HTML layout.
  // Carries ALL original <style> and <link rel=stylesheet> tags verbatim,
  // then overlays a @media print override that converts the dark theme to
  // a clean, elite, white-paper university document — preserving all
  // card/table/badge/grid layout exactly as it appears on screen.
  // Topped with a premium print cover header (logo, institution, title,
  // student, date) and a diagonal ARNOMA watermark.

  window.acnhsPrintNote = function () {
    var studentName = _getStudentName();
    var noteTitle   = (document.querySelector('.acnhs-hero-title') || document.querySelector('h1') || {}).textContent
                   || document.title || 'Class Notes';
    noteTitle = noteTitle.trim();
    var category    = (document.querySelector('.acnhs-hero-eyebrow') || {}).textContent || 'Clinical Notes';
    category = category.trim();
    var printDate   = new Date().toLocaleDateString('en-US', { year:'numeric', month:'long', day:'numeric' });
    var wmText      = 'ARNOMA \u00b7 ' + studentName + ' \u00b7 ' + printDate;

    /* ── 1. Collect original <style> blocks — skip guard + nav-inject styles ── */
    var styleBlocks = '';
    var SKIP_STYLE_IDS = ['acnhs-guard-hide', 'acnhs-nav-inject-styles'];
    document.querySelectorAll('style').forEach(function(s) {
      if (SKIP_STYLE_IDS.indexOf(s.id) !== -1) return;
      /* Also skip any style whose text contains the guard rule */
      if (s.textContent.indexOf('display:none!important') !== -1 &&
          s.textContent.indexOf('body') !== -1 &&
          s.textContent.length < 80) return;
      styleBlocks += '<style>' + s.textContent + '</style>\n';
    });

    /* ── 2. Google Fonts only — skip external/relative links (may be cross-origin) ── */
    var linkBlocks = '<link rel="preconnect" href="https://fonts.googleapis.com">\n' +
      '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,600;0,700;0,800;1,700&family=Inter:wght@300;400;500;600;700;800&display=swap">\n';

    /* ── 3. Collect the inner content HTML (skip nav/hero/guard layers) ── */
    var contentHtml = '';
    /* Priority: .note-body > .container > main > all body children */
    var contentRoot = document.querySelector('.note-body')
                   || document.querySelector('.container')
                   || document.querySelector('main');

    if (contentRoot) {
      contentHtml = contentRoot.outerHTML;
    } else {
      /* Walk body children, skip injected chrome */
      var skipPfx = ['acnhs-site-nav','acnhs-doc-hero','page-shield'];
      var skipIds  = ['acnhs-guard-hide'];
      for (var ci = 0; ci < document.body.childNodes.length; ci++) {
        var ch = document.body.childNodes[ci];
        if (ch.nodeType !== 1) continue;
        var chCls = ch.className || '';
        var chId  = ch.id || '';
        var skip  = false;
        for (var si = 0; si < skipPfx.length; si++) { if (chCls.indexOf(skipPfx[si]) !== -1) { skip = true; break; } }
        for (var si2 = 0; si2 < skipIds.length; si2++) { if (chId === skipIds[si2]) { skip = true; break; } }
        if (!skip) contentHtml += ch.outerHTML;
      }
    }

    /* ── 4. Resolve logo URL for the print header ── */
    var logoUrl = buildLogoUrl();

    /* ── 5. Build the print window ── */
    var pw = window.open('', '_blank', 'width=1020,height=900,scrollbars=yes');
    if (!pw) { alert('Pop-up blocked. Please allow pop-ups for this site and try again.'); return; }

    /* CSS custom-property overrides: remap dark vars to light-paper equivalents */
    var printOverride = [
      /* ── CRITICAL: force body visible — overrides the note-guard display:none ── */
      'body { display: block !important; visibility: visible !important; opacity: 1 !important; }',

      /* ── @page setup ── */
      '@page { margin: 16mm 14mm; size: A4; }',

      /* ── Root variable light-mode remap ── */
      ':root {',
      '  --bg: #ffffff !important;',
      '  --surface: #f8f6f2 !important;',
      '  --card: #ffffff !important;',
      '  --border: #d4c9b0 !important;',
      '  --gold: #8a6318 !important;',
      '  --gold-dim: #c9a84c !important;',
      '  --teal: #0f6b72 !important;',
      '  --teal-dark: #084f55 !important;',
      '  --text: #1a1612 !important;',
      '  --muted: #4a4540 !important;',
      '  --red: #8b1c1c !important;',
      '  --green: #1a5c30 !important;',
      '  --yellow: #7a5c10 !important;',
      '  --blue: #1a3a7a !important;',
      '}',

      /* ── Base document ── */
      'html, body {',
      '  background: #fff !important;',
      '  color: #1a1612 !important;',
      '  font-family: "Inter", "Segoe UI", system-ui, sans-serif !important;',
      '  font-size: 11.5px !important;',
      '  line-height: 1.72 !important;',
      '  padding: 0 !important;',
      '  margin: 0 !important;',
      '  max-width: none !important;',
      '}',

      /* ── Hide injected chrome entirely ── */
      '.acnhs-site-nav, .acnhs-doc-hero, .acnhs-print-btn,',
      '.note-back, .back-btn, .note-header,',
      '#acnhs-guard-hide, .page-shield { display: none !important; }',

      /* ── Layout containers ── */
      '.container, .note-body {',
      '  max-width: 100% !important;',
      '  padding: 0 !important;',
      '  margin: 0 !important;',
      '}',

      /* ── Section titles ── */
      '.section-title {',
      '  color: #8a6318 !important;',
      '  font-size: 9.5px !important;',
      '  font-weight: 800 !important;',
      '  letter-spacing: .14em !important;',
      '  text-transform: uppercase !important;',
      '  margin: 20px 0 9px !important;',
      '  padding-bottom: 5px !important;',
      '  border-bottom: 1.5px solid #d4c9b0 !important;',
      '  display: flex !important;',
      '  align-items: center !important;',
      '  gap: 8px !important;',
      '}',
      '.section-title::after { background: #d4c9b0 !important; }',

      /* ── Cards ── */
      '.card {',
      '  background: #fafaf8 !important;',
      '  border: 1.5px solid #d4c9b0 !important;',
      '  border-radius: 8px !important;',
      '  padding: 13px 16px !important;',
      '  margin-bottom: 11px !important;',
      '  break-inside: avoid !important;',
      '}',
      '.card h3 { color: #1a1612 !important; font-size: 12.5px !important; margin-bottom: 8px !important; }',
      '.card.gold { border-color: #c9a84c !important; background: #fffdf4 !important; }',
      '.card.gold h3 { color: #7a5010 !important; }',
      '.card.red  { border-color: #c0392b !important; background: #fff8f8 !important; }',
      '.card.red  h3 { color: #8b1c1c !important; }',
      '.card.green{ border-color: #2e8b57 !important; background: #f5fbf7 !important; }',
      '.card.green h3 { color: #1a5c30 !important; }',
      '.card.blue { border-color: #3a60c0 !important; background: #f5f7fc !important; }',
      '.card.blue h3 { color: #1a3a7a !important; }',
      '.card.teal { border-color: #2a9d8f !important; background: #f3fbfa !important; }',
      '.card.teal h3 { color: #0f6b72 !important; }',
      '.card.purple { border-color: #7c3aed !important; background: #faf5ff !important; }',
      '.card.purple h3 { color: #5b21b6 !important; }',

      /* ── Alerts ── */
      '.alert {',
      '  border-radius: 7px !important;',
      '  padding: 11px 15px !important;',
      '  margin-bottom: 11px !important;',
      '  font-size: 11px !important;',
      '  break-inside: avoid !important;',
      '}',
      '.alert.yellow { background: #fffbf0 !important; border: 1.5px solid #e6b800 !important; color: #5c4000 !important; }',
      '.alert.red    { background: #fff5f5 !important; border: 1.5px solid #e05c5c !important; color: #7a1a1a !important; }',
      '.alert.teal   { background: #f0fafb !important; border: 1.5px solid #2a9d8f !important; color: #0a4f55 !important; }',
      '.alert.green  { background: #f3fbf5 !important; border: 1.5px solid #2e8b57 !important; color: #155226 !important; }',
      '.alert.blue   { background: #f5f7fc !important; border: 1.5px solid #3a60c0 !important; color: #1a3060 !important; }',
      '.alert strong, .alert b { color: inherit !important; }',

      /* ── Tables ── */
      /* Apply to both .mini-table and any plain <table> in note content */
      'table, .mini-table {',
      '  width: 100% !important;',
      '  border-collapse: collapse !important;',
      '  margin: 11px 0 !important;',
      '  font-size: 10.5px !important;',
      '  /* Do NOT set break-inside:avoid on the whole table — large tables must split */',
      '}',
      /* Each row must never split in the middle — keep entire <tr> on one page */
      'tr, .mini-table tr {',
      '  break-inside: avoid !important;',
      '  page-break-inside: avoid !important;',
      '}',
      /* thead repeats on every page so column headers always appear */
      'thead, .mini-table thead {',
      '  display: table-header-group !important;',
      '}',
      'tbody, .mini-table tbody {',
      '  display: table-row-group !important;',
      '}',
      'table th, .mini-table th {',
      '  background: #f4f0e8 !important;',
      '  color: #2a1a00 !important;',
      '  font-weight: 700 !important;',
      '  padding: 7px 11px !important;',
      '  border: 1px solid #ccc0a0 !important;',
      '  text-align: left !important;',
      '}',
      'table td, .mini-table td {',
      '  padding: 6px 11px !important;',
      '  border: 1px solid #d8d0bc !important;',
      '  color: #1a1612 !important;',
      '  vertical-align: top !important;',
      '  background: #ffffff !important;',
      '}',
      'table tr:nth-child(even) td, .mini-table tr:nth-child(even) td { background: #faf8f3 !important; }',

      /* ── Badges ── */
      '.badge {',
      '  border-radius: 5px !important;',
      '  font-size: 9.5px !important;',
      '  font-weight: 700 !important;',
      '  padding: 2px 7px !important;',
      '  margin-right: 4px !important;',
      '  background: #f0ece4 !important;',
      '  color: #2a1a00 !important;',
      '  border: 1px solid #ccc0a0 !important;',
      '}',
      '.badge.gold   { background: #fdf7e4 !important; color: #6a4a00 !important; border-color: #c9a84c !important; }',
      '.badge.teal   { background: #e8f9f7 !important; color: #0a5560 !important; border-color: #2a9d8f !important; }',
      '.badge.red    { background: #fdf0f0 !important; color: #7a1a1a !important; border-color: #e05c5c !important; }',
      '.badge.blue   { background: #eef1fc !important; color: #1a3060 !important; border-color: #3a60c0 !important; }',
      '.badge.green  { background: #edf8f1 !important; color: #155226 !important; border-color: #2e8b57 !important; }',
      '.badge.purple { background: #f5eeff !important; color: #4c1d95 !important; border-color: #7c3aed !important; }',

      /* ── Note tag pill ── */
      '.note-tag {',
      '  background: #fdf4e0 !important; color: #7a5010 !important;',
      '  border: 1px solid #c9a84c !important;',
      '  border-radius: 20px !important;',
      '  font-size: 9px !important; font-weight: 700 !important;',
      '  padding: 2px 10px !important;',
      '}',

      /* ── Compare / content grids ── */
      '.compare-grid {',
      '  display: grid !important;',
      '  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)) !important;',
      '  gap: 11px !important;',
      '  margin: 11px 0 !important;',
      '}',

      /* ── Insulin rows (Endocrine notes) ── */
      '.insulin-row {',
      '  border-radius: 8px !important;',
      '  padding: 11px 14px !important;',
      '  margin-bottom: 9px !important;',
      '  background: #fafaf8 !important;',
      '  border: 1.5px solid #d4c9b0 !important;',
      '  break-inside: avoid !important;',
      '}',
      '.insulin-row .i-name { color: #2a1a00 !important; font-weight: 800 !important; font-size: 12px !important; margin-bottom: 5px !important; }',

      /* ── General typography ── */
      'h1 { font-size: 18px !important; color: #1a1612 !important; font-weight: 800 !important; margin: 16px 0 7px !important; }',
      'h2 { font-size: 15px !important; color: #2a1a00 !important; font-weight: 700 !important; margin: 14px 0 6px !important; }',
      'h3 { font-size: 12.5px !important; color: #1a1612 !important; font-weight: 700 !important; margin: 11px 0 5px !important; }',
      'h4, h5, h6 { font-size: 11px !important; color: #1a1612 !important; font-weight: 700 !important; margin: 9px 0 4px !important; }',
      'p { color: #1a1612 !important; margin: 5px 0 !important; }',
      'ul, ol { padding-left: 18px !important; margin: 5px 0 5px 0 !important; }',
      'li { margin-bottom: 3px !important; color: #1a1612 !important; font-size: 11px !important; }',
      'li::marker { color: #8a6318 !important; }',
      'strong, b { color: inherit !important; font-weight: 700 !important; }',
      'em, i { font-style: italic !important; }',
      '[style*="color:var(--teal)"] { color: #0f6b72 !important; }',
      '[style*="color:var(--gold)"] { color: #7a5010 !important; }',
      '[style*="color:var(--red)"]  { color: #8b1c1c !important; }',
      '[style*="color:var(--green)"]{ color: #1a5c30 !important; }',
      '[style*="color:var(--blue)"] { color: #1a3a7a !important; }',
      '[style*="color:var(--yellow)"]{ color: #7a5c10 !important; }',

      /* ── Watermark layer — SVG tiled pattern, perfectly symmetrical on every page ── */
      '.arnoma-wm {',
      '  position: fixed; top:0; left:0; width:100%; height:100%;',
      '  pointer-events: none; z-index: 9999; overflow: hidden;',
      '}',
      '.arnoma-wm svg {',
      '  width: 100%; height: 100%;',
      '}',

      /* ── Premium print cover header ── */
      '.arnoma-cover {',
      '  display: flex;',
      '  align-items: stretch;',
      '  border-bottom: 2.5px solid #1a1612;',
      '  padding-bottom: 16px;',
      '  margin-bottom: 30px;',
      '  gap: 20px;',
      '  page-break-inside: avoid;',
      '}',
      '.arnoma-cover-left {',
      '  display: flex;',
      '  align-items: center;',
      '  gap: 14px;',
      '  flex: 1;',
      '}',
      '.arnoma-cover-seal {',
      '  width: 54px; height: 54px;',
      '  border-radius: 50%;',
      '  border: 1.5px solid #c9a84c;',
      '  object-fit: contain;',
      '  flex-shrink: 0;',
      '}',
      '.arnoma-cover-inst {',
      '  line-height: 1.3;',
      '}',
      '.arnoma-cover-inst .ci-name {',
      '  font-family: "Playfair Display", Georgia, "Times New Roman", serif;',
      '  font-size: 13px;',
      '  font-weight: 700;',
      '  color: #1a1612;',
      '  display: block;',
      '}',
      '.arnoma-cover-inst .ci-sub {',
      '  font-size: 8.5px;',
      '  font-weight: 700;',
      '  letter-spacing: .1em;',
      '  text-transform: uppercase;',
      '  color: #8a7050;',
      '  display: block;',
      '  margin-top: 2px;',
      '}',
      '.arnoma-cover-rule {',
      '  width: 1px;',
      '  background: #c9a84c;',
      '  margin: 4px 0;',
      '  flex-shrink: 0;',
      '}',
      '.arnoma-cover-doc {',
      '  flex: 2;',
      '  display: flex;',
      '  flex-direction: column;',
      '  justify-content: center;',
      '}',
      '.arnoma-cover-doc .cd-category {',
      '  font-size: 8.5px;',
      '  font-weight: 800;',
      '  letter-spacing: .14em;',
      '  text-transform: uppercase;',
      '  color: #8a6318;',
      '  margin-bottom: 4px;',
      '  display: flex;',
      '  align-items: center;',
      '  gap: 7px;',
      '}',
      '.arnoma-cover-doc .cd-category::before {',
      '  content: "";',
      '  display: inline-block;',
      '  width: 5px; height: 5px;',
      '  background: #c9a84c;',
      '  border-radius: 50%;',
      '}',
      '.arnoma-cover-doc .cd-title {',
      '  font-family: "Playfair Display", Georgia, "Times New Roman", serif;',
      '  font-size: 20px;',
      '  font-weight: 800;',
      '  color: #1a1612;',
      '  line-height: 1.2;',
      '  margin-bottom: 6px;',
      '}',
      '.arnoma-cover-doc .cd-meta {',
      '  font-size: 9px;',
      '  color: #6a5a40;',
      '  letter-spacing: .04em;',
      '  display: flex;',
      '  gap: 14px;',
      '  flex-wrap: wrap;',
      '}',
      '.arnoma-cover-doc .cd-meta span::before {',
      '  content: "· ";',
      '  color: #c9a84c;',
      '}',
      '.arnoma-cover-doc .cd-meta span:first-child::before {',
      '  content: "";',
      '}',

      /* ── Footer: page number ── */
      '@media print {',
      '  .arnoma-wm { position: fixed !important; }',
      '  .arnoma-cover { page-break-inside: avoid !important; }',
      '  body::after {',
      '    content: "ARNOMA · Armenian College of Nursing & Health Sciences · Confidential Study Material";',
      '    display: block;',
      '    text-align: center;',
      '    font-size: 8px;',
      '    color: #999;',
      '    border-top: 1px solid #e0d8cc;',
      '    padding-top: 8px;',
      '    margin-top: 30px;',
      '    letter-spacing: .05em;',
      '  }',
      '}'
    ].join('\n');

    /* ── 6. Assemble the print document ── */
    var safeTitle  = noteTitle.replace(/</g, '&lt;').replace(/>/g, '&gt;');
    var safeStudent = studentName.replace(/</g, '&lt;').replace(/>/g, '&gt;');
    var safeCat    = category.replace(/</g, '&lt;').replace(/>/g, '&gt;');

    pw.document.write(
      '<!DOCTYPE html>\n<html lang="en">\n<head>\n' +
      '<meta charset="UTF-8"/>\n' +
      '<meta name="viewport" content="width=device-width, initial-scale=1.0"/>\n' +
      '<title>' + safeTitle + ' \u2014 Print</title>\n' +
      linkBlocks +
      styleBlocks +
      '<style id="arnoma-print-override">\n' + printOverride + '\n</style>\n' +
      '</head>\n<body>\n' +

      /* ── Watermark layer ── */
      '<div class="arnoma-wm"><svg id="arnoma-wm-svg" xmlns="http://www.w3.org/2000/svg"><defs>' +
      '<pattern id="wm-pat" x="0" y="0" width="220" height="60" patternUnits="userSpaceOnUse" ' +
      'patternTransform="rotate(-35)">' +
      '<text id="wm-t" x="0" y="40" font-family="Inter, Arial, sans-serif" font-size="9.5" ' +
      'font-weight="700" fill="rgba(0,0,0,0.09)" letter-spacing="0.8"></text>' +
      '</pattern></defs>' +
      '<rect width="100%" height="100%" fill="url(#wm-pat)"/></svg></div>\n' +

      /* ── Premium cover header ── */
      '<div class="arnoma-cover">' +
        '<div class="arnoma-cover-left">' +
          (logoUrl ? '<img class="arnoma-cover-seal" src="' + logoUrl + '" alt="ACNHS Seal" onerror="this.style.display=\'none\'">' : '') +
          '<div class="arnoma-cover-inst">' +
            '<span class="ci-name">Armenian College of Nursing</span>' +
            '<span class="ci-sub">&amp; Health Sciences &nbsp;·&nbsp; ARNOMA</span>' +
          '</div>' +
        '</div>' +
        '<div class="arnoma-cover-rule"></div>' +
        '<div class="arnoma-cover-doc">' +
          '<div class="cd-category">' + safeCat + '</div>' +
          '<div class="cd-title">' + safeTitle + '</div>' +
          '<div class="cd-meta">' +
            '<span>' + safeStudent + '</span>' +
            '<span>Study Guide</span>' +
            '<span>' + printDate + '</span>' +
            '<span>ACNHS &copy; 2026</span>' +
          '</div>' +
        '</div>' +
      '</div>\n' +

      /* ── Actual note content (verbatim DOM, all original classes preserved) ── */
      contentHtml +

      /* ── Scripts: populate watermark, then auto-print ── */
      '<script>\n' +
      '(function(){\n' +
      '  /* Set SVG watermark text */\n' +
      '  var wmEl = document.getElementById("wm-t");\n' +
      '  if (wmEl) wmEl.textContent = ' + JSON.stringify(wmText) + ';\n' +
      '  /* Hide any remaining injected chrome in the cloned content */\n' +
      '  var selectors = [".acnhs-site-nav",".acnhs-doc-hero",".acnhs-print-btn",\n' +
      '    ".note-back",".back-btn","#acnhs-guard-hide",".page-shield"];\n' +
      '  selectors.forEach(function(sel){\n' +
      '    document.querySelectorAll(sel).forEach(function(el){ el.style.display="none"; });\n' +
      '  });\n' +
      '  setTimeout(function() {\n' +
      '    window.focus();\n' +
      '    window.print();\n' +
      '    setTimeout(function() { window.close(); }, 2200);\n' +
      '  }, 650);\n' +
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
