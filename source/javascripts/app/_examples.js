// Slate leaves each example where it sits in the Markdown, usually after the
// parameter tables, so the dark column only fills in at the end of a section.
// On wide screens every section's examples (caption blockquotes and code
// blocks) move right under its heading, so they line up with the endpoint
// they show. When the examples stack under the prose (narrow screens) they go
// back to their place in the text. Order inside a section is kept, so language
// groups stay together.
;(function () {
  'use strict';

  var WIDE = '(min-width: 931px)';
  var moved = [];

  function isExample(node) {
    return node.matches('blockquote, div.highlight, pre');
  }

  function liftToHeadings(content) {
    var heading = null;
    var examples = [];

    function flush() {
      if (heading && examples.length) {
        var ref = heading.nextSibling;
        examples.forEach(function (node) {
          var marker = document.createComment('example');
          content.insertBefore(marker, node);
          moved.push({ node: node, marker: marker });
          content.insertBefore(node, ref);
        });
      }
      examples = [];
    }

    Array.prototype.slice.call(content.children).forEach(function (node) {
      if (node.matches('h1, h2')) {
        flush();
        heading = node;
      } else if (heading && isExample(node)) {
        examples.push(node);
      }
    });
    flush();
  }

  function putBack() {
    moved.forEach(function (entry) {
      entry.marker.parentNode.insertBefore(entry.node, entry.marker);
      entry.marker.parentNode.removeChild(entry.marker);
    });
    moved = [];
  }

  function apply(wide) {
    var content = document.querySelector('.content');
    if (!content) return;
    if (wide && !moved.length) liftToHeadings(content);
    if (!wide && moved.length) putBack();
    if (window.refreshToc) window.refreshToc();
  }

  window.alignExamples = function () {
    if (!window.matchMedia) return apply(true);
    var query = window.matchMedia(WIDE);
    apply(query.matches);
    var onChange = function (e) { apply(e.matches); };
    if (query.addEventListener) query.addEventListener('change', onChange);
    else if (query.addListener) query.addListener(onChange);
  };
})();
