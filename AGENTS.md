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

## Metodologia de trabalho (Devin Agent)

Para cada tarefa, executar o ciclo obrigatorio:

1. **Planejar**: Escrever plano em `/tmp/plano_petcare.md` antes de codar. Incluir:
   - Ficheiros a modificar
   - Servicos Supabase chamados
   - Edge Functions criadas/alteradas
   - Impacto em RLS e seguranca
   - Mostrar o plano antes de implementar

2. **Revisar plano** (Arquiteto Senior):
   - Tem IDOR? (rotas filtram por user_id?)
   - Tem segredo no frontend? (service_role exposto?)
   - Esta escalavel? (queries N+1 no Supabase?)

3. **Implementar** (commits atomicos):
   - Cada commit = UMA responsabilidade
   - NUNCA commit gigante com 10 ficheiros nao relacionados

4. **Testar**:
   - Flutter: `flutter test` ou criar testes unitarios
   - Edge Functions: `supabase functions serve` + curl
   - RLS: curl com ANON_KEY para garantir acesso bloqueado

5. **Revisar PR** (auto-review):
   - Apontar 1 defeito
   - Apontar 1 acerto
   - Corrigir defeito antes de prosseguir

6. **Entregar** com resumo:
   ```
   [PR] - #XX - titulo
   [ARQUIVOS] - lista
   [TESTES] - resultados
   [PENDENTE] - acoes manuais
   ```

## Graphify (memoria em grafo)

- Instalado via `pipx install graphifyy`
- Indexado com `graphify extract . --code-only` (754 nodes, 1073 edges)
- Antes de cada tarefa: `graphify query "estrutura do modulo X"`
- Apos alterar ficheiros: `graphify update .`
- Output em `graphify-out/` (gitignored)
- PATH: `$env:PATH = "$env:USERPROFILE\.local\bin;$env:APPDATA\Python\Python311\Scripts;$env:PATH"`

## Cybersecurity Skills

- Repo: `C:\tmp\sec_skills` (817 skills, Apache-2.0)
- Skills relevantes para PetCare:
  - `exploiting-idor-vulnerabilities` - verificar rotas com :id
  - `exploiting-sql-injection-vulnerabilities` - verificar RPC e RLS
  - `testing-api-security-with-owasp-top-10` - verificar Edge Functions
  - `testing-for-xss-vulnerabilities` - verificar pagina publica QR

## Checklist de seguranca (obrigatorio para cada PR)

- [ ] RLS ativa para a tabela alterada
- [ ] Nenhum console.log de dados sensiveis em Edge Functions
- [ ] Nenhum print() de tokens JWT no Flutter
- [ ] Zod validation em TODAS as Edge Functions
- [ ] Rate limiting configurado (ou planejado)

## Proibicoes totais

- NAO instale DeerFlow (conflita com Devin)
- NAO use /plan ou /review (usar fluxo acima)
- NAO instale pacotes NPM "ecc-universal" sem verificar fonte
- NAO commite google-services.json ou GoogleService-Info.plist
- NAO altere migrations sem testar localmente (`supabase db push --dry-run`)
- NAO use `flutter pub add` sem verificar licenca e seguranca no pub.dev
- NAO instale de fontes desconhecidas (`curl | bash`)
- NAO use service_role no cliente Flutter

## Regras por modulo

| Modulo | Regra |
|--------|-------|
| auth/ | NUNCA armazenar tokens em shared_preferences sem criptografia (usar flutter_secure_storage) |
| pets/ | Upload de foto usa bucket pet_photos com politica publica de leitura |
| medications/ | Sempre registar given_by no dose_logs (user_id ou caregiver_id) |
| qr_code/ | URL publica NUNCA contem dados sensiveis (usar UUIDs) |
| caregivers/ | Token de convite expira em 7 dias |
| notifications/ | Locais apenas no Android; push via FCM para ambos |
| profile/ | Paywall verificado no servidor (Edge Function), NUNCA apenas no cliente |

## Edge Functions

| Funcao | Seguranca |
|--------|-----------|
| notify-pet-found | Zod validation + sem auth (publica) |
| notify-dose-missed | Chamada apenas pelo cron |
| clerk-webhook | Service_role, filtra por evento |
| health | Sem input, apenas status |
| delete-user-account | Requer auth + IDOR protection (jwtSub === user_id) |

## CI/CD

- GitHub Actions: `.github/workflows/supabase-deploy.yml` deploy automatico
- Netlify: `netlify deploy --prod --dir=build/web`
- NUNCA fazer deploy sem rodar `flutter test` e testar Edge Functions

## Versoes verificadas (02 Set 2026)

| Tool | Versao | Status |
|------|--------|--------|
| Flutter | 3.47.1 | OK |
| Node | v24.15.0 | OK |
| Python | 3.11.9 | OK |
| Deno | NAO instalado (Supabase CLI faz deploy remoto) |
