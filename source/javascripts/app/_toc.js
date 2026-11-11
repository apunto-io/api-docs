// Sidebar: highlights the section being read, opens its group of endpoints,
// keeps the active link in view and mirrors it in the URL hash.
// Deep links use native anchors; headings carry scroll-margin-top so they land
// below the fixed top bar.
;(function () {
  'use strict';

  var headings = [];
  var links = {};
  var currentId = null;
  var userScrolled = false;
  var ticking = false;
  var baseTitle = document.title;

  function topOffset() {
    var bar = document.querySelector('.topbar');
    return (bar ? bar.offsetHeight : 60) + 24;
  }

  function collect() {
    headings = Array.prototype.slice.call(document.querySelectorAll('.content > h1, .content > h2'));
    links = {};
    Array.prototype.forEach.call(document.querySelectorAll('#toc a.toc-link'), function (link) {
      links[link.getAttribute('data-target')] = link;
    });
  }

  function headingAtTop() {
    var offset = topOffset();
    var current = headings[0];
    for (var i = 0; i < headings.length; i++) {
      if (headings[i].getBoundingClientRect().top - offset <= 1) {
        current = headings[i];
      } else {
        break;
      }
    }
    // At the very bottom the last heading may never reach the top.
    if (window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 2) {
      current = headings[headings.length - 1];
    }
    return current;
  }

  function sectionIdFor(heading) {
    if (!heading) return null;
    if (heading.tagName === 'H1') return heading.id;
    var node = heading.previousElementSibling;
    while (node && node.tagName !== 'H1') node = node.previousElementSibling;
    return node ? node.id : null;
  }

  function keepVisible(link) {
    var sidebar = document.getElementById('sidebar');
    if (!sidebar || !link) return;
    var linkBox = link.getBoundingClientRect();
    var barBox = sidebar.getBoundingClientRect();
    if (linkBox.top < barBox.top + 40 || linkBox.bottom > barBox.bottom - 40) {
      sidebar.scrollTop += linkBox.top - barBox.top - barBox.height / 3;
    }
  }

  function activate(heading) {
    if (!heading || heading.id === currentId) return;
    currentId = heading.id;

    Array.prototype.forEach.call(document.querySelectorAll('#toc .active'), function (el) {
      el.classList.remove('active');
    });
    Array.prototype.forEach.call(document.querySelectorAll('#toc .nav-item.is-open'), function (el) {
      el.classList.remove('is-open');
    });

    var sectionId = sectionIdFor(heading);
    var sectionItem = document.querySelector('#toc .nav-item[data-section="' + sectionId + '"]');
    if (sectionItem) sectionItem.classList.add('is-open');

    var link = links[heading.id];
    if (link) {
      link.classList.add('active');
      keepVisible(link);
    }

    var label = heading.textContent.trim();
    document.title = label ? label + ' · ' + baseTitle : baseTitle;
    if (userScrolled && window.history && window.history.replaceState) {
      window.history.replaceState(null, '', '#' + heading.id);
    }
  }

  function onScroll() {
    userScrolled = true;
    if (ticking) return;
    ticking = true;
    window.requestAnimationFrame(function () {
      ticking = false;
      activate(headingAtTop());
    });
  }

  // Anchors of the previous version of these docs, so shared links still land
  // on the right place. Exact ids first, then a keyword fallback to the section.
  var LEGACY_IDS = {
    'informacion-general': 'introduccion',
    'principios-rest-y-formato-de-datos': 'convenciones',
    'identificadores-id-numerico-y-codigos-_code': 'codigos-en-lugar-de-ids',
    'alcance-de-la-cuenta-y-permisos': 'permisos-y-alcance',
    'sincronizacion-incremental-updated_since-deleted_since': 'sincronizacion-incremental',
    'sincronizacion-incremental-updated-since-deleted-since': 'sincronizacion-incremental',
    'como-empezar-checklist': 'guia-rapida',
    'crear-un-token-de-api': 'tokens-de-api',
    'usar-el-token-de-api': 'tokens-de-api',
    'login-autenticacion-alternativa': 'iniciar-sesion-con-correo-y-contrasena',
    'usuario-y-cuenta-del-token': 'usuario-del-token',
    'formato-del-error': 'formato',
    'codigos-de-estado-http': 'codigos',
    'operaciones': 'folios-operativos',
    'centro-de-costos-costcenter': 'centro-de-costos',
    'comentarios-messages': 'comentarios',
    'tareas-to-dos': 'tareas',
    'documentos-carpetas-y-archivos': 'documentos-y-archivos'
  };

  var LEGACY_KEYWORDS = [
    [/sincronizacion|updated-since|deleted-since/, 'sincronizacion-incremental'],
    [/paginacion/, 'paginacion'],
    [/autenticacion|token|login/, 'autenticacion'],
    [/error/, 'errores'],
    [/permiso|alcance/, 'permisos-y-alcance'],
    [/quoterequest|quote-request|solicitud|columnas-del-flujo|motivos-de-(ganado|perdido)/, 'solicitudes-comerciales'],
    [/quote|cotizacion/, 'cotizaciones'],
    [/lead|prospecto/, 'prospectos'],
    [/opportunity|oportunidad/, 'oportunidades'],
    [/costcenter|cost-center|centro-de-costos|lineas/, 'centro-de-costos'],
    [/comentario|message/, 'comentarios'],
    [/tarea|todo|to-do/, 'tareas'],
    [/folder|attachment|archivo|carpeta|documento/, 'documentos-y-archivos'],
    [/bill|factura-de-proveedor|facturas-de-proveedor/, 'facturas-de-proveedor'],
    [/invoice|factura/, 'facturas'],
    [/servicio|service/, 'servicios'],
    [/operacion|operation|folio/, 'folios-operativos'],
    [/address|direccion|domicilio/, 'direcciones'],
    [/contact|contacto/, 'contactos'],
    [/motivo|cancellation|cancelacion/, 'catalogos']
  ];

  function resolveTarget(id) {
    if (!id) return null;
    var el = document.getElementById(id);
    if (el) return el;
    var key = id.toLowerCase().replace(/_/g, '-');
    var stripped = key.replace(/-(get|post|patch|put|delete)$/, '');
    var candidates = [LEGACY_IDS[id], LEGACY_IDS[key], LEGACY_IDS[stripped], stripped];
    for (var i = 0; i < candidates.length; i++) {
      el = candidates[i] && document.getElementById(candidates[i]);
      if (el) return el;
    }
    for (var j = 0; j < LEGACY_KEYWORDS.length; j++) {
      if (LEGACY_KEYWORDS[j][0].test(stripped)) return document.getElementById(LEGACY_KEYWORDS[j][1]);
    }
    return null;
  }

  function jumpToHash() {
    var id = decodeURIComponent(window.location.hash.replace(/^#/, ''));
    var target = resolveTarget(id);
    if (!target) return;
    if (target.id !== id && window.history.replaceState) {
      window.history.replaceState(null, '', '#' + target.id);
    }
    target.scrollIntoView();
    activate(target);
  }

  function setupMobileNav() {
    var toggle = document.getElementById('nav-toggle');
    var overlay = document.getElementById('nav-overlay');
    function setOpen(open) {
      document.body.classList.toggle('nav-open', open);
      if (toggle) toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      if (overlay) overlay.hidden = !open;
    }
    if (toggle) toggle.addEventListener('click', function () {
      setOpen(!document.body.classList.contains('nav-open'));
    });
    if (overlay) overlay.addEventListener('click', function () { setOpen(false); });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') setOpen(false);
    });
    Array.prototype.forEach.call(document.querySelectorAll('#toc a'), function (link) {
      link.addEventListener('click', function () { setOpen(false); });
    });
  }

  window.setupToc = function () {
    collect();
    setupMobileNav();
    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('hashchange', function () {
      var id = decodeURIComponent(window.location.hash.slice(1));
      if (document.getElementById(id)) {
        activate(document.getElementById(id));
      } else {
        jumpToHash();
      }
    });
    activate(headingAtTop());

    // Fonts and code blocks change heights after first paint; land on the
    // requested anchor once layout is final.
    var settle = function () { jumpToHash(); };
    if (document.fonts && document.fonts.ready) {
      document.fonts.ready.then(settle);
    } else {
      window.addEventListener('load', settle);
    }
  };

  window.refreshToc = function () {
    collect();
    activate(headingAtTop());
  };
})();
