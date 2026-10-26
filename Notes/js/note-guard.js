/**
 * note-guard.js
 * Removes the body-hide guard style so the note page becomes visible.
 * This must be the last script in <body> so the DOM is ready.
 *
 * Also installs a safety-net: if ANY script error or load failure
 * prevents this from running normally, the body is force-shown after
 * 2500ms so students never see a permanent black screen.
 */
(function () {
  function removeGuard() {
    var guard = document.getElementById('acnhs-guard-hide');
    if (guard) guard.parentNode.removeChild(guard);
    /* Belt-and-suspenders: force body visible regardless */
    document.body.style.setProperty('display', 'block', 'important');
    document.body.style.setProperty('visibility', 'visible', 'important');
    document.body.style.setProperty('opacity', '1', 'important');
  }

  /* Run immediately (normal path — script loaded at end of <body>) */
  removeGuard();

  /* Safety-net: also fire after a short delay in case the DOM wasn't
     fully ready or a race condition left the guard style in place */
  setTimeout(removeGuard, 800);
})();

/* Global safety-net injected early via an inline <script> in <head> would
   be ideal, but since we can't guarantee that, we attach a hard fallback
   on the window load event from this file too. */
window.addEventListener('load', function () {
  var guard = document.getElementById('acnhs-guard-hide');
  if (guard) guard.parentNode.removeChild(guard);
  document.body.style.setProperty('display', 'block', 'important');
  document.body.style.setProperty('visibility', 'visible', 'important');
  document.body.style.setProperty('opacity', '1', 'important');
});


/* ─────────────────────────────────────────────────────────────────────────────
   QUESTION → NOTE FOCUS
   The test page opens a note as  <note>#acnhs-focus=<base64url JSON>  where the JSON is
   { s: question stem, c: [correct answer texts], r: rationale, a: stored anchor text | null }.
   This finds the passage (list item, table row, alert box…) that best explains THAT question,
   scrolls to it and highlights it. Nothing is changed in the note itself except temporary classes
   and a small banner, both removed by "Clear".
   ───────────────────────────────────────────────────────────────────────────── */
