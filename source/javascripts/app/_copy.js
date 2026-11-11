// Copy buttons for example blocks and endpoint paths.
;(function () {
  'use strict';

  var COPY_ICON = '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a2 2 0 0 1 2-2h10"/></svg>';
  var DONE_ICON = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12l5 5L20 7"/></svg>';

  function copyText(text) {
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      var area = document.createElement('textarea');
      area.value = text;
      area.setAttribute('readonly', '');
      area.style.position = 'fixed';
      area.style.opacity = '0';
      document.body.appendChild(area);
      area.select();
      try {
        document.execCommand('copy') ? resolve() : reject(new Error('copy failed'));
      } catch (err) {
        reject(err);
      } finally {
        document.body.removeChild(area);
      }
    });
  }

  function flash(button, label) {
    var original = button.innerHTML;
    button.classList.add('copied');
    button.innerHTML = DONE_ICON + (label ? '<span>' + label + '</span>' : '');
    setTimeout(function () {
      button.classList.remove('copied');
      button.innerHTML = original;
    }, 1600);
  }

  function addBlockButton(block) {
    var pre = block.querySelector('pre');
    if (!pre || block.querySelector('.copy-button')) return;
    var button = document.createElement('button');
    button.type = 'button';
    button.className = 'copy-button';
    button.setAttribute('aria-label', 'Copiar código');
    button.innerHTML = COPY_ICON + '<span>Copiar</span>';
    button.addEventListener('click', function () {
      copyText(pre.innerText.replace(/\n$/, '')).then(function () { flash(button, 'Copiado'); });
    });
    block.appendChild(button);
  }

  function addEndpointButton(endpoint) {
    var path = endpoint.querySelector('code');
    if (!path || endpoint.querySelector('.endpoint-copy')) return;
    var button = document.createElement('button');
    button.type = 'button';
    button.className = 'endpoint-copy';
    button.setAttribute('aria-label', 'Copiar ruta');
    button.title = 'Copiar ruta';
    button.innerHTML = COPY_ICON;
    button.addEventListener('click', function () {
      copyText(path.textContent.trim()).then(function () { flash(button); });
    });
    endpoint.appendChild(button);
  }

  window.setupCodeCopy = function () {
    Array.prototype.forEach.call(document.querySelectorAll('.content > div.highlight'), addBlockButton);
    Array.prototype.forEach.call(document.querySelectorAll('.content > .endpoint'), addEndpointButton);
  };
})();
