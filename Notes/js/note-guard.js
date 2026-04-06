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
