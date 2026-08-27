# Notas do projeto PetCare

## Ritual de screenshots (por módulo)

A cada módulo finalizado:

1. Compilar app para o emulador: `flutter build apk` ou `flutter run -d <emulador>`
2. Navegar manualmente pelas 3 telas principais do módulo
3. Executar `powershell -File tool\screenshot.ps1`
4. Para cada tela, inserir nome descritivo (ex: `modulo_02_pets_list`)
5. Apresentar as imagens antes de continuar

## Screenshots headless (Chrome)

- Telas públicas (login, QR) podem ser capturadas com Chrome headless
- Telas autenticadas requerem emulador Android ou dispositivo físico, porque a sessão Supabase precisa de login real e a app carrega dados dinâmicos
- Script auxiliar: `tool\screenshot.ps1` (usa `adb shell screencap`)

## Permissões Supabase (allow-list redirects)

Para testes locais e deploy Cloudflare, as URLs permitidas para auth estão configuradas como:
- `http://127.0.0.1:8080/**`
- `http://localhost:8080/**`
- `https://*.lhr.life/**`
- `https://petsaas.pages.dev/**`

## Configuração Firebase Web

- `lib/main.dart` contém as opções Web do Firebase
- Não é feito via `flutterfire configure` para evitar dependência do CLI
