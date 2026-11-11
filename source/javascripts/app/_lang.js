// Example language selector.
//
// Code blocks are tagged by language (pre.tab-shell, pre.tab-javascript, ...).
// A run of consecutive example blocks is one group. In each group the block of
// the chosen language shows; when the group has no block in that language the
// cURL block shows instead, so a tab never leaves an example empty.
// JSON responses and untagged blocks are always visible.
;(function () {
  'use strict';

  var STORAGE_KEY = 'apunto-docs-language';
  var languages = [];
  var groups = null;

  function blockLanguage(block) {
    var pre = block.querySelector('pre');
    if (!pre) return null;
    for (var i = 0; i < languages.length; i++) {
      if (pre.classList.contains('tab-' + languages[i])) return languages[i];
    }
    return null;
  }

  function buildGroups() {
    groups = [];
    var current = [];
    var content = document.querySelector('.content');
    if (!content) return;
    Array.prototype.forEach.call(content.children, function (node) {
      if (node.matches('div.highlight')) {
        if (blockLanguage(node)) current.push(node);
      } else if (current.length) {
        groups.push(current);
        current = [];
      }
    });
    if (current.length) groups.push(current);
  }

  function fromQuery() {
    var match = window.location.search.match(/[?&]lang=([^&#]+)/);
    return match ? decodeURIComponent(match[1]) : null;
  }

  function stored() {
    try { return window.localStorage.getItem(STORAGE_KEY); } catch (e) { return null; }
  }

  function remember(language) {
    try { window.localStorage.setItem(STORAGE_KEY, language); } catch (e) { /* private mode */ }
  }

  function activate(language) {
    if (languages.indexOf(language) === -1) language = languages[0];
    if (!groups) buildGroups();

    groups.forEach(function (group) {
      var hasChosen = group.some(function (block) { return blockLanguage(block) === language; });
      var shown = hasChosen ? language : languages[0];
      group.forEach(function (block) {
        block.hidden = blockLanguage(block) !== shown;
      });
    });

    Array.prototype.forEach.call(document.querySelectorAll('.lang-chip'), function (chip) {
      var active = chip.getAttribute('data-language-name') === language;
      chip.classList.toggle('active', active);
      chip.setAttribute('aria-selected', active ? 'true' : 'false');
    });

    remember(language);
    if (window.refreshToc) window.refreshToc();
  }

  window.activateLanguage = activate;

  window.setupLanguages = function (list) {
    languages = list || [];
    if (!languages.length) return;
    Array.prototype.forEach.call(document.querySelectorAll('.lang-chip'), function (chip) {
      chip.addEventListener('click', function () {
        var heading = currentHeading();
        activate(chip.getAttribute('data-language-name'));
        if (heading) heading.scrollIntoView();
      });
    });
    activate(fromQuery() || stored() || languages[0]);
  };

  // Switching languages changes heights; keep the reader on the same heading.
  function currentHeading() {
    var bar = document.querySelector('.topbar');
    var offset = (bar ? bar.offsetHeight : 60) + 24;
    var found = null;
    Array.prototype.forEach.call(document.querySelectorAll('.content > h1, .content > h2'), function (h) {
      if (h.getBoundingClientRect().top - offset <= 1) found = h;
    });
    return found;
  }
})();
