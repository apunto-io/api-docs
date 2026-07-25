//= require ./lib/_energize
//= require ./app/_theme
//= require ./app/_copy
//= require ./app/_toc
//= require ./app/_lang

function adjustLanguageSelectorWidth() {
  // Horizontal size/position for the examples-column lang bar is handled in
  // CSS (fixed + left/right). Do not set pixel width here — that caused the
  // sticky bar to extend over the documentation column.
  const elem = $('.dark-box > .lang-selector');
  elem.css('width', '');
}

$(function() {
  loadToc($('#toc'), '.toc-link', '.toc-list-h2', 10);
  setupLanguages($('body').data('languages'));
  $('.content').imagesLoaded( function() {
    window.recacheHeights();
    window.refreshToc();
  });

  $(window).resize(function() {
    adjustLanguageSelectorWidth();
  });
  adjustLanguageSelectorWidth();
});

window.onpopstate = function() {
  activateLanguage(getLanguageFromQueryString());
};
