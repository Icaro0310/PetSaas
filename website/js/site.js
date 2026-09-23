// PetCare site — nav mobile + scroll reveal (respeita prefers-reduced-motion)
(function () {
  "use strict";

  var toggle = document.querySelector(".nav-toggle");
  var overlay = document.querySelector(".nav-overlay");
  var closeBtn = document.querySelector(".nav-overlay__close");

  var menuTrigger = null;

  function setMenu(open) {
    if (!overlay || !toggle) return;
    if (open) menuTrigger = document.activeElement;
    overlay.classList.toggle("is-open", open);
    toggle.setAttribute("aria-expanded", String(open));
    document.body.style.overflow = open ? "hidden" : "";
    if (open && closeBtn) closeBtn.focus();
    if (!open && menuTrigger) menuTrigger.focus();
  }

  if (toggle && overlay) {
    toggle.addEventListener("click", function () { setMenu(true); });
    if (closeBtn) closeBtn.addEventListener("click", function () { setMenu(false); });
    overlay.addEventListener("click", function (e) {
      if (e.target.tagName === "A") setMenu(false);
    });
    document.addEventListener("keydown", function (e) {
      if (!overlay.classList.contains("is-open")) return;
      if (e.key === "Escape") {
        setMenu(false);
        return;
      }
      if (e.key !== "Tab") return;
      var focusable = overlay.querySelectorAll('a[href], button:not([disabled])');
      if (!focusable.length) return;
      var first = focusable[0];
      var last = focusable[focusable.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    });
  }

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var items = document.querySelectorAll(".reveal");

  if (reduceMotion || !("IntersectionObserver" in window)) {
    items.forEach(function (el) { el.classList.add("is-visible"); });
    return;
  }

  var observer = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12, rootMargin: "0px 0px -8% 0px" });

  items.forEach(function (el) { observer.observe(el); });
})();

// Newsletter / waitlist -> Edge Function `subscribe` (Supabase)
(function () {
  "use strict";

  var SUBSCRIBE_URL = "https://dotplnbakltelacsxvjz.supabase.co/functions/v1/subscribe";

  document.querySelectorAll("[data-subscribe]").forEach(function (form) {
    var input = form.querySelector('input[type="email"]');
    var button = form.querySelector('button[type="submit"]');
    var msg = form.parentElement.querySelector(".subscribe__msg");
    if (!input || !button || !msg) return;

    form.addEventListener("submit", function (e) {
      e.preventDefault();
      var email = input.value.trim();
      input.setAttribute("aria-invalid", "false");
      msg.className = "subscribe__msg";
      msg.textContent = "";

      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        input.setAttribute("aria-invalid", "true");
        msg.classList.add("is-error");
        msg.textContent = "Introduza um endereço de email válido.";
        input.focus();
        return;
      }

      button.disabled = true;
      var label = button.textContent;
      button.textContent = "A submeter…";

      fetch(SUBSCRIBE_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: email, source: "website" })
      })
        .then(function (res) {
          if (res.ok) {
            msg.classList.add("is-ok");
            msg.textContent = "A sua subscrição foi registada.";
            form.reset();
            return;
          }
          return res.json().catch(function () { return {}; }).then(function (body) {
            throw new Error(body.error || "Erro ao subscrever. Tente novamente.");
          });
        })
        .catch(function () {
          msg.classList.add("is-error");
          msg.textContent = "Não foi possível registar a subscrição. Tente novamente mais tarde.";
        })
        .finally(function () {
          button.disabled = false;
          button.textContent = label;
        });
    });
  });
})();
