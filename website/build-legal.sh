#!/usr/bin/env bash
# Gera privacy.html e terms.html do website a partir do conteudo de web/
set -euo pipefail
cd "$(dirname "$0")"

gen() {
  local src="../web/$1" out="$2" title="$3" desc="$4" canon="$5"
  local body
  body=$(sed -n '/<body>/,/<\/body>/p' "$src" | sed '1d;$d')

  cat > "$out" <<EOF
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <meta name="description" content="${desc}">
  <link rel="canonical" href="${canon}">
  <meta name="robots" content="index,follow">
  <link rel="icon" type="image/png" href="assets/favicon.png">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Poppins:wght@600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/site.css">
</head>
<body>

  <header class="site-nav">
    <div class="container site-nav__inner">
      <a class="brand" href="./">
        <span class="brand__mark" aria-hidden="true">
          <svg viewBox="0 0 24 24" fill="#fff"><path d="M12 13.2c-2.6 0-5.4 2.1-5.4 4.5 0 1.5 1 2.5 2.5 2.5 1 0 1.8-.5 2.9-.5s1.9.5 2.9.5c1.5 0 2.5-1 2.5-2.5 0-2.4-2.8-4.5-5.4-4.5zM6.4 8.6c-1.1-.3-2.3.7-2.6 2.2-.3 1.4.3 2.8 1.4 3.1 1.1.3 2.3-.7 2.6-2.2.3-1.4-.3-2.8-1.4-3.1zm11.2 0c-1.1.3-1.7 1.7-1.4 3.1.3 1.5 1.5 2.5 2.6 2.2 1.1-.3 1.7-1.7 1.4-3.1-.3-1.5-1.5-2.5-2.6-2.2zM9.3 3.6c-1.2.2-2 1.6-1.8 3 .2 1.5 1.3 2.5 2.5 2.3 1.2-.2 2-1.6 1.8-3-.2-1.5-1.3-2.5-2.5-2.3zm5.4 0c-1.2-.2-2.3.8-2.5 2.3-.2 1.4.6 2.8 1.8 3 1.2.2 2.3-.8 2.5-2.3.2-1.4-.6-2.8-1.8-3z"/></svg>
        </span>
        PetCare
      </a>
      <nav class="site-nav__links" aria-label="Principal">
        <a class="nav-link" href="./">Inicio</a>
        <a class="nav-link" href="pricing.html">Precos</a>
        <a class="btn btn--primary" href="https://moonlit-pothos-c56cd4.netlify.app" target="_blank" rel="noopener noreferrer">Abrir a app</a>
      </nav>
      <button class="nav-toggle" aria-expanded="false" aria-controls="navOverlay">Menu</button>
    </div>
  </header>

  <div class="nav-overlay" id="navOverlay" role="dialog" aria-modal="true" aria-label="Menu">
    <button class="nav-overlay__close" aria-label="Fechar menu">Fechar</button>
    <a href="./">Inicio</a>
    <a href="pricing.html">Precos</a>
    <a href="privacy.html">Privacidade</a>
    <a href="terms.html">Termos</a>
    <a class="btn btn--primary" href="https://moonlit-pothos-c56cd4.netlify.app" target="_blank" rel="noopener noreferrer">Abrir a app</a>
  </div>

  <main class="section">
    <div class="container legal">
${body}
    </div>
  </main>

  <footer class="site-footer">
    <div class="container">
      <div class="site-footer__row">
        <a class="brand" href="./">
          <span class="brand__mark" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="#fff"><path d="M12 13.2c-2.6 0-5.4 2.1-5.4 4.5 0 1.5 1 2.5 2.5 2.5 1 0 1.8-.5 2.9-.5s1.9.5 2.9.5c1.5 0 2.5-1 2.5-2.5 0-2.4-2.8-4.5-5.4-4.5zM6.4 8.6c-1.1-.3-2.3.7-2.6 2.2-.3 1.4.3 2.8 1.4 3.1 1.1.3 2.3-.7 2.6-2.2.3-1.4-.3-2.8-1.4-3.1zm11.2 0c-1.1.3-1.7 1.7-1.4 3.1.3 1.5 1.5 2.5 2.6 2.2 1.1-.3 1.7-1.7 1.4-3.1-.3-1.5-1.5-2.5-2.6-2.2zM9.3 3.6c-1.2.2-2 1.6-1.8 3 .2 1.5 1.3 2.5 2.5 2.3 1.2-.2 2-1.6 1.8-3-.2-1.5-1.3-2.5-2.5-2.3zm5.4 0c-1.2-.2-2.3.8-2.5 2.3-.2 1.4.6 2.8 1.8 3 1.2.2 2.3-.8 2.5-2.3.2-1.4-.6-2.8-1.8-3z"/></svg>
          </span>
          PetCare
        </a>
        <nav class="site-footer__links" aria-label="Rodape">
          <a href="./">Sobre</a>
          <a href="pricing.html">Precos</a>
          <a href="privacy.html">Politica de Privacidade</a>
          <a href="terms.html">Termos de Uso</a>
          <a href="mailto:legal@petcare.com">Contacto</a>
        </nav>
      </div>
      <p class="site-footer__copy">&copy; 2026 PetCare. Todos os direitos reservados.</p>
    </div>
  </footer>

  <script src="js/site.js" defer></script>
</body>
</html>
EOF
  echo "gerado: $out"
}

gen "privacy.html" "privacy.html" \
  "Politica de Privacidade - PetCare" \
  "Como o PetCare recolhe, usa e protege os seus dados. Conformidade LGPD, CCPA e GDPR." \
  "https://icaro0310.github.io/PetSaas/privacy.html"

gen "terms.html" "terms.html" \
  "Termos de Uso - PetCare" \
  "Condicoes de utilizacao do PetCare. Planos, cancelamento, DMCA e arbitragem." \
  "https://icaro0310.github.io/PetSaas/terms.html"
