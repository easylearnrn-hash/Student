/* case-study-shell.js
   The ONE header every case study uses. It mirrors the test.html header
   (title, user pill, timer, progress, Flag, text size, Invert, Reveal All)
   and the same role split:
     - Admin / faculty: gold pill + REVEAL ALL button
     - Student:         blue pill, the Reveal All button is never created
   ADMIN GATE: browser flags (isAdmin / userRole in storage) are NEVER trusted, because anyone can
   type them into devtools. Admin status comes only from a live Supabase session whose user has a row
   in admin_accounts (row-level security means a student's query returns nothing). It is checked when
   the header loads and AGAIN on every Reveal All click. Any error or timeout = student view.
   Usage in a case study page:
     <script src="js/case-study-shell.js"></script>
     const hdr = CaseStudyShell.mount({ title, total, items, embedded, onExit, onFlag, onRole });
   onRole(isAdmin) fires after each server check; hdr.verifyAdmin() re-checks on demand (use it before any admin-only action).
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

/* Reveal All modal (admin only): built to be scanned in seconds */
#csRevealModal{position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.85);display:flex;align-items:flex-start;justify-content:center;padding:28px 16px;overflow-y:auto}
#csRevealModal .rv-box{background:#0f172a;border:1px solid #334155;border-radius:16px;max-width:980px;width:100%;padding:22px 26px}
#csRevealModal .rv-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;gap:12px}
#csRevealModal h2{font-family:'Playfair Display',serif;font-size:22px;color:#f1f5f9}
#csRevealModal .rv-sub{font-size:12.5px;color:#94a3b8;margin-top:2px}
#csRevealModal .rv-close{background:rgba(255,255,255,.06);border:1.5px solid rgba(255,255,255,.15);color:#cbd5e1;border-radius:8px;padding:7px 14px;font-weight:700;cursor:pointer;flex-shrink:0}
#csRevealModal .rv-glance{border:1px solid #334155;border-radius:12px;background:#1e293b;margin-bottom:18px;overflow:hidden}
#csRevealModal .rv-glance-title{font-size:10.5px;font-weight:800;letter-spacing:1.2px;text-transform:uppercase;color:var(--gold-primary);padding:10px 14px;border-bottom:1px solid #334155}
#csRevealModal .rv-grow{display:grid;grid-template-columns:34px 170px 1fr;gap:10px;align-items:center;padding:8px 14px;border-bottom:1px solid rgba(255,255,255,.06);color:inherit;text-decoration:none;font-size:13px;cursor:pointer}
#csRevealModal .rv-grow:last-child{border-bottom:none}
#csRevealModal .rv-grow:hover{background:rgba(201,168,76,.08)}
#csRevealModal .rv-gn{width:26px;height:26px;border-radius:50%;background:rgba(201,168,76,.18);border:1px solid rgba(201,168,76,.5);color:var(--gold-light);font-weight:800;font-size:12px;display:flex;align-items:center;justify-content:center}
#csRevealModal .rv-gs{font-weight:700;color:#e2e8f0}
#csRevealModal .rv-gk{color:#6ee7b7;font-weight:700;line-height:1.5}
#csRevealModal .rv-item{border:1px solid #334155;border-left:4px solid var(--gold-primary);border-radius:12px;padding:16px 18px 18px;margin-bottom:16px;background:#1e293b}
#csRevealModal .rv-top{display:flex;justify-content:space-between;align-items:center;gap:10px;margin-bottom:8px;flex-wrap:wrap}
#csRevealModal .rv-step{font-size:11px;font-weight:800;letter-spacing:1.2px;text-transform:uppercase;color:var(--gold-primary)}
#csRevealModal .rv-pts{font-size:11px;font-weight:800;letter-spacing:.6px;color:#cbd5e1;border:1px solid #475569;border-radius:20px;padding:3px 10px}
#csRevealModal .rv-prompt{font-weight:700;color:#f1f5f9;margin-bottom:4px;line-height:1.5;font-size:16px}
#csRevealModal .rv-how{font-size:12px;color:#94a3b8;margin-bottom:12px}
#csRevealModal .rv-opt{display:flex;align-items:flex-start;gap:10px;padding:8px 12px;border-radius:9px;margin-bottom:6px;font-size:14px;line-height:1.5;border:1.5px solid transparent;color:#94a3b8;background:rgba(255,255,255,.03)}
#csRevealModal .rv-opt .rv-l{width:24px;height:24px;flex-shrink:0;border-radius:6px;border:1.5px solid #475569;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:800}
#csRevealModal .rv-opt .rv-t{flex:1}
#csRevealModal .rv-opt .rv-m{font-size:10.5px;font-weight:800;letter-spacing:.7px;text-transform:uppercase;white-space:nowrap;padding-left:8px}
#csRevealModal .rv-opt.yes{background:rgba(16,185,129,.14);border-color:#10b981;color:#ecfdf5}
#csRevealModal .rv-opt.yes .rv-l{background:#10b981;border-color:#10b981;color:#052e1b}
#csRevealModal .rv-opt.yes .rv-m{color:#6ee7b7}
#csRevealModal .rv-opt.no .rv-m{color:#64748b}
#csRevealModal .rv-tbl{width:100%;border-collapse:collapse;font-size:14px}
#csRevealModal .rv-tbl td{padding:8px 10px;border-bottom:1px solid rgba(255,255,255,.07);vertical-align:middle;color:#e2e8f0;line-height:1.45}
#csRevealModal .rv-tbl tr:last-child td{border-bottom:none}
#csRevealModal .rv-tbl td.rv-ansc{width:1%;white-space:nowrap;text-align:right}
#csRevealModal .rv-pill{display:inline-block;font-size:12.5px;font-weight:800;padding:4px 12px;border-radius:20px;background:rgba(16,185,129,.16);border:1.5px solid #10b981;color:#6ee7b7}
#csRevealModal .rv-sent{font-size:16px;line-height:2.1;color:#e2e8f0}
#csRevealModal .rv-sent .rv-pill{font-size:14px;margin:0 2px}
#csRevealModal .rv-cols{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}
@media(max-width:820px){#csRevealModal .rv-cols{grid-template-columns:1fr}#csRevealModal .rv-grow{grid-template-columns:34px 1fr}#csRevealModal .rv-gk{grid-column:1 / -1}}
#csRevealModal .rv-col{background:rgba(2,6,23,.35);border:1px solid #334155;border-radius:10px;padding:10px}
#csRevealModal .rv-col h4{font-size:10.5px;letter-spacing:1px;text-transform:uppercase;color:var(--gold-primary);margin-bottom:8px}
#csRevealModal .rv-col .rv-opt{font-size:13px;padding:7px 9px}
#csRevealModal .rv-why{margin-top:14px;border-radius:10px;background:rgba(201,168,76,.08);border:1px solid rgba(201,168,76,.3);padding:12px 14px}
#csRevealModal .rv-why-t{font-size:10.5px;font-weight:800;letter-spacing:1.1px;text-transform:uppercase;color:var(--gold-light);margin-bottom:6px}
#csRevealModal .rv-why ul{margin:0 0 0 18px;padding:0}
#csRevealModal .rv-why li{font-size:13.5px;line-height:1.6;color:#e2e8f0;margin-bottom:4px}

/* Text size (same levels as test.html) */
body[data-zoom="medium"] .prompt{font-size:24px}
body[data-zoom="medium"] .opt,body[data-zoom="medium"] .matrix,body[data-zoom="medium"] .entry p,body[data-zoom="medium"] .vt,body[data-zoom="medium"] .fb p{font-size:17.5px}
body[data-zoom="medium"] .cloze{font-size:20px}
body[data-zoom="medium"] .hint{font-size:15.5px}
body[data-zoom="medium"] .bt-col .opt{font-size:15px}
body[data-zoom="large"] .prompt{font-size:28px}
body[data-zoom="large"] .opt,body[data-zoom="large"] .matrix,body[data-zoom="large"] .entry p,body[data-zoom="large"] .vt,body[data-zoom="large"] .fb p{font-size:20px}
body[data-zoom="large"] .cloze{font-size:23px}
body[data-zoom="large"] .hint{font-size:17.5px}
body[data-zoom="large"] .bt-col .opt{font-size:17px}
body[data-zoom="large"] select{font-size:18px}

/* Invert (light reading mode): warm ivory paper, deep navy ink, rich gold accents */
body.invert-read{background:#fff;background-image:none;color:#0f172a}
body.invert-read input[type="checkbox"],body.invert-read input[type="radio"]{accent-color:#9a7420}
body.invert-read .test-header{background:linear-gradient(180deg,#fffefb,#f8f1df);border-bottom:2px solid #c9a84c;box-shadow:0 6px 22px rgba(90,66,12,.13)}
body.invert-read .test-title{color:#0f172a}
body.invert-read .progress-text{color:#5b5440}
body.invert-read .timer{background:#fbeceb;border-color:#e0a29d;color:#a33a35}
body.invert-read .flag-btn,body.invert-read .zoom-picker,body.invert-read .invert-btn,body.invert-read .exit-btn{background:#fbf6ea;border-color:#d9c99a;color:#3a3523}
body.invert-read .flag-btn.flagged{background:linear-gradient(135deg,#f6d27a,#e4a93a);border-color:#b7791f;color:#2b1d03}
body.invert-read .zoom-btn{color:#5b5440}
body.invert-read .zoom-btn:hover,body.invert-read .flag-btn:hover,body.invert-read .exit-btn:hover,body.invert-read .invert-btn:hover{background:#f3e9cd;border-color:#c9a84c;color:#3a2e0b}
body.invert-read .zoom-btn.active,body.invert-read .invert-btn.active{background:linear-gradient(135deg,#ecd58a,#d6b45a);border:1px solid #b08d2e;color:#2b2106}
body.invert-read #csUserName{color:#0f172a}
body.invert-read #csUserRole{color:#7a5a12 !important}
body.invert-read #csUserPill{background:#fbf6ea !important;border-color:#d9c99a !important}
body.invert-read #csUserAvatar{background:linear-gradient(135deg,#f3e2a9,#e0c36e) !important;border-color:#b08d2e !important;color:#4a3608 !important}
body.invert-read .reveal-all-btn{color:#2b2106;background:linear-gradient(135deg,#ecd58a,#d6b45a);border-color:#b08d2e;box-shadow:0 3px 10px rgba(176,141,46,.28)}

body.invert-read .panel{background:linear-gradient(180deg,#fffefb,#fcf8ee);border-color:#e2d6b4;box-shadow:0 12px 32px rgba(90,66,12,.10),inset 0 1px 0 #fff}
body.invert-read .step{background:#fffdf8;border-color:#e2d6b4;opacity:.85}
body.invert-read .step .n{color:#8a7a52}
body.invert-read .step .l{color:#243047}
body.invert-read .step.active{opacity:1;border-color:#b08d2e;background:linear-gradient(135deg,#f6e7b3,#e8cf80);box-shadow:0 4px 14px rgba(176,141,46,.25)}
body.invert-read .step.active .n{color:#6b4e0a}
body.invert-read .step.active .l{color:#1f1a0a}
body.invert-read .step.done{opacity:1;border-color:#86bf9f;background:#eef7f1}
body.invert-read .step.done .n{color:#1f7a52}
body.invert-read .step.flagged::after{color:#b7791f}
body.invert-read .step.nav:hover{border-color:#b08d2e;opacity:1;box-shadow:0 4px 14px rgba(176,141,46,.2)}
body.invert-read .chart-head,body.invert-read .tabs,body.invert-read .actions{border-color:#eadfc4}
body.invert-read .chart-head h3{color:#7a5a12}
body.invert-read .chart-head small,body.invert-read .counter,body.invert-read .hint{color:#6a6554}
body.invert-read .tabs{background:#f7f1e2}
body.invert-read .tab{color:#6a6554}
body.invert-read .tab:hover{color:#7a5a12}
body.invert-read .tab.active{background:#fffdf8;color:#7a5a12;border-color:#e2d6b4}
body.invert-read .tab .dot{background:#c9a84c;box-shadow:0 0 6px rgba(201,168,76,.7)}
body.invert-read .entry{border-left-color:#c9a84c}
body.invert-read .entry.new{background:linear-gradient(90deg,#f8efd4,transparent)}
body.invert-read .entry .time{color:#8a6516}
body.invert-read .entry p{color:#1d2740}
body.invert-read .entry b{color:#0f172a}
body.invert-read .vt th,body.invert-read .matrix th{color:#5b4b22;background:#f4ecd7;border-color:#e2d6b4}
body.invert-read .vt th.new{color:#7a5a12}
body.invert-read .vt td{color:#0f172a;border-color:#eadfc4}
body.invert-read .vt td.label{color:#7a5a12}
body.invert-read .vt td.label small,body.invert-read .vt td .unit,body.invert-read .vt td .dev{color:#6a6554}
body.invert-read .vt td.new{background:#faf0cf}
body.invert-read .step-chip{background:#f8efd6;border-color:#cdb36a;color:#7a5a12}
body.invert-read .prompt{color:#0f172a}
body.invert-read .new-info{background:#f8efd6;border-color:#d9c28a;color:#6b4e0a}
body.invert-read .opt{background:#fffefb;border-color:#dccfa9;color:#1d2740}
body.invert-read .opt:hover{background:#fcf6e3;border-color:#b08d2e}
body.invert-read .opt:has(input:checked){background:#f8efd6;border-color:#b08d2e;box-shadow:0 0 0 3px rgba(201,168,76,.18)}
body.invert-read .opt.ok{border-color:#3a9a6e !important;background:#e9f6ee !important;box-shadow:none}
body.invert-read .opt.bad{border-color:#c4524d !important;background:#fbeceb !important;box-shadow:none}
body.invert-read .opt.miss{border-color:#c18a2a !important;background:#fcf0d3 !important;box-shadow:none}
body.invert-read .opt.ok .tag{color:#1f7a52}body.invert-read .opt.bad .tag{color:#a8352f}body.invert-read .opt.miss .tag{color:#8a5a0a}
body.invert-read .matrix td{border-color:#eadfc4;color:#1d2740}
body.invert-read .matrix td.right{background:#e3f3ea}
body.invert-read .matrix td.wrong{background:#f9e1df}
body.invert-read .cloze{color:#0f172a}
body.invert-read select{background:#fffdf8;color:#5b4210;border-color:#cdbd93}
body.invert-read select:focus{border-color:#b08d2e;box-shadow:0 0 0 3px rgba(201,168,76,.2)}
body.invert-read select.ok{border-color:#3a9a6e;color:#1f7a52}
body.invert-read select.bad{border-color:#c4524d;color:#a8352f}
body.invert-read .correct-note{color:#1f7a52}
body.invert-read .bt-col{background:#fbf7ec;border-color:#e2d6b4}
body.invert-read .bt-col.center{background:#f8efd6;border-color:#c9a84c}
body.invert-read .bt-col h4{color:#7a5a12}
body.invert-read .bt-col .sub{color:#6a6554}
body.invert-read .btn{color:#1f1604;border-color:#b08d2e;background:linear-gradient(135deg,#e6c96a,#c9a84c);box-shadow:0 4px 14px rgba(176,141,46,.28)}
body.invert-read .btn:hover{box-shadow:0 8px 20px rgba(176,141,46,.38)}
body.invert-read .btn:disabled{box-shadow:none}
body.invert-read .btn.ghost{color:#6b4e0a;background:#fbf2d9;border-color:#c9a84c;box-shadow:none}
body.invert-read .fb.full{border-color:#7fbf9d;background:#eaf6ef}
body.invert-read .fb.part{border-color:#dcae52;background:#fdf3da}
body.invert-read .fb.none{border-color:#d98a86;background:#fbeceb}
body.invert-read .fb .score{color:#0f172a}
body.invert-read .fb p{color:#1d2740}
body.invert-read .big{color:#8a6516}
body.invert-read .skill .row{color:#1d2740}
body.invert-read .skill .bar{background:#eadfc4}
body.invert-read .skill .bar i{background:linear-gradient(90deg,#b08d2e,#d9bb5a)}

body.invert-read #csRevealModal{background:rgba(48,38,14,.55)}
body.invert-read #csRevealModal .rv-box{background:#fffdf8;border-color:#d9c99a;box-shadow:0 24px 64px rgba(48,38,14,.3)}
body.invert-read #csRevealModal h2,body.invert-read #csRevealModal .rv-prompt,body.invert-read #csRevealModal .rv-gs{color:#0f172a}
body.invert-read #csRevealModal .rv-sub,body.invert-read #csRevealModal .rv-how{color:#6a6554}
body.invert-read #csRevealModal .rv-close{background:#fbf6ea;border-color:#d9c99a;color:#3a3523}
body.invert-read #csRevealModal .rv-glance{background:#fbf7ec;border-color:#e2d6b4}
body.invert-read #csRevealModal .rv-glance-title{color:#7a5a12;border-color:#eadfc4}
body.invert-read #csRevealModal .rv-grow{border-color:#eadfc4}
body.invert-read #csRevealModal .rv-grow:hover{background:#f8efd6}
body.invert-read #csRevealModal .rv-gn{background:linear-gradient(135deg,#f3e2a9,#e0c36e);border-color:#b08d2e;color:#4a3608}
body.invert-read #csRevealModal .rv-gk{color:#1f7a52}
body.invert-read #csRevealModal .rv-item{background:#fffefb;border-color:#e2d6b4;border-left-color:#c9a84c}
body.invert-read #csRevealModal .rv-step{color:#7a5a12}
body.invert-read #csRevealModal .rv-pts{color:#5b4b22;border-color:#d9c99a}
body.invert-read #csRevealModal .rv-opt{color:#6a6554;background:#faf6ea}
body.invert-read #csRevealModal .rv-opt .rv-l{border-color:#cdbd93}
body.invert-read #csRevealModal .rv-opt.yes{background:#e9f6ee;border-color:#3a9a6e;color:#0f172a}
body.invert-read #csRevealModal .rv-opt.yes .rv-l{background:#2f8f63;border-color:#2f8f63;color:#fff}
body.invert-read #csRevealModal .rv-opt.yes .rv-m{color:#1f7a52}
body.invert-read #csRevealModal .rv-opt.no .rv-m{color:#8a8470}
body.invert-read #csRevealModal .rv-tbl td{color:#1d2740;border-color:#eadfc4}
body.invert-read #csRevealModal .rv-pill{background:#e9f6ee;border-color:#3a9a6e;color:#1f7a52}
body.invert-read #csRevealModal .rv-sent{color:#0f172a}
body.invert-read #csRevealModal .rv-col{background:#fbf7ec;border-color:#e2d6b4}
body.invert-read #csRevealModal .rv-col h4{color:#7a5a12}
body.invert-read #csRevealModal .rv-why{background:#f8efd6;border-color:#d9c28a}
body.invert-read #csRevealModal .rv-why-t{color:#7a5a12}
body.invert-read #csRevealModal .rv-why li{color:#1d2740}
`;

  var textFormatter = null; // set only while building the answer key so long forms show there too
  var esc = function (s) {
    var out = String(s).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; });
    return textFormatter ? textFormatter(out) : out;
  };
  var store = function (k) { return sessionStorage.getItem(k) || localStorage.getItem(k) || ''; };

  // Display-only identity. Nothing here decides admin access.
  var ROLE = { isLoggedIn: false, userName: null, adminEmail: null };
  var verifiedAdmin = false; // private: only set by a successful server-side check, never exposed
  (function initRole() {
    ROLE.isLoggedIn = sessionStorage.getItem('isLoggedIn') === 'true' || localStorage.getItem('isLoggedIn') === 'true' ||
      !!localStorage.getItem('sb-zlvnxvrzotamhpezqedr-auth-token');
    ROLE.userName = store('userName') || store('teacherName') || null;
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

  // Server-checked admin test (same source of truth as detectArnomaAdmin() in test.html and every admin tool).
  // Fails closed: no session, no admin_accounts row, error or timeout all return false.
  async function verifyAdmin() {
    try {
      if (!window.supabase) await loadScript(BASE + 'supabase.min.js');
      if (typeof window.initSupabase !== 'function') await loadScript(BASE + 'supabase-config.js');
      var client = window.initSupabase();
      if (!client) return false;
      var sd = await withTimeout(client.auth.getSession(), 6000);
      var user = sd && sd.data && sd.data.session && sd.data.session.user;
      if (!user || !user.id) return false;
      var r = await withTimeout(client.from('admin_accounts').select('auth_user_id').eq('auth_user_id', user.id).maybeSingle(), 6000);
      if (r.error || !r.data || r.data.auth_user_id !== user.id) return false;
      ROLE.adminEmail = user.email || null;
      return true;
    } catch (e) {
      return false;
    }
  }

  function identity() {
    var email = store('userEmail') || store('teacherEmail');
    var name = (ROLE.userName || '').trim();
    if (!name && email) name = email.split('@')[0].replace(/[._]/g, ' ').replace(/\b\w/g, function (c) { return c.toUpperCase(); });
    if (!name && verifiedAdmin && ROLE.adminEmail) name = ROLE.adminEmail.split('@')[0];
    if (!name) name = verifiedAdmin ? 'Administrator' : 'Student';
    var parts = name.split(/\s+/).filter(Boolean);
    var initials = parts.length >= 2 ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase() : name.slice(0, 2).toUpperCase();
    var roleLabel = verifiedAdmin ? 'Administrator' : 'Student';
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

  // Generic teacher answer key: quick-glance table first, then one scannable card per item
  var L = function (i) { return String.fromCharCode(65 + i); };
  var HOW = { sata: 'Select all that apply', matrix: 'Match each row to its column(s)', cloze: 'Drop-down sentence', bowtie: 'Bowtie: 1 condition, 2 actions, 2 parameters' };

  function optRows(opts, correct) {
    return opts.map(function (t, i) {
      var yes = correct.indexOf(i) !== -1;
      return '<div class="rv-opt ' + (yes ? 'yes' : 'no') + '"><span class="rv-l">' + L(i) + '</span><span class="rv-t">' + esc(t) + '</span><span class="rv-m">' + (yes ? '✓ Correct' : 'Wrong') + '</span></div>';
    }).join('');
  }
  function keyText(it) {
    if (it.type === 'sata') return it.correct.map(L).join(' · ') + ' (' + it.correct.length + ' of ' + it.options.length + ')';
    if (it.type === 'matrix') return it.rows.map(function (r) { return [].concat(r[1]).map(function (k) { return it.cols[k]; }).join(' + '); }).join(' · ');
    if (it.type === 'cloze') return it.parts.filter(function (p) { return typeof p !== 'string'; }).map(function (p) { return p.opts[p.correct]; }).join(' → ');
    return it.condition.opts[it.condition.correct] + ' | Actions ' + it.actions.correct.map(function (i) { return L(i); }).join('+') + ' | Monitor ' + it.params.correct.map(function (i) { return L(i); }).join('+');
  }
  function answerBody(it) {
    if (it.type === 'sata') return optRows(it.options, it.correct);
    if (it.type === 'matrix') {
      return '<table class="rv-tbl">' + it.rows.map(function (r) { return '<tr><td>' + esc(r[0]) + '</td><td class="rv-ansc">' + [].concat(r[1]).map(function (k) { return '<span class="rv-pill">' + esc(it.cols[k]) + '</span>'; }).join(' ') + '</td></tr>'; }).join('') + '</table>';
    }
    if (it.type === 'cloze') {
      return '<div class="rv-sent">' + it.parts.map(function (p) { return typeof p === 'string' ? esc(p) : '<span class="rv-pill">' + esc(p.opts[p.correct]) + '</span>'; }).join('') + '</div>';
    }
    var col = function (g, title) { return '<div class="rv-col"><h4>' + esc(title) + '</h4>' + optRows(g.opts, g.correct) + '</div>'; };
    var cond = { opts: it.condition.opts, correct: [it.condition.correct] };
    return '<div class="rv-cols">' + col(it.actions, 'Actions (pick 2)') + col(cond, 'Condition (pick 1)') + col(it.params, 'Monitor (pick 2)') + '</div>';
  }
  function whyList(text) {
    var parts = String(text).split(/(?<=[.!?])\s+(?=[A-Z“(])/).filter(Boolean);
    return '<div class="rv-why"><div class="rv-why-t">Why</div><ul>' + parts.map(function (t) { return '<li>' + esc(t) + '</li>'; }).join('') + '</ul></div>';
  }
  function buildRevealHtml(items, format) {
    textFormatter = format || null;
    try { return buildRevealInner(items); } finally { textFormatter = null; }
  }
  function buildRevealInner(items) {
    var total = items.reduce(function (s, it) { return s + it.max; }, 0);
    var glance = '<div class="rv-glance"><div class="rv-glance-title">Answer key at a glance · click a row to jump</div>' +
      items.map(function (it, n) {
        return '<a class="rv-grow" data-jump="rv-item-' + n + '"><span class="rv-gn">' + (n + 1) + '</span><span class="rv-gs">' + esc(it.step) + '</span><span class="rv-gk">' + esc(keyText(it)) + '</span></a>';
      }).join('') + '</div>';
    var cards = items.map(function (it, n) {
      return '<div class="rv-item" id="rv-item-' + n + '"><div class="rv-top"><span class="rv-step">Item ' + (n + 1) + ' of ' + items.length + ' • ' + esc(it.step) + '</span><span class="rv-pts">' + it.max + ' pts</span></div>' +
        '<div class="rv-prompt">' + esc(it.prompt) + '</div><div class="rv-how">' + esc(HOW[it.type] || '') + '</div>' +
        answerBody(it) + whyList(it.rationale) + '</div>';
    }).join('');
    return { sub: items.length + ' items · ' + total + ' points total', html: glance + cards };
  }

  function showRevealModal(title, built) {
    if (!verifiedAdmin) return; // defence in depth: the modal only ever opens for a verified admin
    var old = document.getElementById('csRevealModal');
    if (old) old.remove();
    var m = document.createElement('div');
    m.id = 'csRevealModal';
    m.innerHTML = '<div class="rv-box"><div class="rv-head"><div><h2>' + esc(title) + '</h2><div class="rv-sub">' + esc(built.sub || '') + ' · green = correct answer</div></div><button class="rv-close" type="button">Close</button></div>' + built.html + '</div>';
    m.addEventListener('click', function (e) {
      if (e.target === m || e.target.classList.contains('rv-close')) { m.remove(); return; }
      var row = e.target.closest && e.target.closest('[data-jump]');
      if (row) { var t = m.querySelector('#' + row.getAttribute('data-jump')); if (t) t.scrollIntoView({ behavior: 'smooth', block: 'start' }); }
    });
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
      var teacher = verifiedAdmin;
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
        b.onclick = async function () {
          // Re-verify on every click: a session that ended, or a non-admin, gets nothing
          var ok = await verifyAdmin();
          if (!ok) {
            verifiedAdmin = false;
            var open = document.getElementById('csRevealModal'); if (open) open.remove();
            applyRole();
            return;
          }
          verifiedAdmin = true;
          if (opts.items) showRevealModal('Answer key', buildRevealHtml(opts.items, opts.format));
        };
        slot.appendChild(b);
      }
    }
    applyRole();
    function notifyRole() { if (opts.onRole) opts.onRole(verifiedAdmin); }
    verifyAdmin().then(function (ok) { verifiedAdmin = ok; applyRole(); notifyRole(); });

    function fmt(s) { return String(Math.floor(s / 60)).padStart(2, '0') + ':' + String(s % 60).padStart(2, '0'); }
    function startTimer() {
      stopTimer(); timerSecs = 0;
      document.getElementById('csTimer').textContent = fmt(0);
      timerId = setInterval(function () { timerSecs++; document.getElementById('csTimer').textContent = fmt(timerSecs); }, 1000);
    }
    function stopTimer() { if (timerId) { clearInterval(timerId); timerId = null; } }
    startTimer();

    return {
      // Fresh server-side admin check for gated actions. Fails closed and drops admin UI if it fails.
      verifyAdmin: async function () {
        var ok = await verifyAdmin();
        var changed = ok !== verifiedAdmin;
        verifiedAdmin = ok;
        if (changed) { applyRole(); notifyRole(); }
        return ok;
      },
      setProgress: function (cur, total) { document.getElementById('csProgress').textContent = cur + ' / ' + total; },
      setFlagged: function (on) { document.getElementById('csFlagBtn').classList.toggle('flagged', !!on); },
      startTimer: startTimer,
      stopTimer: stopTimer
    };
  }

  window.CaseStudyShell = { mount: mount };
})();
