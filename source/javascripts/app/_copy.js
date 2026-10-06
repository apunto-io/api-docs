function normalizeCodeText(text) {
  return text.replace(/\n$/, '');
}

function codeTextFromPre($pre) {
  var $code = $pre.children('code').first();
  var raw = $code.length ? $code.text() : $pre.text();
  return normalizeCodeText(raw);
}

function copyWithExecCommand(text) {
  return new Promise(function(resolve, reject) {
    var el = document.createElement('textarea');
    el.value = text;
    el.setAttribute('readonly', '');
    el.style.position = 'fixed';
    el.style.top = '0';
    el.style.left = '0';
    el.style.opacity = '0';
    document.body.appendChild(el);
    el.focus();
    el.select();
    el.setSelectionRange(0, text.length);

    try {
      var ok = document.execCommand('copy');
      document.body.removeChild(el);
      if (ok) {
        resolve();
      } else {
        reject(new Error('Copy command was unsuccessful'));
      }
    } catch (err) {
      document.body.removeChild(el);
      reject(err);
    }
  });
}

function copyText(text) {
  if (!text) {
    return Promise.reject(new Error('Nothing to copy'));
  }

  if (navigator.clipboard && window.isSecureContext) {
    return navigator.clipboard.writeText(text).catch(function() {
      return copyWithExecCommand(text);
    });
  }

  return copyWithExecCommand(text);
}

function setupCodeCopy() {
  $('pre.highlight').each(function() {
    var $pre = $(this);
    if ($pre.children('.copy-clipboard').length) {
      return;
    }

    var $button = $(
      '<button type="button" class="copy-clipboard" aria-label="Copiar al portapapeles">' +
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" aria-hidden="true">' +
          '<path d="M18 6v-6h-18v18h6v6h18v-18h-6zm-12 10h-4v-14h14v4h-10v10zm16 6h-14v-14h14v14z"></path>' +
        '</svg>' +
      '</button>'
    );

    $pre.append($button);

    $button.on('click', function(event) {
      event.preventDefault();
      event.stopPropagation();
      var text = codeTextFromPre($pre);
      copyText(text)
        .then(function() {
          $button.addClass('copy-clipboard--copied');
          window.setTimeout(function() {
            $button.removeClass('copy-clipboard--copied');
          }, 1500);
        })
        .catch(function() {
          window.alert('No se pudo copiar al portapapeles.');
        });
    });
  });
}
