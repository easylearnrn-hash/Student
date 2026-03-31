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

      /* ════════════════════════════════════════════════════════════
         EKG DESIGN SYSTEM — Global normalization applied to ALL notes
         Overrides every existing note CSS to the unified dark theme.
         ════════════════════════════════════════════════════════════ */

      /* ── CSS tokens — EKG dark palette ── */
      ':root {',
      '  --ekg-bg:        #0d1117 !important;',
      '  --ekg-card:      #161b22 !important;',
      '  --ekg-border:    #30363d !important;',
      '  --ekg-text:      #e6edf3 !important;',
      '  --ekg-muted:     #8b949e !important;',
      '  --ekg-light:     #1c2333 !important;',
      '  --ekg-navy:      #1f6feb !important;',
      '  --ekg-red:       #f87171 !important;',
      '  --ekg-orange:    #fb923c !important;',
      '  --ekg-blue:      #60a5fa !important;',
      '  --ekg-gold:      #fbbf24 !important;',
      '  --ekg-green:     #4ade80 !important;',
      '  --ekg-purple:    #c084fc !important;',
      '  --ekg-teal:      #2dd4bf !important;',
      '}',

      /* ── Page base ── */
      'html { background: #0d1117 !important; }',
      'body {',
      '  background: #0d1117 !important;',
      '  color: #e6edf3 !important;',
      '  font-family: \'Inter\', system-ui, -apple-system, sans-serif !important;',
      '  line-height: 1.7 !important;',
      '}',

      /* ── Main containers ── */
      '.container, .page, .note-body, .content, main, article, section, .wrapper, .content-wrap {',
      '  background: transparent !important;',
      '  color: #e6edf3 !important;',
      '}',

      /* ── Any old sticky/fixed headers not replaced by nav inject ── */
      '.doc-header, .note-header-legacy, .page-header, header:not(.acnhs-doc-hero):not(.institution) {',
      '  background: #0d1117 !important;',
      '  color: #e6edf3 !important;',
      '  border-bottom: 1px solid #30363d !important;',
      '  box-shadow: none !important;',
      '}',

      /* ── Typography ── */
      'h1:not(.acnhs-hero-title) {',
      '  font-family: \'Playfair Display\', Georgia, serif !important;',
      '  color: #ffffff !important;',
      '  line-height: 1.15 !important;',
      '}',
      'h2 {',
      '  color: #60a5fa !important;',
      '  border-bottom: 1px solid #30363d !important;',
      '  padding-bottom: 8px !important;',
      '  margin-top: 36px !important;',
      '  margin-bottom: 16px !important;',
      '}',
      'h3 {',
      '  color: #fbbf24 !important;',
      '  margin-top: 24px !important;',
      '  margin-bottom: 10px !important;',
      '}',
      'h4 { color: #fb923c !important; }',
      'h5, h6 { color: #c084fc !important; }',
      'p { color: #e6edf3 !important; }',
      'a { color: #60a5fa !important; }',
      'a:hover { color: #93c5fd !important; }',
      'li { color: #e6edf3 !important; }',
      'li::marker { color: #60a5fa !important; }',
      'strong { color: #f0ece3 !important; }',
      'em { color: #c9a84c !important; }',
      'code, pre {',
      '  background: #1c2333 !important;',
      '  color: #f87171 !important;',
      '  border: 1px solid #30363d !important;',
      '  border-radius: 5px !important;',
      '}',

      /* ── Section headings (old .section-title pattern) ── */
      '.section-title, .section-heading {',
      '  color: #8b949e !important;',
      '  border-bottom: 1px solid #30363d !important;',
      '  letter-spacing: 0.12em !important;',
      '  font-size: 0.7rem !important;',
      '  font-weight: 700 !important;',
      '  text-transform: uppercase !important;',
      '  padding-bottom: 8px !important;',
      '  margin: 32px 0 14px !important;',
      '}',
      '.section-title::after {',
      '  background: #30363d !important;',
      '}',

      /* ── Cards (ALL variants) ── */
      '.card, .ref-card, .tip-box, .info-box, .box, .panel, .overview, .summary-card, .note-card {',
      '  background: #161b22 !important;',
      '  border: 1px solid #30363d !important;',
      '  border-radius: 10px !important;',
      '  color: #e6edf3 !important;',
      '}',
      /* Colour-accented cards — keep left accent only */
      '.card.teal, .card.teal  { border-color: rgba(45,212,191,0.35) !important; }',
      '.card.gold, .card.gold  { border-color: rgba(251,191,36,0.35) !important; }',
      '.card.red,  .card.red   { border-color: rgba(248,113,113,0.35) !important; }',
      '.card.green,.card.green { border-color: rgba(74,222,128,0.35) !important; }',
      '.card.blue, .card.blue  { border-color: rgba(96,165,250,0.35) !important; }',
      '.card.purple            { border-color: rgba(192,132,252,0.35) !important; }',
      '.card.orange            { border-color: rgba(251,146,60,0.35) !important; }',
      '.card h3 { color: #e6edf3 !important; }',
      '.card.teal h3, .card.teal h4   { color: #2dd4bf !important; }',
      '.card.gold h3, .card.gold h4   { color: #fbbf24 !important; }',
      '.card.red h3,  .card.red h4    { color: #f87171 !important; }',
      '.card.green h3,.card.green h4  { color: #4ade80 !important; }',
      '.card.blue h3, .card.blue h4   { color: #60a5fa !important; }',
      '.card.purple h3,.card.purple h4{ color: #c084fc !important; }',

      /* ── Alerts ── */
      '.alert, .notice, .warning, .danger, .tip, .callout {',
      '  background: #161b22 !important;',
      '  border-left: 4px solid #30363d !important;',
      '  color: #e6edf3 !important;',
      '  border-radius: 8px !important;',
      '}',
      '.alert.yellow, .tip   { border-color: #fbbf24 !important; }',
      '.alert.red,  .danger  { border-color: #f87171 !important; }',
      '.alert.teal, .notice  { border-color: #2dd4bf !important; }',
      '.alert.green          { border-color: #4ade80 !important; }',
      '.alert.blue           { border-color: #60a5fa !important; }',
      '.alert .tip strong, .alert strong { color: #f0ece3 !important; }',
      '.alert p, .tip p       { color: #e6edf3 !important; }',
      '.alert-title, .tip strong:first-child { color: #fbbf24 !important; }',

      /* ── Tables ── */
      'table, .mini-table, .formula-table, .drug-table, .comparison-table {',
      '  background: #161b22 !important;',
      '  border: 1px solid #30363d !important;',
      '  border-radius: 10px !important;',
      '  overflow: hidden;',
      '  width: 100%;',
      '  border-collapse: collapse;',
      '}',
      'thead, thead tr { background: #1f6feb !important; }',
      'th {',
      '  background: #1f6feb !important;',
      '  color: #ffffff !important;',
      '  font-size: 0.72rem !important;',
      '  font-weight: 600 !important;',
      '  letter-spacing: 0.08em !important;',
      '  text-transform: uppercase !important;',
      '  padding: 12px 16px !important;',
      '  text-align: left !important;',
      '  border: none !important;',
      '}',
      'td {',
      '  padding: 10px 16px !important;',
      '  border-bottom: 1px solid #30363d !important;',
      '  color: #e6edf3 !important;',
      '  vertical-align: top !important;',
      '  font-size: 0.875rem !important;',
      '}',
      'tbody tr:last-child td { border-bottom: none !important; }',
      'tbody tr:nth-child(even) td { background: #1c2333 !important; }',
      'tbody tr:hover td { background: rgba(255,255,255,0.03) !important; }',

      /* ── Badges / pills ── */
      '.badge, .pill, .label, .tag, .note-tag, .chip {',
      '  background: #1c2333 !important;',
      '  color: #8b949e !important;',
      '  border: 1px solid #30363d !important;',
      '  border-radius: 100px !important;',
      '  font-size: 0.72rem !important;',
      '  font-weight: 700 !important;',
      '  padding: 3px 10px !important;',
      '  display: inline-block !important;',
      '}',
      '.badge-red,.badge.red,.pill-red         { color: #f87171 !important; background: rgba(248,113,113,0.12) !important; border-color: rgba(248,113,113,0.35) !important; }',
      '.badge-orange,.badge.orange,.pill-orange{ color: #fb923c !important; background: rgba(251,146,60,0.12) !important;  border-color: rgba(251,146,60,0.35) !important; }',
      '.badge-blue,.badge.blue,.pill-blue      { color: #60a5fa !important; background: rgba(96,165,250,0.12) !important;  border-color: rgba(96,165,250,0.35) !important; }',
      '.badge-gold,.badge.gold,.badge-yellow,.pill-gold { color: #fbbf24 !important; background: rgba(251,191,36,0.12) !important; border-color: rgba(251,191,36,0.35) !important; }',
      '.badge-green,.badge.green,.pill-green   { color: #4ade80 !important; background: rgba(74,222,128,0.12) !important;  border-color: rgba(74,222,128,0.35) !important; }',
      '.badge-purple,.badge.purple             { color: #c084fc !important; background: rgba(192,132,252,0.12) !important; border-color: rgba(192,132,252,0.35) !important; }',
      '.badge-teal,.badge.teal                 { color: #2dd4bf !important; background: rgba(45,212,191,0.12) !important;  border-color: rgba(45,212,191,0.35) !important; }',
      /* old note-tag (teal) */
      '.note-tag { color: #2dd4bf !important; background: rgba(45,212,191,0.1) !important; border-color: rgba(45,212,191,0.3) !important; }',

      /* ── Lists ── */
      'ul li::marker, ol li::marker { color: #60a5fa !important; }',

      /* ── Overview / summary gradients → flatten to dark card ── */
      '.overview, .summary, .intro-box, .highlight-box {',
      '  background: #161b22 !important;',
      '  border: 1px solid #30363d !important;',
      '  color: #e6edf3 !important;',
      '}',
      '.overview p, .summary p, .intro-box p { color: #e6edf3 !important; }',
      '.overview strong { color: #f0ece3 !important; }',

      /* ── Canvas cards (ECG grids etc.) ── */
      '.canvas-card { background: #161b22 !important; border: 1px solid #30363d !important; border-radius: 12px !important; }',
      '.canvas-caption { color: #8b949e !important; }',

      /* ── Footer ── */
      '.page-footer, footer { border-top: 1px solid #30363d !important; color: #8b949e !important; }',
      '.page-footer span, footer span { color: #8b949e !important; }',

      /* ── Institution header (EKG note style) keep as-is ── */
      '.institution {',
      '  border-bottom: 2px solid #30363d !important;',
      '  color: #e6edf3 !important;',
      '}',
      '.inst-logo { background: #1f6feb !important; }',
      '.inst-name { color: #e6edf3 !important; }',
      '.inst-dept, .doc-code { color: #8b949e !important; }',

      /* ── Scrollbar ── */
      '::-webkit-scrollbar { width: 8px !important; }',
      '::-webkit-scrollbar-track { background: #0d1117 !important; }',
      '::-webkit-scrollbar-thumb { background: #30363d !important; border-radius: 4px !important; }',
      '::-webkit-scrollbar-thumb:hover { background: #8b949e !important; }',

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
  // Opens a new window with white paper / black ink version of this note,
  // overlaid with a dense diagonal watermark: ARNOMA · student name · date.
  window.acnhsPrintNote = function () {
    var studentName = _getStudentName();
    var noteTitle   = document.querySelector('.acnhs-hero-title')?.textContent
                   || document.querySelector('h1')?.textContent
                   || document.title
                   || 'Class Notes';
    var printDate   = new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
    var wmText      = 'ARNOMA  \u00b7  ' + studentName + '  \u00b7  ' + printDate;

    // Clone the page body content (everything below the nav)
    var bodyClone = document.body.cloneNode(true);
    // Remove injected nav and hero from the clone so only note content prints
    var cloneNav  = bodyClone.querySelector('.acnhs-site-nav');
    var cloneHero = bodyClone.querySelector('.acnhs-doc-hero');
    if (cloneNav)  cloneNav.remove();
    if (cloneHero) cloneHero.remove();
    // Remove any protection overlays / scripts
    bodyClone.querySelectorAll('script, noscript, #acnhs-guard-hide, .page-shield').forEach(function(el){ el.remove(); });
    var bodyHtml = bodyClone.innerHTML;

    // Collect all <style> and <link rel="stylesheet"> from the current page
    var styleHtml = '';
    document.querySelectorAll('style:not(#acnhs-nav-inject-styles)').forEach(function(s){
      styleHtml += '<style>' + s.textContent + '</style>';
    });

    var pw = window.open('', '_blank', 'width=960,height=800');
    if (!pw) { alert('Pop-up blocked. Please allow pop-ups for this site and try again.'); return; }

    // Build watermark tile HTML (JS fills it after load)
    pw.document.write('<!DOCTYPE html>\n<html lang="en">\n<head>\n' +
      '<meta charset="UTF-8"/>\n' +
      '<title>' + noteTitle.replace(/</g,'&lt;') + ' \u2014 Print</title>\n' +
      styleHtml +
      '<style>\n' +
      /* ── Nuclear white-paper override: blast every dark bg/color ── */
      ':root{--bg:#fff!important;--surface:#fff!important;--surface2:#fff!important;' +
        '--bg-deep:#fff!important;--bg-card:#fff!important;--bg-alt:#fff!important;' +
        '--border:#d0d0d0!important;--gold:#8a6a1a!important;--gold-light:#7a5c10!important;' +
        '--text:#111!important;--text-muted:#444!important;--text-dim:#666!important;' +
        '--red:#b91c1c!important;--green:#166534!important;--blue:#1d4ed8!important;' +
        '--purple:#7e22ce!important;--orange:#c2410c!important;--yellow:#92400e!important;--radius:8px!important;}\n' +
      /* Force white bg on everything — this is the nuclear rule */
      '*{background-color:#fff!important;color:#111!important;' +
        'border-color:#ccc!important;box-shadow:none!important;' +
        'text-shadow:none!important;-webkit-print-color-adjust:exact;}\n' +
      /* Re-allow transparent so layout isn't broken, then selectively re-color */
      '*[style*="background"]{background-color:#fff!important;}\n' +
      'html,body{background:#fff!important;color:#111!important;margin:0;padding:24px 40px 80px;max-width:860px;margin:0 auto;}\n' +
      'h1{color:#111!important;}\n' +
      'h2{color:#7a5c10!important;border-color:#ccc!important;}\n' +
      'h3{color:#1d4ed8!important;}\n' +
      'h4,h5,h6,p,li,td,th,span,div{color:#111!important;}\n' +
      /* Cards — white bg, light border */
      '.card,.card *{background:#fff!important;border-color:#bbb!important;}\n' +
      '.card.gold,.card.gold *{background:#fff!important;border-color:rgba(138,106,26,0.4)!important;}\n' +
      '.card.red,.card.red *{background:#fff!important;border-color:rgba(185,28,28,0.35)!important;}\n' +
      '.card.blue,.card.blue *{background:#fff!important;border-color:rgba(29,78,216,0.35)!important;}\n' +
      '.card.green,.card.green *{background:#fff!important;border-color:rgba(22,101,52,0.35)!important;}\n' +
      '.card.purple,.card.purple *{background:#fff!important;border-color:rgba(126,34,206,0.35)!important;}\n' +
      /* Restore colored text inside colored cards */
      '.card.gold h2,.card.gold h3{color:#7a5c10!important;}\n' +
      '.card.red h2,.card.red h3{color:#b91c1c!important;}\n' +
      '.card.blue h2,.card.blue h3{color:#1d4ed8!important;}\n' +
      '.card.green h2,.card.green h3{color:#166534!important;}\n' +
      '.card.purple h2,.card.purple h3{color:#7e22ce!important;}\n' +
      /* Badges */
      '.badge-red{color:#b91c1c!important;background:#fff!important;border-color:rgba(185,28,28,0.4)!important;}\n' +
      '.badge-blue{color:#1d4ed8!important;background:#fff!important;border-color:rgba(29,78,216,0.4)!important;}\n' +
      '.badge-gold{color:#8a6a1a!important;background:#fff!important;border-color:rgba(138,106,26,0.4)!important;}\n' +
      '.badge-green{color:#166534!important;background:#fff!important;border-color:rgba(22,101,52,0.4)!important;}\n' +
      '.badge-purple{color:#7e22ce!important;background:#fff!important;border-color:rgba(126,34,206,0.4)!important;}\n' +
      '.badge-orange{color:#c2410c!important;background:#fff!important;border-color:rgba(194,65,12,0.4)!important;}\n' +
      /* Tables */
      '.mini-table,.mini-table *{background:#fff!important;border-color:#ccc!important;color:#111!important;}\n' +
      '.mini-table th{background:#f0f0f0!important;color:#111!important;}\n' +
      '.mini-table tr:nth-child(even) td{background:#f8f8f8!important;}\n' +
      /* Alerts, tags */
      '.alert,.alert *{background:#f8f8f8!important;border-color:#bbb!important;color:#111!important;}\n' +
      '.alert-title{color:#111!important;font-weight:700;}\n' +
      '.note-tag{color:#8a6a1a!important;background:#fff!important;border-color:rgba(138,106,26,0.35)!important;}\n' +
      /* Images keep their look; canvases keep backgrounds for ECG grids etc. */
      'img{background:transparent!important;}\n' +
      'canvas{background:#fff!important;}\n' +
      /* ── Print header ── */
      '.arnoma-print-header{display:flex;justify-content:space-between;align-items:flex-end;' +
        'border-bottom:2px solid #111;padding-bottom:10px;margin-bottom:28px;page-break-inside:avoid;}\n' +
      '.arnoma-print-header .ph-title{font-size:18px;font-weight:800;color:#111;font-family:\'Playfair Display\',Georgia,serif;}\n' +
      '.arnoma-print-header .ph-meta{font-size:10px;color:#555;text-align:right;line-height:1.7;}\n' +
      /* ── Watermark ── */
      '.arnoma-wm{position:fixed;top:0;left:0;right:0;bottom:0;' +
        'display:flex;flex-wrap:wrap;align-content:flex-start;' +
        'gap:0;overflow:hidden;pointer-events:none;z-index:9999;}\n' +
      '.arnoma-wm span{display:inline-block;font-size:10.5px;font-weight:700;' +
        'color:rgba(0,0,0,0.08);transform:rotate(-38deg);padding:26px 14px;' +
        'white-space:nowrap;font-family:Inter,Arial,sans-serif;letter-spacing:0.4px;}\n' +
      /* ── Page setup ── */
      '@media print{@page{margin:14mm 12mm;} body{padding:0!important;} .arnoma-wm{position:fixed;}}\n' +
      '</style>\n' +
      '</head>\n<body>\n' +
      '<div class="arnoma-wm" id="arnoma-wm-tiles"></div>\n' +
      '<div class="arnoma-print-header">' +
        '<div class="ph-title">' + noteTitle.replace(/</g,'&lt;') + '</div>' +
        '<div class="ph-meta"><strong>ARNOMA University</strong><br>' + studentName.replace(/</g,'&lt;') + '<br>Printed ' + printDate + '</div>' +
      '</div>\n' +
      bodyHtml +
      '<script>\n' +
      '(function(){\n' +
      '  var c=document.getElementById("arnoma-wm-tiles");\n' +
      '  var t=' + JSON.stringify(wmText) + ';\n' +
      '  var h="";\n' +
      '  for(var i=0;i<200;i++) h+="<span>"+t+"</span>";\n' +
      '  c.innerHTML=h;\n' +
      '  setTimeout(function(){window.focus();window.print();setTimeout(function(){window.close();},1500);},350);\n' +
      '})();\n' +
      '<\/script>\n' +
      '</body></html>');
    pw.document.close();
  };

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
