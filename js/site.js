// PetCare site — nav mobile + scroll reveal (respeita prefers-reduced-motion)
(function () {
  "use strict";

  var toggle = document.querySelector(".nav-toggle");
  var overlay = document.querySelector(".nav-overlay");
  var closeBtn = document.querySelector(".nav-overlay__close");

  function setMenu(open) {
    if (!overlay || !toggle) return;
    overlay.classList.toggle("is-open", open);
    toggle.setAttribute("aria-expanded", String(open));
    document.body.style.overflow = open ? "hidden" : "";
    if (open && closeBtn) closeBtn.focus();
  }

  if (toggle && overlay) {
    toggle.addEventListener("click", function () { setMenu(true); });
    if (closeBtn) closeBtn.addEventListener("click", function () { setMenu(false); });
    overlay.addEventListener("click", function (e) {
      if (e.target.tagName === "A") setMenu(false);
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") setMenu(false);
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
        msg.textContent = "Introduza um email valido.";
        input.focus();
        return;
      }

      button.disabled = true;
      var label = button.textContent;
      button.textContent = "A subscrever...";

      fetch(SUBSCRIBE_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: email, source: "website" })
      })
        .then(function (res) {
          if (res.ok) {
            msg.classList.add("is-ok");
            msg.textContent = "Subscricao confirmada. Enviamos um email de boas-vindas - verifique a sua caixa de entrada!";
            form.reset();
            return;
          }
          return res.json().catch(function () { return {}; }).then(function (body) {
            throw new Error(body.error || "Erro ao subscrever. Tente novamente.");
          });
        })
        .catch(function () {
          msg.classList.add("is-error");
          msg.textContent = "Nao foi possivel subscrever. Tente novamente mais tarde.";
        })
        .finally(function () {
          button.disabled = false;
          button.textContent = label;
        });
    });
  });
})();
