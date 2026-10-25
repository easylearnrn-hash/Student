/* case-study-shell.js
   The ONE header every case study uses. It mirrors the test.html header
   (title, user pill, timer, progress, Flag, text size, Invert, Reveal All)
   and the same role split:
     - Admin / faculty: gold pill + REVEAL ALL button
     - Student:         blue pill, the Reveal All button is never created
   Usage in a case study page:
     <script src="js/case-study-shell.js"></script>
     const hdr = CaseStudyShell.mount({ title, total, embedded, onExit, onFlag, getRevealHtml });
*/
(function () {
  'use strict';

  var BASE = (document.currentScript && document.currentScript.src || '').replace(/[^/]*$/, '');

  var CSS = `
.test-header{position:sticky;top:0;background:rgba(15,23,42,0.98);border-bottom:2px solid var(--gold-primary);padding:14px 24px;z-index:100;box-shadow:0 4px 20px rgba(0,0,0,.25)}
.test-header-content{max-width:1400px;margin:0 auto;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px 16px}
.test-header .hdr-left{display:flex;align-items:center;gap:14px;min-width:0;flex:1}
.test-title{font-family:'Playfair Display',serif;font-size:18px;font-weight:700;color:#f8fafc;letter-spacing:.3px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:520px}
.test-meta{display:flex;align-items:center;gap:16px;flex-wrap:wrap;flex-shrink:0}
.timer{display:flex;align-items:center;gap:8px;padding:8px 16px;background:rgba(239,68,68,.12);border:1.5px solid rgba(239,68,68,.35);border-radius:8px;font-weight:700;color:#fca5a5;font-size:15px}
.progress-text{font-weight:600;color:#94a3b8;font-size:13px;white-space:nowrap}
.flag-btn{padding:8px 14px;background:rgba(255,255,255,.06);border:1.5px solid rgba(255,255,255,.15);border-radius:8px;font-weight:600;cursor:pointer;transition:all .15s;display:flex;align-items:center;gap:8px;font-size:13px;color:#cbd5e1}
.flag-btn:hover{border-color:var(--gold-primary);background:rgba(201,168,76,.1);color:var(--gold-primary)}
.flag-btn.flagged{border-color:var(--warning);background:var(--warning);color:#0f172a}
.zoom-picker{display:flex;align-items:center;gap:4px;padding:4px;background:rgba(255,255,255,.05);border:1.5px solid rgba(255,255,255,.12);border-radius:10px}
.zoom-btn{display:flex;align-items:center;justify-content:center;padding:5px 10px;border-radius:7px;border:none;background:transparent;cursor:pointer;font-family:'Inter',sans-serif;font-weight:800;color:#94a3b8;letter-spacing:.3px;transition:all .15s;white-space:nowrap;line-height:1}
.zoom-btn:hover{background:rgba(255,255,255,.07);color:#f1f5f9}
.zoom-btn.active{background:linear-gradient(135deg,rgba(201,168,76,.22),rgba(201,168,76,.10));border:1px solid rgba(201,168,76,.45);color:var(--gold-primary)}
.zoom-btn[data-size="small"]{font-size:11px}.zoom-btn[data-size="medium"]{font-size:13px}.zoom-btn[data-size="large"]{font-size:16px}
.invert-btn{display:flex;align-items:center;justify-content:center;gap:6px;padding:8px 12px;background:rgba(255,255,255,.05);border:1.5px solid rgba(255,255,255,.12);border-radius:10px;cursor:pointer;font-size:12px;font-weight:700;letter-spacing:.4px;color:#94a3b8;transition:all .15s;white-space:nowrap;line-height:1}
.invert-btn:hover{background:rgba(255,255,255,.07);color:#f1f5f9}
.invert-btn.active{background:linear-gradient(135deg,rgba(201,168,76,.22),rgba(201,168,76,.10));border-color:rgba(201,168,76,.45);color:var(--gold-primary)}
.reveal-all-btn{display:flex;align-items:center;gap:7px;padding:8px 16px;border-radius:8px;border:2px solid rgba(201,168,76,.6);background:linear-gradient(135deg,rgba(201,168,76,.18),rgba(201,168,76,.07));color:var(--gold-primary);font-weight:700;font-size:13px;cursor:pointer;letter-spacing:.5px;transition:.2s}
.exit-btn{display:flex;align-items:center;gap:6px;padding:8px 12px;border-radius:8px;border:1.5px solid rgba(255,255,255,.15);background:rgba(255,255,255,.06);color:#cbd5e1;font-weight:700;font-size:12px;cursor:pointer;white-space:nowrap;flex-shrink:0}
.exit-btn:hover{border-color:var(--gold-primary);color:var(--gold-primary)}
#csUserPill{display:inline-flex;align-items:center;gap:9px;padding:5px 14px 5px 5px;border-radius:999px;flex-shrink:0;max-width:260px;overflow:hidden}
#csUserAvatar{display:inline-flex;align-items:center;justify-content:center;width:30px;height:30px;border-radius:50%;border:1.5px solid;font-weight:900;font-size:11px;letter-spacing:.5px;flex-shrink:0}
#csUserText{display:flex;flex-direction:column;min-width:0;line-height:1.25}
#csUserName{color:#f1f5f9;font-size:13px;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;letter-spacing:.1px}
#csUserRole{font-size:9.5px;font-weight:800;letter-spacing:.8px;text-transform:uppercase}

/* Reveal All modal (admin only) */
#csRevealModal{position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.85);display:flex;align-items:flex-start;justify-content:center;padding:32px 16px;overflow-y:auto}
#csRevealModal .rv-box{background:#0f172a;border:1px solid #334155;border-radius:16px;max-width:860px;width:100%;padding:24px 28px}
#csRevealModal .rv-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px}
#csRevealModal h2{font-family:'Playfair Display',serif;font-size:22px;color:#f1f5f9}
#csRevealModal .rv-close{background:rgba(255,255,255,.06);border:1.5px solid rgba(255,255,255,.15);color:#cbd5e1;border-radius:8px;padding:7px 14px;font-weight:700;cursor:pointer}
#csRevealModal .rv-item{border:1px solid #334155;border-left:3px solid var(--gold-primary);border-radius:12px;padding:16px 18px;margin-bottom:14px;background:#1e293b}
#csRevealModal .rv-step{font-size:10px;font-weight:800;letter-spacing:1.2px;text-transform:uppercase;color:var(--gold-primary);margin-bottom:6px}
#csRevealModal .rv-prompt{font-weight:700;color:#f1f5f9;margin-bottom:8px;line-height:1.5}
#csRevealModal ul{margin:0 0 10px 18px;color:#cbd5e1;font-size:14px;line-height:1.6}
#csRevealModal .rv-ans li{color:#6ee7b7}
#csRevealModal .rv-lbl{font-size:10.5px;font-weight:800;letter-spacing:1px;text-transform:uppercase;color:#94a3b8;margin:8px 0 3px}
#csRevealModal .rv-rat{font-size:13.5px;line-height:1.7;color:#cbd5e1}

/* Text size (same levels as test.html) */
body[data-zoom="medium"] .prompt{font-size:24px}
body[data-zoom="medium"] .opt,body[data-zoom="medium"] .matrix,body[data-zoom="medium"] .entry p,body[data-zoom="medium"] .vt,body[data-zoom="medium"] .fb p{font-size:16px}
body[data-zoom="medium"] .cloze{font-size:19px}
body[data-zoom="medium"] .hint,body[data-zoom="medium"] .bt-col .opt{font-size:14.5px}
body[data-zoom="large"] .prompt{font-size:28px}
body[data-zoom="large"] .opt,body[data-zoom="large"] .matrix,body[data-zoom="large"] .entry p,body[data-zoom="large"] .vt,body[data-zoom="large"] .fb p{font-size:18.5px}
body[data-zoom="large"] .cloze{font-size:22px}
body[data-zoom="large"] .hint,body[data-zoom="large"] .bt-col .opt{font-size:16.5px}
body[data-zoom="large"] select{font-size:17px}

/* Invert: bright background, dark text (same palette as test.html) */
body.invert-read{background:#fff;background-image:none;color:#0f172a}
body.invert-read .test-header{background:#fff;border-bottom-color:#a8832a;box-shadow:0 2px 10px rgba(15,23,42,.12)}
body.invert-read .test-title{color:#0f172a}
body.invert-read .progress-text{color:#334155}
body.invert-read .timer{background:#fee2e2;border-color:#dc2626;color:#991b1b}
body.invert-read .flag-btn,body.invert-read .zoom-picker,body.invert-read .invert-btn,body.invert-read .exit-btn{background:#f1f5f9;border-color:#94a3b8;color:#0f172a}
body.invert-read .flag-btn.flagged{background:#fbbf24;border-color:#d97706;color:#0f172a}
body.invert-read .zoom-btn{color:#334155}
body.invert-read .zoom-btn:hover,body.invert-read .flag-btn:hover,body.invert-read .exit-btn:hover,body.invert-read .invert-btn:hover{background:#e2e8f0;color:#0f172a}
body.invert-read .zoom-btn.active,body.invert-read .invert-btn.active{background:#fdf3d0;border-color:#a8832a;color:#6b4e0a}
body.invert-read #csUserName{color:#0f172a}
body.invert-read #csUserRole{color:#6b4e0a !important}
body.invert-read #csUserPill{background:#f8fafc !important;border-color:#94a3b8 !important}
body.invert-read #csUserAvatar{background:#fdf3d0 !important;border-color:#a8832a !important;color:#6b4e0a !important}
body.invert-read .reveal-all-btn{color:#6b4e0a;background:#fdf3d0;border-color:#a8832a}

body.invert-read .panel{background:#fff;border-color:#94a3b8;box-shadow:0 4px 18px rgba(15,23,42,.12)}
body.invert-read .step{background:#fff;border-color:#94a3b8;opacity:.75}
body.invert-read .step .n{color:#475569}
body.invert-read .step .l{color:#0f172a}
body.invert-read .step.active{opacity:1;border-color:#a8832a;background:#fdf3d0}
body.invert-read .step.active .n{color:#6b4e0a}
body.invert-read .step.done{opacity:1;border-color:#15803d;background:#f0fdf4}
body.invert-read .step.done .n{color:#15803d}
body.invert-read .step.flagged::after{color:#b45309}
body.invert-read .chart-head,body.invert-read .tabs,body.invert-read .actions{border-color:#cbd5e1}
body.invert-read .chart-head h3{color:#6b4e0a}
body.invert-read .chart-head small,body.invert-read .counter,body.invert-read .hint{color:#475569}
body.invert-read .tabs{background:#f8fafc}
body.invert-read .tab{color:#475569}
body.invert-read .tab.active{background:#fff;color:#6b4e0a;border-color:#94a3b8}
body.invert-read .tab .dot{background:#a8832a;box-shadow:none}
body.invert-read .entry{border-left-color:#a8832a}
body.invert-read .entry.new{background:linear-gradient(90deg,#fdf3d0,transparent)}
body.invert-read .entry .time{color:#6b4e0a}
body.invert-read .entry b{color:#0f172a}
body.invert-read .vt th,body.invert-read .matrix th{color:#334155;background:#f8fafc;border-color:#cbd5e1}
body.invert-read .vt th.new{color:#6b4e0a}
body.invert-read .vt td{color:#0f172a;border-color:#e2e8f0}
body.invert-read .vt td.label{color:#6b4e0a}
body.invert-read .vt td.label small,body.invert-read .vt td .unit,body.invert-read .vt td .dev{color:#475569}
body.invert-read .vt td.new{background:#fdf3d0}
body.invert-read .step-chip{background:#fdf3d0;border-color:#a8832a;color:#6b4e0a}
body.invert-read .prompt{color:#0f172a}
body.invert-read .new-info{background:#fdf3d0;border-color:#a8832a;color:#6b4e0a}
body.invert-read .opt{background:#fff;border-color:#94a3b8;color:#0f172a}
body.invert-read .opt:hover{background:#fdf8e6;border-color:#a8832a}
body.invert-read .opt:has(input:checked){background:#fdf3d0;border-color:#a8832a}
body.invert-read .opt.ok{border-color:#15803d !important;background:#dcfce7 !important}
body.invert-read .opt.bad{border-color:#b91c1c !important;background:#fee2e2 !important}
body.invert-read .opt.miss{border-color:#d97706 !important;background:#fef3c7 !important}
body.invert-read .opt.ok .tag{color:#15803d}body.invert-read .opt.bad .tag{color:#b91c1c}body.invert-read .opt.miss .tag{color:#92400e}
body.invert-read .matrix td{border-color:#e2e8f0}
body.invert-read .matrix td.right{background:#dcfce7}
body.invert-read .matrix td.wrong{background:#fee2e2}
body.invert-read .cloze{color:#0f172a}
body.invert-read select{background:#f1f5f9;color:#0f172a;border-color:#64748b}
body.invert-read select.ok{border-color:#15803d;color:#166534}
body.invert-read select.bad{border-color:#b91c1c;color:#991b1b}
body.invert-read .correct-note{color:#15803d}
body.invert-read .bt-col{background:#f8fafc;border-color:#94a3b8}
body.invert-read .bt-col.center{background:#fdf8e6;border-color:#a8832a}
body.invert-read .bt-col h4{color:#6b4e0a}
body.invert-read .bt-col .sub{color:#475569}
body.invert-read .btn{color:#0f172a}
body.invert-read .btn.ghost{color:#6b4e0a;background:#fdf3d0}
body.invert-read .fb.full{border-color:#15803d;background:#f0fdf4}
body.invert-read .fb.part{border-color:#d97706;background:#fffbeb}
body.invert-read .fb.none{border-color:#b91c1c;background:#fef2f2}
body.invert-read .fb .score{color:#0f172a}
body.invert-read .fb p{color:#0f172a}
body.invert-read .big{color:#6b4e0a}
body.invert-read .skill .bar{background:#e2e8f0}
body.invert-read .skill .bar i{background:linear-gradient(90deg,#a8832a,#c9a84c)}
body.invert-read #csRevealModal .rv-box{background:#fff;border-color:#94a3b8}
body.invert-read #csRevealModal h2,body.invert-read #csRevealModal .rv-prompt{color:#0f172a}
body.invert-read #csRevealModal .rv-item{background:#f8fafc;border-color:#94a3b8;border-left-color:#a8832a}
body.invert-read #csRevealModal ul,body.invert-read #csRevealModal .rv-rat{color:#0f172a}
body.invert-read #csRevealModal .rv-ans li{color:#166534}
body.invert-read #csRevealModal .rv-step{color:#6b4e0a}
body.invert-read #csRevealModal .rv-close{background:#f1f5f9;border-color:#94a3b8;color:#0f172a}
`;

  var esc = function (s) {
    return String(s).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; });
  };
  var store = function (k) { return sessionStorage.getItem(k) || localStorage.getItem(k) || ''; };

  // Same identity rules as test.html initSessionRole()
  var ROLE = { isLoggedIn: false, isTeacher: false, userRole: null, userName: null };
  (function initRole() {
    ROLE.isLoggedIn = sessionStorage.getItem('isLoggedIn') === 'true' || localStorage.getItem('isLoggedIn') === 'true' ||
      !!localStorage.getItem('sb-zlvnxvrzotamhpezqedr-auth-token');
    var isAdmin = store('isAdmin') === 'true';
    var role = store('userRole').toLowerCase().trim();
    ROLE.userRole = role || (isAdmin ? 'admin' : 'student');
    ROLE.userName = store('userName') || store('teacherName') || null;
    ROLE.isTeacher = ['teacher', 'admin', 'superadmin', 'instructor'].indexOf(role) !== -1 || isAdmin;
  })();

  function withTimeout(p, ms) {
    return Promise.race([p, new Promise(function (_, rej) { setTimeout(function () { rej(new Error('timeout')); }, ms); })]);
  }
  function loadScript(src) {
    return new Promise(function (res, rej) {
      var s = document.createElement('script');
      s.src = src; s.onload = res; s.onerror = rej;
      document.head.appendChild(s);
    });
  }

  // ARNOMA admins sign in with Supabase (admin_accounts), same check as test.html detectArnomaAdmin()
  async function detectAdmin() {
    if (ROLE.isTeacher) return;
    try {
      if (window.parent !== window && window.parent.SESSION_ROLE && window.parent.SESSION_ROLE.isTeacher) {
        ROLE.isTeacher = true;
        ROLE.userRole = window.parent.SESSION_ROLE.userRole || 'admin';
        ROLE.userName = ROLE.userName || window.parent.SESSION_ROLE.userName;
        return;
      }
    } catch (e) { /* cross-origin parent: fall through */ }
    try {
      if (!window.supabase) await loadScript(BASE + 'supabase.min.js');
      if (typeof window.initSupabase !== 'function') await loadScript(BASE + 'supabase-config.js');
      var client = window.initSupabase();
      if (!client) return;
      var sd = await withTimeout(client.auth.getSession(), 4000);
      var user = sd && sd.data && sd.data.session && sd.data.session.user;
      if (!user) return;
      var r = await withTimeout(client.from('admin_accounts').select('auth_user_id').eq('auth_user_id', user.id).maybeSingle(), 4000);
      if (r.error || !r.data) return;
      ROLE.isTeacher = true;
      ROLE.userRole = 'admin';
      if (!ROLE.userName && user.email) ROLE.userName = user.email.split('@')[0];
    } catch (e) { console.warn('case study admin check skipped:', e && e.message); }
  }

  function identity() {
    var email = store('userEmail') || store('teacherEmail');
    var name = (ROLE.userName || '').trim();
    if (!name && email) name = email.split('@')[0].replace(/[._]/g, ' ').replace(/\b\w/g, function (c) { return c.toUpperCase(); });
    if (!name) name = ROLE.isTeacher ? 'Faculty' : 'Student';
    var parts = name.split(/\s+/).filter(Boolean);
    var initials = parts.length >= 2 ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase() : name.slice(0, 2).toUpperCase();
    var roleLabel = ROLE.isTeacher ? (ROLE.userRole === 'admin' || ROLE.userRole === 'superadmin' ? 'Administrator' : 'Faculty') : 'Student';
    return { name: name, initials: initials, roleLabel: roleLabel };
  }

  function setZoom(level) {
    if (['small', 'medium', 'large'].indexOf(level) === -1) level = 'small';
    document.body.setAttribute('data-zoom', level);
    localStorage.setItem('acnhs_test_zoom', level);
    document.querySelectorAll('#csZoomPicker .zoom-btn').forEach(function (b) { b.classList.toggle('active', b.dataset.size === level); });
  }
  function setInvert(on) {
    document.body.classList.toggle('invert-read', !!on);
    localStorage.setItem('acnhs_test_invert', on ? '1' : '0');
    var b = document.getElementById('csInvertBtn');
    if (b) { b.classList.toggle('active', !!on); b.setAttribute('aria-pressed', on ? 'true' : 'false'); }
  }

  // Generic "all answers + rationales" view for the admin Reveal All button
  function buildRevealHtml(items) {
    var li = function (arr) { return '<ul class="rv-ans">' + arr.map(function (t) { return '<li>' + esc(t) + '</li>'; }).join('') + '</ul>'; };
    return items.map(function (it, n) {
      var body = '';
      if (it.type === 'sata') body = li(it.correct.map(function (i) { return it.options[i]; }));
      else if (it.type === 'matrix') body = li(it.rows.map(function (r) { return r[0] + ' → ' + it.cols[r[1]]; }));
      else if (it.type === 'cloze') body = li([it.parts.map(function (p) { return typeof p === 'string' ? p : '[' + p.opts[p.correct] + ']'; }).join('')]);
      else {
        body = '<div class="rv-lbl">' + esc(it.condition.title) + '</div>' + li([it.condition.opts[it.condition.correct]]) +
          '<div class="rv-lbl">' + esc(it.actions.title) + '</div>' + li(it.actions.correct.map(function (i) { return it.actions.opts[i]; })) +
          '<div class="rv-lbl">' + esc(it.params.title) + '</div>' + li(it.params.correct.map(function (i) { return it.params.opts[i]; }));
      }
      return '<div class="rv-item"><div class="rv-step">Item ' + (n + 1) + ' • ' + esc(it.step) + '</div><div class="rv-prompt">' + esc(it.prompt) + '</div>' +
        body + '<div class="rv-lbl">Rationale</div><div class="rv-rat">' + esc(it.rationale) + '</div></div>';
    }).join('');
  }

  function showRevealModal(title, html) {
    if (!ROLE.isTeacher) return; // students can never open this
    var old = document.getElementById('csRevealModal');
    if (old) old.remove();
    var m = document.createElement('div');
    m.id = 'csRevealModal';
    m.innerHTML = '<div class="rv-box"><div class="rv-head"><h2>' + esc(title) + '</h2><button class="rv-close" type="button">Close</button></div>' + html + '</div>';
    m.addEventListener('click', function (e) { if (e.target === m || e.target.classList.contains('rv-close')) m.remove(); });
    document.body.appendChild(m);
  }

  function mount(opts) {
    if (!ROLE.isLoggedIn) { window.location.replace('../index.html'); return null; }
    var style = document.createElement('style');
    style.id = 'csShellStyles';
    style.textContent = CSS;
    document.head.appendChild(style);

    var host = document.getElementById('csHeader');
    var timerSecs = 0, timerId = null;
    var flagSvg = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><line x1="4" y1="22" x2="4" y2="15"/></svg>';
    host.className = 'test-header';
    host.innerHTML =
      '<div class="test-header-content">' +
        '<div class="hdr-left">' +
          (opts.embedded ? '<button class="exit-btn" id="csExitBtn" type="button">✕ Topics</button>' : '') +
          '<div class="test-title" id="csTitle" title="' + esc(opts.title) + '">' + esc(opts.title) + '</div>' +
          '<div id="csUserPill"><span id="csUserAvatar">?</span><span id="csUserText"><span id="csUserName">—</span><span id="csUserRole">—</span></span></div>' +
        '</div>' +
        '<div class="test-meta">' +
          '<div class="timer"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg><span id="csTimer">00:00</span></div>' +
          '<div class="progress-text" id="csProgress">0 / ' + opts.total + '</div>' +
          '<button class="flag-btn" id="csFlagBtn" type="button">' + flagSvg + '<span>Flag</span></button>' +
          '<div class="zoom-picker" id="csZoomPicker" title="Text size">' +
            '<button class="zoom-btn" data-size="small" title="Small text" type="button">A</button>' +
            '<button class="zoom-btn" data-size="medium" title="Medium text" type="button">A</button>' +
            '<button class="zoom-btn" data-size="large" title="Large text" type="button">A</button>' +
          '</div>' +
          '<button class="invert-btn" id="csInvertBtn" type="button" title="Invert colors (bright background, dark text)" aria-pressed="false">' +
            '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 3v18"/><path d="M12 3a9 9 0 0 1 0 18z" fill="currentColor"/></svg><span>Invert</span></button>' +
          '<span id="csRevealSlot"></span>' +
        '</div>' +
      '</div>';

    host.querySelectorAll('#csZoomPicker .zoom-btn').forEach(function (b) { b.onclick = function () { setZoom(b.dataset.size); }; });
    document.getElementById('csInvertBtn').onclick = function () { setInvert(!document.body.classList.contains('invert-read')); };
    document.getElementById('csFlagBtn').onclick = function () { if (opts.onFlag) opts.onFlag(); };
    if (opts.embedded) {
      var exit = function () { if (opts.onExit) opts.onExit(); };
      document.getElementById('csExitBtn').onclick = exit;
      document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !document.getElementById('csRevealModal')) exit(); });
    }
    setZoom(localStorage.getItem('acnhs_test_zoom') || 'small');
    setInvert(localStorage.getItem('acnhs_test_invert') === '1');

    // Student view first; the admin-only controls are added only once admin status is confirmed
    function applyRole() {
      var id = identity();
      var teacher = ROLE.isTeacher;
      var color = teacher ? 'var(--gold-primary)' : '#38bdf8';
      var av = document.getElementById('csUserAvatar'), pill = document.getElementById('csUserPill');
      av.textContent = id.initials;
      av.style.background = teacher ? 'rgba(201,168,76,0.15)' : 'rgba(56,189,248,0.12)';
      av.style.borderColor = teacher ? 'rgba(201,168,76,0.5)' : 'rgba(56,189,248,0.45)';
      av.style.color = color;
      document.getElementById('csUserName').textContent = id.name;
      var roleEl = document.getElementById('csUserRole');
      roleEl.textContent = id.roleLabel;
      roleEl.style.color = color;
      pill.style.background = teacher ? 'rgba(201,168,76,0.07)' : 'rgba(56,189,248,0.07)';
      pill.style.border = '1px solid ' + (teacher ? 'rgba(201,168,76,0.22)' : 'rgba(56,189,248,0.18)');
      var slot = document.getElementById('csRevealSlot');
      slot.innerHTML = '';
      if (teacher) {
        var b = document.createElement('button');
        b.type = 'button'; b.id = 'csRevealBtn'; b.className = 'reveal-all-btn';
        b.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>REVEAL ALL';
        b.onclick = function () { if (opts.getRevealHtml) showRevealModal('All answers & rationales', opts.getRevealHtml()); };
        slot.appendChild(b);
      }
    }
    applyRole();
    detectAdmin().then(applyRole);

    function fmt(s) { return String(Math.floor(s / 60)).padStart(2, '0') + ':' + String(s % 60).padStart(2, '0'); }
    function startTimer() {
      stopTimer(); timerSecs = 0;
      document.getElementById('csTimer').textContent = fmt(0);
      timerId = setInterval(function () { timerSecs++; document.getElementById('csTimer').textContent = fmt(timerSecs); }, 1000);
    }
    function stopTimer() { if (timerId) { clearInterval(timerId); timerId = null; } }
    startTimer();

    return {
      setProgress: function (cur, total) { document.getElementById('csProgress').textContent = cur + ' / ' + total; },
      setFlagged: function (on) { document.getElementById('csFlagBtn').classList.toggle('flagged', !!on); },
      startTimer: startTimer,
      stopTimer: stopTimer
    };
  }

  window.CaseStudyShell = { mount: mount, buildRevealHtml: buildRevealHtml, role: ROLE };
})();