(function () {
  var HASH_KEY = '#acnhs-focus=';
  var STOP = {};
  ('a an the and or of to in on for with without by at as is are was were be been being it its this that these ' +
   'those which what who whom whose when where why how do does did not no nor than then so such into onto from ' +
   'up out over under again here there all any both each few more most other some own same too very can will ' +
   'just should would could may might must shall has have had if but about also may per via ' +
   'nurse client patient following statement statements correct incorrect select apply best likely first ' +
   'appropriate expected recognize recognizes based note notes standard according regarding accurately reflects ' +
   'reflect confirms finding findings include included includes plan care around analyzing evaluating identifies ' +
   'characteristics characteristic associated key fact facts listed list elements element component components ' +
   'selections align').split(' ').forEach(function (w) { STOP[w] = 1; });

  function stem(w) {
    if (w.length > 4 && w.slice(-3) === 'ies') return w.slice(0, -3) + 'y';
    if (w.length > 4 && /(sses|xes|ches|shes)$/.test(w)) return w.slice(0, -2);
    if (w.length > 3 && w.slice(-1) === 's' && !/(ss|us|is)$/.test(w)) return w.slice(0, -1);
    if (w.length > 6 && w.slice(-3) === 'ing') return w.slice(0, -3);
    if (w.length > 5 && w.slice(-2) === 'ed') return w.slice(0, -2);
    return w;
  }

  function tokenize(str) {
    var s = String(str || '').toLowerCase().replace(/[\u2019']/g, '');
    var m = s.match(/[a-z0-9]+/g) || [];
    var out = [];
    m.forEach(function (w) {
      if (STOP[w]) return;
      if (w.length < 2 && !/\d/.test(w)) return;
      out.push(stem(w));
    });
    return out;
  }

  function bigrams(tokens) {
    var out = [];
    for (var i = 0; i < tokens.length - 1; i++) out.push(tokens[i] + ' ' + tokens[i + 1]);
    return out;
  }

  var BLOCK_SEL = 'li,p,tr,table,ul,ol,div,h1,h2,h3,h4,h5,h6,dd,dt,blockquote';
  var SKIP_SEL = 'script,style,noscript,nav,header,footer,.note-header,.note-back,.acnhs-focus-banner,[class^="med-abbr"]';

  // True when the element sits inside page chrome (navigation, header, tooltips...). Stops at <body>,
  // because injected scripts add classes to <body> itself.
  function inChrome(el) {
    for (var n = el; n && n !== document.body; n = n.parentElement) {
      if (n.matches && n.matches(SKIP_SEL)) return true;
    }
    return false;
  }

  function ownText(el) {
    if (el.tagName === 'LI') {
      var t = '';
      el.childNodes.forEach(function (n) {
        if (n.nodeType === 3) t += n.nodeValue;
        else if (n.nodeType === 1 && !/^(UL|OL)$/.test(n.tagName)) t += n.textContent;
      });
      return t;
    }
    return el.textContent;
  }

  // The note's text units, in reading order, each with the heading context it sits under.
  function collectUnits(root) {
    var units = [];
    var section = '', card = '';
    var all = root.querySelectorAll('li,tr,p,h2,h3,h4,h5,div,dd,dt,blockquote');
    for (var i = 0; i < all.length; i++) {
      var el = all[i];
      if (inChrome(el)) continue;
      var tag = el.tagName;
      if (tag === 'DIV' || tag === 'P' || /^H[2-5]$/.test(tag) || tag === 'DD' || tag === 'DT' || tag === 'BLOCKQUOTE') {
        if (el.querySelector(BLOCK_SEL)) continue; // a container, its children are the units
      }
      if (tag === 'TR' && el.querySelector('tr')) continue;
      if (tag === 'TR' && el.querySelector('th') && !el.querySelector('td')) continue; // header row
      var text = ownText(el).replace(/\s+/g, ' ').trim();
      if (text.length < 4) continue;
      var isH = /^H[2-5]$/.test(tag) || (tag === 'DIV' && /section-title|section-head/i.test(el.className));
      if (isH) {
        if (tag === 'H2' || tag === 'H1' || /section-title|section-head/i.test(el.className)) { section = text; card = ''; }
        else card = text;
      }
      var toks = tokenize(text);
      if (!toks.length) continue;
      units.push({ el: el, text: text, toks: toks, set: new Set(toks), bi: new Set(bigrams(toks)), ctx: new Set(tokenize(section + ' ' + card)), heading: isH, section: section });
    }
    return units;
  }

  var TUNE = { wA: 5, wS: 1.4, wR: 0.5, len: 0.3, head: 0.55, ctx: 0.3, bi: 0.5, near: 0.72, sameSection: 1, maxHits: 3 };

  function buildQuery(p) {
    var parts = [
      { toks: tokenize((p.c || []).join(' ')), w: TUNE.wA },
      { toks: tokenize(p.s), w: TUNE.wS },
      { toks: tokenize(p.r), w: TUNE.wR }
    ];
    var tw = {};
    parts.forEach(function (part) {
      part.toks.forEach(function (t) { tw[t] = Math.max(tw[t] || 0, part.w); });
    });
    var bw = {};
    parts.forEach(function (part) {
      bigrams(part.toks).forEach(function (b) { bw[b] = Math.max(bw[b] || 0, part.w); });
    });
    return { tw: tw, bw: bw };
  }

  function rank(units, p) {
    var q = buildQuery(p);
    var df = {};
    units.forEach(function (u) { u.set.forEach(function (t) { df[t] = (df[t] || 0) + 1; }); });
    var N = units.length || 1;
    function idf(t) { return Math.log(1 + N / (df[t] || 1)); }
    var scored = [];
    units.forEach(function (u) {
      var s = 0, hits = 0;
      for (var t in q.tw) {
        if (u.set.has(t)) { s += q.tw[t] * idf(t); hits++; }
        else if (u.ctx.has(t)) { s += TUNE.ctx * q.tw[t] * idf(t); }
      }
      for (var b in q.bw) {
        if (u.bi.has(b)) { var pr = b.split(' '); s += TUNE.bi * q.bw[b] * (idf(pr[0]) + idf(pr[1])) / 2; }
      }
      if (u.heading) s *= TUNE.head; // a heading alone rarely explains the question
      s = s / Math.pow(1 + u.toks.length, TUNE.len);
      if (s > 0) scored.push({ unit: u, score: s, hits: hits });
    });
    scored.sort(function (a, b) { return b.score - a.score; });
    return scored;
  }

  function norm(s) { return String(s || '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim(); }

  // Best passages for a payload: [{ el, text, score }] — first is the best, others are close runners-up in the same section.
  function locate(p, root) {
    root = root || document.body;
    var units = collectUnits(root);
    if (!units.length) return [];
    if (p.a) {
      var na = norm(p.a);
      var head = na.slice(0, 60);
      var exact = units.filter(function (u) { var nu = norm(u.text); return !u.heading && (nu.indexOf(head) !== -1 || (nu.length > 12 && na.indexOf(nu) !== -1)); });
      if (exact.length) return exact.slice(0, 1).map(function (u) { return { el: u.el, text: u.text, score: 99, exact: true }; });
    }
    var ranked = rank(units, p);
    if (!ranked.length) return [];
    var top = ranked[0];
    var out = [{ el: top.unit.el, text: top.unit.text, score: top.score, hits: top.hits }];
    for (var i = 1; i < ranked.length && out.length < TUNE.maxHits; i++) {
      var r = ranked[i];
      if (r.score >= TUNE.near * top.score && (!TUNE.sameSection || r.unit.section === top.unit.section) && !r.unit.el.contains(top.unit.el) && !top.unit.el.contains(r.unit.el)) {
        out.push({ el: r.unit.el, text: r.unit.text, score: r.score, hits: r.hits });
      }
    }
    return out;
  }

  // ── Page behaviour ──────────────────────────────────────────────────────
  function decode(hash) {
    try {
      var b64 = hash.slice(HASH_KEY.length).replace(/-/g, '+').replace(/_/g, '/');
      while (b64.length % 4) b64 += '=';
      return JSON.parse(decodeURIComponent(escape(atob(b64))));
    } catch (e) { return null; }
  }

  function injectStyle() {
    if (document.getElementById('acnhs-focus-style')) return;
    var st = document.createElement('style');
    st.id = 'acnhs-focus-style';
    st.textContent =
      '.acnhs-focus-hit{background:rgba(253,224,71,.30)!important;color:inherit;outline:2px solid #c9a84c;outline-offset:3px;border-radius:8px;box-shadow:0 0 0 7px rgba(201,168,76,.16),0 0 28px rgba(201,168,76,.38);animation:acnhsFocusPulse 1.6s ease-out 1}' +
      'tr.acnhs-focus-hit>td,tr.acnhs-focus-hit>th{background:rgba(253,224,71,.30)!important}' +
      '@keyframes acnhsFocusPulse{0%{box-shadow:0 0 0 0 rgba(253,224,71,.9)}100%{box-shadow:0 0 0 7px rgba(201,168,76,.16),0 0 28px rgba(201,168,76,.38)}}' +
      '.acnhs-focus-banner{position:fixed;top:14px;left:50%;transform:translateX(-50%);z-index:2147483000;display:flex;align-items:center;gap:12px;padding:10px 12px 10px 16px;max-width:calc(100vw - 24px);background:linear-gradient(160deg,#1e293b,#0f172a);border:1px solid rgba(201,168,76,.45);border-radius:14px;box-shadow:0 12px 36px rgba(0,0,0,.45);font:600 13px/1.4 Inter,system-ui,sans-serif;color:#f1f5f9}' +
      '.acnhs-focus-banner b{color:#d4b56a;font-weight:800}' +
      '.acnhs-focus-banner button{flex-shrink:0;border:1px solid rgba(201,168,76,.45);background:rgba(201,168,76,.12);color:#d4b56a;border-radius:9px;padding:6px 12px;font:700 12px Inter,system-ui,sans-serif;cursor:pointer}' +
      '.acnhs-focus-banner button:hover{background:rgba(201,168,76,.24)}';
    document.head.appendChild(st);
  }

  function clearFocus() {
    document.querySelectorAll('.acnhs-focus-hit').forEach(function (e) { e.classList.remove('acnhs-focus-hit'); });
    var b = document.querySelector('.acnhs-focus-banner');
    if (b) b.remove();
    try { history.replaceState(null, '', location.pathname + location.search); } catch (e) { /* ignore */ }
  }

  function banner(html) {
    var b = document.createElement('div');
    b.className = 'acnhs-focus-banner';
    b.innerHTML = '<span>' + html + '</span><button type="button">Clear</button>';
    b.querySelector('button').onclick = clearFocus;
    document.body.appendChild(b);
  }

  var MIN_SCORE = 2.5;
  function run() {
    if (location.hash.indexOf(HASH_KEY) !== 0) return;
    var p = decode(location.hash);
    if (!p) return;
    injectStyle();
    var hits = locate(p, document.body);
    if (!hits.length || (!hits[0].exact && (hits[0].score < MIN_SCORE || hits[0].hits < 2))) {
      banner('This note covers your question, but the <b>exact passage</b> could not be pinpointed.');
      return;
    }
    hits.forEach(function (h) { h.el.classList.add('acnhs-focus-hit'); });
    banner('\uD83D\uDCCD The highlighted part of this note <b>explains your question</b>.');
    setTimeout(function () { hits[0].el.scrollIntoView({ behavior: 'smooth', block: 'center' }); }, 350);
  }

  window.ACNHS_NOTE_FOCUS = { locate: locate, run: run, clear: clearFocus, tokenize: tokenize, tune: TUNE };

  if (document.readyState === 'complete') setTimeout(run, 250);
  else window.addEventListener('load', function () { setTimeout(run, 250); });
})();
