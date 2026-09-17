/* SKA Gebäude Service — main.js */
(function () {
  'use strict';

  /* ----------------------------------------------------------------
     Konfiguration
     ---------------------------------------------------------------- */
  var CONFIG = {
    whatsapp: '491796957453',   // internationales Format, nur Ziffern
    formEndpoint: ''            // leer = Anfrage wird über WhatsApp übergeben
  };

  /* ---------------- Mobile Navigation ---------------- */
  var burger = document.querySelector('.burger');
  var nav = document.querySelector('.nav');
  if (burger && nav) {
    burger.addEventListener('click', function () {
      var open = burger.getAttribute('aria-expanded') === 'true';
      burger.setAttribute('aria-expanded', String(!open));
      nav.classList.toggle('open', !open);
    });
    nav.addEventListener('click', function (e) {
      if (e.target.tagName === 'A') {
        burger.setAttribute('aria-expanded', 'false');
        nav.classList.remove('open');
      }
    });
  }

  /* ---------------- Scroll-Reveal ---------------- */
  var rv = document.querySelectorAll('.rv');
  if (rv.length && 'IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (es) {
      es.forEach(function (en) {
        if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); }
      });
    }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });
    rv.forEach(function (el) { io.observe(el); });
  } else {
    rv.forEach(function (el) { el.classList.add('in'); });
  }

  /* ----------------------------------------------------------------
     WhatsApp — Servicewahl
     Jede Kachel öffnet WhatsApp mit einer bereits geschriebenen
     Nachricht für genau diese Leistung.
     ---------------------------------------------------------------- */
  function waOpen(text) {
    window.open('https://wa.me/' + CONFIG.whatsapp + '?text=' + encodeURIComponent(text),
                '_blank', 'noopener');
  }

  document.querySelectorAll('[data-wa]').forEach(function (el) {
    el.addEventListener('click', function (e) {
      e.preventDefault();
      waOpen(el.getAttribute('data-wa') || 'Hallo SKA Gebäude Service, ');
    });
  });

  /* ---------------- Anfrageformular ---------------- */
  document.querySelectorAll('form[data-form]').forEach(function (form) {
    var status = form.querySelector('.fstatus');

    function say(msg, ok) {
      if (!status) { return; }
      status.textContent = msg;
      status.className = 'fstatus ' + (ok ? 'ok' : 'err');
    }

    form.addEventListener('submit', function (e) {
      e.preventDefault();
      if (!form.reportValidity()) { return; }

      var d = new FormData(form);
      var get = function (k) { return (d.get(k) || '').toString().trim(); };

      var text = [
        'Anfrage über ska-gebaeudeservice.de',
        '',
        'Name: ' + get('name'),
        'Telefon: ' + get('telefon'),
        get('email') ? 'E-Mail: ' + get('email') : '',
        get('ort') ? 'Ort: ' + get('ort') : '',
        get('leistung') ? 'Leistung: ' + get('leistung') : '',
        get('nachricht') ? 'Nachricht: ' + get('nachricht') : ''
      ].filter(Boolean).join('\n');

      if (CONFIG.formEndpoint) {
        var btn = form.querySelector('button[type="submit"]');
        if (btn) { btn.disabled = true; btn.dataset.label = btn.textContent; btn.textContent = 'Wird gesendet …'; }
        fetch(CONFIG.formEndpoint, { method: 'POST', headers: { Accept: 'application/json' }, body: d })
          .then(function (r) {
            if (!r.ok) { throw new Error('HTTP ' + r.status); }
            form.reset();
            say('Vielen Dank! Ihre Anfrage ist eingegangen — wir melden uns schnellstmöglich.', true);
          })
          .catch(function () { say('Senden fehlgeschlagen. Bitte rufen Sie an: 0179 6957453', false); })
          .finally(function () { if (btn) { btn.disabled = false; btn.textContent = btn.dataset.label; } });
        return;
      }

      waOpen(text);
      say('Ihre Anfrage wurde in WhatsApp übernommen — dort noch auf „Senden“ tippen. Lieber telefonisch? 0179 6957453', true);
    });
  });

  /* ---------------- Bürozeiten-Status ---------------- */
  // Büro: Mo–Fr 08:00–18:00, Sa 08:00–14:30. Notdienst läuft davon unabhängig.
  var HOURS = { 1: [8, 18], 2: [8, 18], 3: [8, 18], 4: [8, 18], 5: [8, 18], 6: [8, 14.5], 0: null };
  document.querySelectorAll('[data-office]').forEach(function (el) {
    var now = new Date();
    var today = HOURS[now.getDay()];
    var t = now.getHours() + now.getMinutes() / 60;
    var open = today && t >= today[0] && t < today[1];
    el.textContent = open ? 'Büro jetzt besetzt' : 'Büro geschlossen — Notdienst erreichbar';
  });

  /* ---------------- Jahr ---------------- */
  document.querySelectorAll('[data-year]').forEach(function (el) {
    el.textContent = String(new Date().getFullYear());
  });
})();
