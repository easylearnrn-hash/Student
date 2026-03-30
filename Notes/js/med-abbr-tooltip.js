/**
 * med-abbr-tooltip.js
 * Shows a tooltip with the expanded form of common medical abbreviations
 * when a student hovers over a <abbr> element.
 */
(function () {
  var tooltip = null;

  function getOrCreateTooltip() {
    if (!tooltip) {
      tooltip = document.createElement('div');
      tooltip.className = 'abbr-tooltip';
      document.body.appendChild(tooltip);
    }
    return tooltip;
  }

  document.addEventListener('mouseover', function (e) {
    var el = e.target.closest('abbr[title]');
    if (!el) return;
    var tip = getOrCreateTooltip();
    tip.textContent = el.getAttribute('title');
    tip.style.display = 'block';
  });

  document.addEventListener('mousemove', function (e) {
    if (!tooltip || tooltip.style.display === 'none') return;
    tooltip.style.left = (e.pageX + 12) + 'px';
    tooltip.style.top  = (e.pageY + 12) + 'px';
  });

  document.addEventListener('mouseout', function (e) {
    var el = e.target.closest('abbr[title]');
    if (!el || !tooltip) return;
    tooltip.style.display = 'none';
  });
})();
