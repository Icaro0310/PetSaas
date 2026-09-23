# GitHub Pages

Hosting do website institucional **e** da app Flutter Web (producao). Gratuito.

## Configuracao

| Campo | Valor |
|-------|-------|
| Branch de deploy | `gh-pages` |
| Site (raiz) | `https://icaro0310.github.io/PetSaas/` |
| App Flutter | `https://icaro0310.github.io/PetSaas/app/` |
| Build site | estatico (website/) |
| Build app | `flutter build web --base-href=/PetSaas/app/` |
| Publish | copiar `website/` -> raiz do gh-pages e `build/web/` -> `app/` |

## Estrutura no branch gh-pages

```
/              <- website/ (index.html, pricing, privacy, terms, 404.html)
/app/          <- build/web/ (app Flutter compilada)
```

## SPA fallback (rotas limpas)

O GitHub Pages nao tem fallback nativo. Solucao implementada:

1. `/404.html` (raiz): se o path comeca com `/PetSaas/app`, redireciona
   para `/PetSaas/app/?p=<path+query+hash>`
2. `web/index.html` (app): le `?p=` e faz `history.replaceState` para a
   URL limpa antes do bootstrap do Flutter (`usePathUrlStrategy`)

Resultado: `/PetSaas/app/login`, `/PetSaas/app/p/<uuid>` (QR publico) e
`/PetSaas/app/join?token=...` funcionam em acesso direto.

## Ficheiros relacionados

| Ficheiro | Descricao |
|----------|-----------|
| `website/` | Fonte do site (deploy = raiz do gh-pages) |
| `website/404.html` | Fallback SPA + pagina de erro |
| `web/index.html` | Decoder `?p=` + base-href |
| `build/web/` | Output do Flutter Web (vai para `app/`) |
| `lib/config/constants.dart` | `siteUrl` |
| `lib/core/services/deep_link_service.dart` | `webBaseUrl` (QR codes e convites) |

## Limites do GitHub Pages

- 100 GB/mes de banda (soft limit), site < 1 GB
- Apenas conteudo estatico (backend = Supabase Edge Functions)

## Notas

- SSL automatico via GitHub
- Custom domain suportado: adicionar `CNAME` ao gh-pages + DNS
- O site Netlify antigo (`moonlit-pothos-c56cd4.netlify.app`) pode ser
  apagado no dashboard do Netlify; QR codes ja gerados com esse URL
  deixam de funcionar quando o site for removido
