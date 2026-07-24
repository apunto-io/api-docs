;(function () {
  'use strict';

  var STORAGE_KEY = 'apunto-docs-theme';

  function preferredTheme() {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
    return 'light';
  }

  function applyTheme(theme, persist) {
    document.documentElement.setAttribute('data-theme', theme);
    if (persist) {
      localStorage.setItem(STORAGE_KEY, theme);
    }
  }

  function initThemeToggle() {
    var button = document.getElementById('theme-toggle');
    if (!button) return;

    button.addEventListener('click', function () {
      var next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      applyTheme(next, true);
    });
  }

  // The script tag is loaded in <head>, before #theme-toggle exists in the
  // DOM — wait for DOMContentLoaded so the click handler actually binds.
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initThemeToggle);
  } else {
    initThemeToggle();
  }

  if (window.matchMedia) {
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function (event) {
      if (localStorage.getItem(STORAGE_KEY)) return;
      applyTheme(event.matches ? 'dark' : 'light', false);
    });
  }
})();
