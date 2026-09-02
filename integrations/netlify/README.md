# Netlify

Hosting do Flutter Web (producao).

## Configuracao

| Campo | Valor |
|-------|-------|
| Site name | moonlit-pothos-c56cd4 |
| Production URL | `https://moonlit-pothos-c56cd4.netlify.app` |
| Deploy method | Netlify CLI (`netlify deploy --prod`) |
| Build | `flutter build web --release` |
| Publish dir | `build/web/` |

## Ficheiros relacionados

| Ficheiro | Descricao |
|----------|-----------|
| `lib/config/constants.dart` | `siteUrl` |
| `build/web/` | Output do Flutter Web (deployed) |
| `.netlify/` | Config local do Netlify CLI |

## SPA redirects

O Netlify precisa de redirecionar todas as rotas para `index.html` para que o GoRouter funcione. Isto e tratado automaticamente pelo Netlify CLI quando faz deploy de uma SPA.

## Deploy manual

```bash
flutter build web --release
cd build/web
netlify deploy --prod --dir=. --site moonlit-pothos-c56cd4 --auth <TOKEN>
```

## Notas

- Nao ha custom domain configurado
- SSL automatico via Netlify
- Site temporario `gleeful-bunny-9bfac6.netlify.app` foi criado por engano (nao usar)
