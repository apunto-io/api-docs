//= require ../lib/_lunr
//= require ../lib/_jquery
//= require ../lib/_jquery.highlight
;(function () {
  'use strict';

  var content, searchResults, searchInputEl, searchClearBtn, searchWrapper;
  var highlightOpts = { element: 'span', className: 'search-highlight' };
  var searchDelay = 0;
  var timeoutHandle = 0;
  var index;
  var activeIndex = -1;
  var lastResultCount = 0;

  function populate() {
    index = lunr(function () {
      this.ref('id');
      this.field('title', { boost: 10 });
      this.field('body', { metadataWhitelist: ['position'] });
      this.pipeline.add(lunr.trimmer, lunr.stopWordFilter);

      var lunrConfig = this;

      $('h1, h2').each(function () {
        var title = $(this);
        var body = title.nextUntil('h1, h2');
        lunrConfig.add({
          id: title.prop('id'),
          title: title.text(),
          body: body.text()
        });
      });
    });
    determineSearchDelay();
  }

  $(populate);
  $(bind);

  function determineSearchDelay() {
    if (index.tokenSet.toArray().length > 5000) {
      searchDelay = 250;
    }
  }

  function escapeHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  // Turn free-text user input into a forgiving lunr query: every term is
  // searched both as-typed (default weight) and as a trailing wildcard, so
  // "cancel" also surfaces "cancelar", "cancelación", etc. — not just exact
  // stemmed matches, which is how the old search made partial words return
  // nothing.
  function buildQuery(raw) {
    var terms = raw
      .trim()
      .split(/\s+/)
      .filter(Boolean)
      .map(function (t) { return t.replace(/[*^~:+-]/g, ''); })
      .filter(Boolean);

    if (!terms.length) return '';

    return terms
      .map(function (t) { return t + ' ' + t + '*'; })
      .join(' ');
  }

  function runSearch(rawValue) {
    var query = buildQuery(rawValue);
    if (!query) return [];

    try {
      return index.search(query).filter(function (r) {
        return r.score > 0.0001;
      });
    } catch (e) {
      // Malformed query (stray lunr operator, etc.) — fail soft to no results
      // instead of throwing and breaking the input entirely.
      return [];
    }
  }

  // Pull a short excerpt of body text around the first indexed match so
  // results show *why* they matched, not just a heading title.
  function snippetFor(result, elem, rawValue) {
    var bodyText = $(elem).nextUntil('h1, h2').text().replace(/\s+/g, ' ').trim();
    if (!bodyText) return '';

    var metadata = result.matchData && result.matchData.metadata;
    var position = null;

    if (metadata) {
      Object.keys(metadata).forEach(function (term) {
        if (position) return;
        var fields = metadata[term];
        if (fields.body && fields.body.position && fields.body.position.length) {
          position = fields.body.position[0];
        }
      });
    }

    var radius = 60;
    var start, snippet;

    if (position) {
      start = Math.max(0, position[0] - radius);
      snippet = bodyText.slice(start, start + position[1] + radius * 2);
    } else {
      snippet = bodyText.slice(0, radius * 2);
    }

    if (start > 0) snippet = '…' + snippet;
    if (start + snippet.length < bodyText.length) snippet = snippet + '…';

    var escaped = escapeHtml(snippet);
    var terms = rawValue.trim().split(/\s+/).filter(Boolean);
    terms.forEach(function (term) {
      var safeTerm = term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      escaped = escaped.replace(new RegExp('(' + safeTerm + ')', 'ig'), '<mark>$1</mark>');
    });

    return escaped;
  }

  function breadcrumbFor(elem) {
    var $elem = $(elem);
    if ($elem.is('h1')) return '';
    var $parentH1 = $elem.prevAll('h1').first();
    return $parentH1.length ? $parentH1.text() : '';
  }

  function badgeFor(elem) {
    var $badge = $(elem).find('.badge').first();
    if (!$badge.length) return '';
    return '<span class="' + $badge.attr('class') + ' search-result-badge">' + $badge.text() + '</span>';
  }

  function setActive(newIndex) {
    var items = searchResults.find('li[data-nav]');
    if (!items.length) return;

    if (newIndex < 0) newIndex = items.length - 1;
    if (newIndex >= items.length) newIndex = 0;

    items.removeClass('active');
    activeIndex = newIndex;
    items.eq(activeIndex).addClass('active');
  }

  function goToActive() {
    var $active = searchResults.find('li[data-nav].active a');
    if ($active.length) {
      $active[0].click();
    } else {
      var $first = searchResults.find('li[data-nav] a').first();
      if ($first.length) $first[0].click();
    }
  }

  function closeResults() {
    searchResults.removeClass('visible');
    activeIndex = -1;
  }

  function toggleClearButton() {
    searchWrapper.toggleClass('has-value', !!searchInputEl.value);
  }

  function bind() {
    content = $('.content');
    searchResults = $('.search-results');
    searchInputEl = $('#input-search')[0];
    searchClearBtn = $('#search-clear');
    searchWrapper = $('.topbar-search');

    $('#input-search').on('keyup', function (e) {
      // Arrow/enter/escape are handled on keydown for reliable preventDefault;
      // ignore them here so we don't re-run search on every navigation key.
      if ([38, 40, 13, 27].indexOf(e.keyCode) !== -1) return;

      toggleClearButton();

      var wait = function () {
        return function (executingFunction, waitTime) {
          clearTimeout(timeoutHandle);
          timeoutHandle = setTimeout(executingFunction, waitTime);
        };
      }();
      wait(function () {
        search(e);
      }, searchDelay);
    });

    $('#input-search').on('keydown', function (e) {
      switch (e.keyCode) {
        case 40: // Down
          e.preventDefault();
          setActive(activeIndex + 1);
          break;
        case 38: // Up
          e.preventDefault();
          setActive(activeIndex - 1);
          break;
        case 13: // Enter
          e.preventDefault();
          goToActive();
          break;
        case 27: // Escape
          searchInputEl.value = '';
          toggleClearButton();
          unhighlight();
          closeResults();
          searchInputEl.blur();
          break;
      }
    });

    if (searchClearBtn.length) {
      searchClearBtn.on('click', function () {
        searchInputEl.value = '';
        toggleClearButton();
        unhighlight();
        closeResults();
        searchInputEl.focus();
      });
    }

    // The topbar advertises a "/" shortcut — actually wire it up. Skip when
    // the user is already typing in any text field so "/" still works
    // normally inside inputs/textareas.
    $(document).on('keydown', function (e) {
      if (e.key !== '/' || e.metaKey || e.ctrlKey || e.altKey) return;
      var tag = (e.target.tagName || '').toLowerCase();
      if (tag === 'input' || tag === 'textarea') return;
      e.preventDefault();
      searchInputEl.focus();
    });

    $(document).on('click', function (e) {
      if (!$(e.target).closest('.topbar-search').length) closeResults();
    });
  }

  function search(event) {
    unhighlight();

    if (!searchInputEl.value) {
      closeResults();
      return;
    }

    var rawValue = searchInputEl.value;
    var results = runSearch(rawValue);
    lastResultCount = results.length;

    searchResults.addClass('visible');
    activeIndex = -1;

    if (results.length) {
      searchResults.empty();

      $.each(results, function (i, result) {
        var elem = document.getElementById(result.ref);
        if (!elem) return;

        var $elem = $(elem);
        var title = escapeHtml($elem.text());
        var crumb = breadcrumbFor(elem);
        var badge = badgeFor(elem);
        var snippet = snippetFor(result, elem, rawValue);

        var html = '<li data-nav>' +
          '<a href="#' + result.ref + '">' +
            (crumb ? '<span class="search-result-crumb">' + escapeHtml(crumb) + '</span>' : '') +
            '<span class="search-result-title">' + title + badge + '</span>' +
            (snippet ? '<span class="search-result-snippet">' + snippet + '</span>' : '') +
          '</a>' +
        '</li>';

        searchResults.append(html);
      });

      searchResults.append(
        '<li class="search-results-hint">' +
          '<span>↑↓ navegar</span><span>↵ abrir</span><span>Esc cerrar</span>' +
        '</li>'
      );

      highlight.call(searchInputEl);
    } else {
      searchResults.html(
        '<li class="search-no-results">Sin resultados para “' + escapeHtml(rawValue) + '”</li>'
      );
    }
  }

  function highlight() {
    if (this.value) content.highlight(this.value, highlightOpts);
  }

  function unhighlight() {
    content.unhighlight(highlightOpts);
  }
})();
