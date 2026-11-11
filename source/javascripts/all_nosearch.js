//= require ./lib/_jquery
//= require ./app/_theme
//= require ./app/_examples
//= require ./app/_copy
//= require ./app/_toc
//= require ./app/_lang

$(function () {
  alignExamples();
  setupCodeCopy();
  setupLanguages($('body').data('languages'));
  setupToc();
});
