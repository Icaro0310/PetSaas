# PROMPT ADAPTADO - Site Institucional PetCare no Framer

> Prompt completo e adaptado ao estado real do projeto PetCare.
> Data: 02 de setembro de 2026
> Versao: 1.0

---

## 0. CONTEXTO REAL DO PROJETO (NAO INVENTAR)

Antes de construir o site no Framer, leia o estado real do projeto:

### 0.1 Dominios e URLs

| Ambiente | URL atual | URL final pretendida |
|----------|-----------|---------------------|
| App Flutter Web (Netlify) | `https://moonlit-pothos-c56cd4.netlify.app` | `https://app.petcare.com` |
| Site institucional (Framer) | (a criar) | `https://www.petcare.com` |
| Supabase API | `https://dotplnbakltelacsxvjz.supabase.co` | (igual) |
| Clerk Auth | `https://climbing-burro-4910.clerk.accounts.dev` | (igual) |

### 0.2 Rotas publicas do Flutter Web (CRITICO para QR Codes)

O app Flutter Web tem estas rotas publicas (sem login):

- `/p/<uuid>` - Pagina publica do pet (via QR Code)
- `/join?token=<token>` - Aceitar convite de cuidador
- `/scan` - Scanner de QR Code

**IMPORTANTE:** Estas rotas vivem no subdominio `app.petcare.com` (Netlify), NAO no Framer.
O Framer (www.petcare.com) NAO deve tentar servir estas rotas.

### 0.3 Bug atual a corrigir no Flutter

O ficheiro `lib/core/services/deep_link_service.dart` atualmente gera URLs com:
- Dominio errado: `https://petcare-micro-saas.web.app` (legacy Firebase)
- Path errado: `/pet/<uuid>` em vez de `/p/<uuid>`

**Correcao necessaria** (tarefa separada do site Framer):
```dart
// ANTES (errado):
static const String webBaseUrl = 'https://petcare-micro-saas.web.app';
static String publicPetUrl(String qrCodeUuid) =>
    '$webBaseUrl/pet/$qrCodeUuid';

// DEPOIS (correto):
static const String webBaseUrl = 'https://app.petcare.com';
static String publicPetUrl(String qrCodeUuid) =>
    '$webBaseUrl/p/$/$qrCodeUuid';
```

### 0.4 Paginas legais existentes

Ja existem e estao deployadas no Netlify (mas devem ser movidas para o Framer):

- `https://moonlit-pothos-c56cd4.netlify.app/privacy.html` - Politica de Privacidade (LGPD + CCPA + GDPR)
- `https://moonlit-pothos-c56cd4.netlify.app/terms.html` - Termos de Servico (DMCA + arbitragem)

Conteudo completo em:
- `docs/legal/politica-de-privacidade.txt`
- `docs/legal/termos-de-servico.txt`

### 0.5 Precos reais (validados no codigo)

| Plano | Preco | Limites |
|-------|-------|---------|
| Free | EUR 0/mes | 1 pet, 1 cuidador, historico 7 dias |
| Premium | EUR 1,99/mes | Pets ilimitados, cuidadores ilimitados, historico completo |
| Trial | 14 dias gratis | Acesso completo Premium |

---

## 1. VISAO GERAL DO PROJETO

**Nome do produto:** PetCare

**URLs finais:**
- `www.petcare.com` - Site institucional (Framer)
- `app.petcare.com` - App Flutter Web funcional (Netlify)

**Objetivo do site:**
Landing page institucional para converter visitantes em utilizadores da aplicacao SaaS. O site deve transmitir confianca, cuidado e modernidade, mostrando como a app resolve dois problemas centrais:

1. Rastrear quem deu cada medicamento ao pet.
2. Ajudar a encontrar um pet perdido via QR Code.

**Publico-alvo:** Donos de animais de estimacao (caes e gatos), especialmente os que lidam com medicacoes cronicas ou multiplos cuidadores.

---

## 2. IDENTIDADE VISUAL (BRANDING)

### 2.1 Cores primarias

| Cor | Hex | Uso |
|-----|-----|-----|
| Verde floresta | `#2E7D32` | Cor principal, botoes, headers |
| Verde claro | `#A5D6A7` | Fundos suaves, cards |
| Laranja/Ambar | `#FF8F00` | CTAs secundarios, alertas |

### 2.2 Cores neutras

| Cor | Hex | Uso |
|-----|-----|-----|
| Fundo | `#FAFBF6` | Background geral |
| Texto principal | `#1E2A1E` | Paragrafos, titulos |

### 2.3 Tipografia

- **Titulos:** Inter (bold/extra bold) ou Poppins
- **Corpo:** Inter (regular/medium)

### 2.4 Tom de voz

Calmo, empatico, profissional e ligeiramente informal ("O seu pet merece o melhor cuidado.").

### 2.5 Elementos visuais

- Icones arredondados
- Ilustracoes de pets (patas, ossinhos)
- Fotos reais de caes/gatos (Unsplash)
- Mockups de smartphone mostrando a app

---

## 3. ESTRUTURA DO SITE (PAGINAS)

O site tera 4 paginas:

1. **Home** (`/`) - principal landing page
2. **Preos** (`/pricing`) - comparacao Free vs Premium
3. **Politica de Privacidade** (`/privacy`) - estatica
4. **Termos de Uso** (`/terms`) - estatica

> Blog/FAQ nao e prioritario nesta fase.

---

## 4. CONTEUDO DETALHADO POR SECCAO (HOME)

### Secao 1 - Hero (acima da dobra)

**Headline:**
> "Saber exatamente quem deu cada medicamento ao seu pet. E encontra-lo mais rapido, se ele se perder."

**Subheadline:**
> "Gerencie medicacoes, convide cuidadores e tenha um QR Code unico na coleira do seu pet - tudo com privacidade total."

**CTA Primario:**
- Texto: "Comecar teste gratis de 14 dias"
- Link: `https://app.petcare.com`
- `target="_blank"`

**CTA Secundario:**
- Texto: "Ver como funciona"
- Link: `#como-funciona` (ancora)

**Elemento visual:**
Mockup de smartphone com tela de gestao de medicamentos da app. Ao lado, uma coleira com QR Code a flutuar.

### Secao 2 - Problema / Solucao

**Titulo da secao:** "Cuidar de um pet com medicacao nao precisa ser um caos."

**Grid com 3 cards:**

**Card 1:**
- Icone: Calendario/relógio
- Titulo: "Nunca mais perca uma dose"
- Texto: "Agendamentos diarios, semanais ou intervalados. Receba lembretes no seu telemovel e saiba exatamente quando a proxima dose deve ser dada."

**Card 2:**
- Icone: Pessoas/checklist
- Titulo: "Quem deu? Fica registado"
- Texto: "Cuidadores e familiares marcam as doses que administram. Historico completo com nome e hora - adeus a duvida."

**Card 3:**
- Icone: QR Code / localizacao
- Titulo: "QR Code na coleira = seguranca extra"
- Texto: "Se alguem encontrar o seu pet, basta escanear o QR Code. Recebe um alerta instantaneo com a localizacao - sem expor os seus dados pessoais."

### Secao 3 - Como funciona (passo a passo)

**Titulo:** "Em 3 passos, o seu pet esta protegido"

**Passo 1:**
- Icone: Cadastro (formulario)
- Titulo: "Crie o perfil do seu pet"
- Texto: "Adicione nome, foto, peso e as medicacoes que ele toma - tudo em menos de 2 minutos."

**Passo 2:**
- Icone: QR Code / impressao
- Titulo: "Gere e imprima o QR Code"
- Texto: "A app gera um codigo unico para cada pet. Coloque na coleira, na plaqueta ou imprima uma etiqueta."

**Passo 3:**
- Icone: Convite / casa
- Titulo: "Convide cuidadores e relaxe"
- Texto: "Partilhe um link de convite com quem ajuda nos cuidados. Eles marcam as doses, mas nunca editam ou apagam informacoes importantes."

### Secao 4 - Funcionalidades chave

**Titulo:** "Tudo o que precisa para cuidar bem"

**Lista em 2 colunas com icones:**

- [x] Registo ilimitado de doses e historico completo
- [x] Notificacoes push para doses pendentes e perdidas
- [x] Pagina publica do pet (via QR Code) sem dados privados
- [x] Suporte a varios pets, cuidadores e tipos de medicacao
- [x] Dados seguros com autenticacao por Magic Link (sem passwords)
- [x] Funciona no telemovel, tablet e computador (Web)

### Secao 5 - Precos (Pricing)

**Titulo:** "Planos simples e justos"

**Card Free:**
- Preco: EUR 0/mes
- Subtitulo: "Para sempre"
- Features:
  - 1 pet
  - 1 medicacao ativa
  - 1 cuidador
  - QR Code e pagina publica
  - Lembretes por email
- Botao: "Comecar gratis" -> `https://app.petcare.com`

**Card Premium (destacado visualmente):**
- Preco: EUR 1,99/mes
- Subtitulo: "ou EUR 19,99/ano"
- Features:
  - Pets ilimitados
  - Medicacoes ilimitadas
  - Cuidadores ilimitados
  - Notificacoes push em tempo real
  - Historico completo de doses
  - Suporte prioritario
- Badge: "14 dias de teste gratis"
- Botao: "Experimentar 14 dias gratis" -> `https://app.petcare.com`

**Nota de rodape:**
"Nao pedimos cartao de credito para iniciar o teste. Cancele quando quiser."

### Secao 6 - Chamada final (CTA Final)

**Fundo:** Verde escuro (`#1B5E20`) com texto branco.

**Titulo:** "Pronto para cuidar do seu pet com mais tranquilidade?"

**Subtitulo:** "Junte-se a centenas de donos que ja protegem os seus animais com o PetCare."

**Botao grande:** "Testar gratis por 14 dias" -> `https://app.petcare.com`

### Secao 7 - Rodape (Footer)

**Logotipo:** PetCare (texto ou marca)

**Links:**
- Sobre -> `/`
- Precos -> `/pricing`
- Politica de Privacidade -> `/privacy`
- Termos de Uso -> `/terms`
- Contacto -> `mailto:legal@petcare.com`

**Icones sociais:** Instagram, Facebook, TikTok (se existirem)

**Copyright:** (c) 2026 PetCare. Todos os direitos reservados.

---

## 5. PAGINAS ESTATICAS (PRIVACY & TERMS)

### 5.1 Politica de Privacidade (`/privacy`)

**CONTEUDO PRONTO DISPONIVEL:**
O texto completo esta em `docs/legal/politica-de-privacidade.txt` no repositorio.
Tambem deployado em `https://moonlit-pothos-c56cd4.netlify.app/privacy.html`.

**Resumo para o Framer:**
- LGPD (Brasil), CCPA (California), GDPR (UE), Lei 23/96 (Portugal)
- Dados recolhidos: nome, email, dados do pet, FCM token, IP, analytics
- Localizacao apenas com permissao explicita (mensagem "pet encontrado")
- Nao partilha com terceiros para fins comerciais
- Direitos: acesso, correcao, eliminacao, portabilidade
- Exclusao de conta: botao na app "Perfil > Excluir conta (LGPD)"
- Contacto: legal@petcare.com

**Placeholder:** Substituir `[SEU_NOME]` e `[SEU_ENDERECO]` pelos dados reais antes de publicar.

### 5.2 Termos de Uso (`/terms`)

**CONTEUDO PRONTO DISPONIVEL:**
O texto completo esta em `docs/legal/termos-de-servico.txt` no repositorio.
Tambem deployado em `https://moonlit-pothos-c56cd4.netlify.app/terms.html`.

**Resumo para o Framer:**
- Condicoes de utilizacao da app
- Responsabilidades do utilizador
- Planos: Free (EUR 0) e Premium (EUR 1,99/mes)
- Politica de cancelamento: cancele quando quiser, sem reembolso de periodos parciais
- DMCA: notificacoes para legal@petcare.com
- Arbitragem vinculativa (CAM Lisboa ou AAA EUA)
- Limitacao de responsabilidade: nao substitui aconselhamento veterinario
- Lei aplicavel: Portugal (Lei 23/96)

**Placeholder:** Substituir `[SEU_NOME]` e `[SEU_ENDERECO]` pelos dados reais antes de publicar.

---

## 6. REQUISITOS TECNICOS PARA O FRAMER

### 6.1 Responsividade

| Breakpoint | Largura |
|-----------|---------|
| Desktop | 1920px |
| Tablet | 768px |
| Mobile | 375px |

Base de design: 1440px (Desktop)

### 6.2 SEO - Meta tags por pagina

| Pagina | Meta titulo | Meta descricao |
|--------|------------|----------------|
| Home | "PetCare - Gestao de medicamentos e QR Code para pets" | "Saiba quem deu cada medicamento ao seu pet. QR Code unico na coleira para encontra-lo se se perder. Teste gratis 14 dias." |
| Pricing | "Planos PetCare - Gratis ou Premium a partir de EUR 1,99/mes" | "Plano Free para sempre ou Premium com pets e cuidadores ilimitados. 14 dias de teste gratis, sem cartao." |
| Privacy | "Politica de Privacidade - PetCare" | "Como o PetCare recolhe, usa e protege os seus dados. Conformidade LGPD, CCPA e GDPR." |
| Terms | "Termos de Uso - PetCare" | "Condicoes de utilizacao do PetCare. Planos, cancelamento, DMCA e arbitragem." |

### 6.3 Velocidade

- Imagens otimizadas (WebP)
- Evitar animacoes pesadas que prejudiquem Core Web Vitals
- LCP < 2.5s
- CLS < 0.1

### 6.4 Links externos (CRITICO)

**Todos os CTAs devem abrir o app numa nova aba:**
- `target="_blank"`
- `rel="noopener noreferrer"`
- URL: `https://app.petcare.com` (substituir por `https://moonlit-pothos-c56cd4.netlify.app` enquanto o dominio custom nao estiver configurado)

### 6.5 Configuracao de dominio (DNS)

| Registro | Tipo | Valor |
|----------|------|-------|
| `@` (root) | A/CNAME | Servidores do Framer |
| `www` | CNAME | Servidores do Framer |
| `app` | CNAME | `moonlit-pothos-c56cd4.netlify.app` |

**No Netlify:**
- Site settings > Domain management > Add custom domain: `app.petcare.com`

---

## 7. ANIMACOES E INTERACOES (UX)

### 7.1 Hero
- Texto com fade-in suave (0.5s)
- Mockup do telefone com animacao infinita de leve elevacao (float)

### 7.2 Cards
- Hover: leve elevacao (sombra maior) + transicao de cor na borda
- Transicao: 200ms ease-out

### 7.3 Scroll reveal
- Secoes aparecem com fade-up ao scroll
- Usar "Scroll Transform" nativo do Framer

### 7.4 Menu mobile
- Hamburger menu que abre overlay com todos os links
- Animacao de slide-in da direita (300ms)

---

## 8. COPY ALTERNATIVA (PARA A/B TESTING)

### 8.1 Hero alternativo
> "O seu pet seguro. A sua mente tranquila."

### 8.2 Card 3 alternativo
> "QR Code que avisa quando o pet e encontrado - sem expor o seu numero de telefone."

### 8.3 Depoimento (opcional)
> "A minha cadela toma medicacao 3x ao dia. Com o PetCare, toda a familia ajuda sem confusao."
> - Mariana, utilizadora Premium.

---

## 9. INSTRUCOES FINAIS PARA O FRAMER

1. Criar novo projeto no Framer com base Desktop (1440px width)

2. Configurar Theme do Framer:
   - Primary: `#2E7D32`
   - Background: `#FAFBF6`
   - Text: `#1E2A1E`
   - Accent: `#FF8F00`

3. Adicionar secoes na ordem indicada, usando componentes nativos (Text, Image, Button, Stack, Grid)

4. Ligar os links:
   - Botoes "Testar gratis" -> `https://app.petcare.com` (`target="_blank"`)
   - Rodape Privacy -> `/privacy`
   - Rodape Terms -> `/terms`
   - Rodape Precos -> `/pricing`

5. Publicar no dominio principal e configurar CNAME de `app` para Netlify

---

## 10. ARQUITETURA DE SUBDOMINIOS (CRITICO)

```
www.petcare.com (Framer)          -> Site institucional
app.petcare.com (Netlify/Flutter) -> App SaaS funcional
```

### 10.1 O que vive no Framer (www.petcare.com)
- Landing page (Home)
- Pricing
- Privacy
- Terms
- Blog (futuro)

### 10.2 O que vive no Netlify (app.petcare.com)
- Login / auth
- Dashboard
- Gestao de pets, medicacoes, doses
- Pagina publica do pet: `app.petcare.com/p/<uuid>`
- Convite de cuidador: `app.petcare.com/join?token=<token>`
- Scanner QR: `app.petcare.com/scan`

### 10.3 Atencao aos QR Codes (CRITICO)

Os QR Codes gerados pela app Flutter apontam para:
```
https://app.petcare.com/p/<uuid>
```

**O Framer NAO deve tentar servir a rota `/p/<uuid>`.**
Se alguem escanear um QR Code, deve ir direto ao Netlify (app.petcare.com).

### 10.4 Bug atual no codigo Flutter (corrigir separadamente)

O ficheiro `lib/core/services/deep_link_service.dart` tem:
- Dominio errado: `https://petcare-micro-saas.web.app` (legacy)
- Path errado: `/pet/<uuid>` em vez de `/p/<uuid>`

**Correcao:**
```dart
static const String webBaseUrl = 'https://app.petcare.com';

static String publicPetUrl(String qrCodeUuid) =>
    '$webBaseUrl/p/$qrCodeUuid';
```

---

## 11. INTEGRACAO COM API DO FRAMER (OPCIONAL - PARA AUTOMACAO)

O Framer tem uma Server API (em beta aberto, gratuita) que permite:
- Publicar mudancas programaticamente
- Sincronizar CMS com fontes externas
- Atualizar conteudo sem abrir o Framer

### 11.1 Setup

```bash
npm install framer-api
```

### 11.2 Exemplo de uso (Node.js)

```javascript
import { connect } from "framer-api";

const framer = await connect(
  "https://framer.com/projects/<project-id>",
  process.env.FRAMER_API_KEY // gerar em Site Settings > General
);

// Ver mudancas nao publicadas
const changes = await framer.getChangedPaths();
console.log(changes); // { added: [...], removed: [...], modified: [...] }

// Publicar nova versao de preview
const result = await framer.publish();
console.log(result); // { deployment: { id: "..." }, hostnames: [...] }

// Promover para producao
await framer.deploy(result.deployment.id);
```

### 11.3 Capacidades da API

| Operacao | Suportado |
|----------|-----------|
| Publicar site | Sim |
| Promover para producao | Sim |
| Ver mudancas | Sim |
| Ler/escrever CMS | Sim (Managed Collections) |
| Atualizar canvas | Sim (Plugin API) |
| Criar paginas novas | NAO diretamente (usar Plugin API no editor) |

### 11.4 Limitacoes

- A API nao cria paginas do zero - o design deve ser feito no editor Framer
- A API e ideal para: sincronizar CMS (ex: atualizar precos), publicar mudancas, automatizar deploys
- Para criar o site inicial, e necessario usar o editor Framer (ou um template)

### 11.5 Recomendacao para o Devin

Como Devin Agent, posso:
- [x] Acessar a API do Framer via `framer-api` (Node.js)
- [x] Publicar mudancas programaticamente
- [x] Sincronizar conteudo do CMS (ex: atualizar precos se mudarem)
- [x] Verificar mudancas nao publicadas
- [ ] Criar o design inicial do site (requer editor Framer manual)
- [ ] Modificar layout visual (requer editor Framer manual)

**Fluxo recomendado:**
1. Utilizador cria o design inicial no Framer (manualmente ou com template)
2. Utilizador gera API key em Site Settings > General
3. Utilizador guarda API key em GitHub Secret: `FRAMER_API_KEY`
4. Devin pode entao publicar/sincronizar via API

---

## 12. CHECKLIST DE ENTREGA

### 12.1 Design (manual no Framer)
- [ ] Criar projeto no Framer
- [ ] Configurar Theme (cores, tipografia)
- [ ] Criar pagina Home com 7 secoes
- [ ] Criar pagina Pricing
- [ ] Criar pagina Privacy (copiar de docs/legal/politica-de-privacidade.txt)
- [ ] Criar pagina Terms (copiar de docs/legal/termos-de-servico.txt)
- [ ] Configurar meta tags SEO por pagina
- [ ] Configurar animacoes (fade-in, hover, scroll reveal)
- [ ] Testar responsividade (Desktop, Tablet, Mobile)
- [ ] Configurar menu mobile (hamburger)

### 12.2 DNS / Dominio
- [ ] Apontar `www` e `@` para Framer
- [ ] Apontar `app` (CNAME) para `moonlit-pothos-c56cd4.netlify.app`
- [ ] No Netlify: adicionar `app.petcare.com` como custom domain
- [ ] Verificar SSL automatico em ambos

### 12.3 Codigo Flutter (correcoes)
- [ ] Corrigir `deep_link_service.dart`: dominio + path
- [ ] Atualizar `constants.dart`: `siteUrl` para `https://app.petcare.com`
- [ ] Testar QR Code com nova URL
- [ ] Testar convite de cuidador com nova URL

### 12.4 Automacao (opcional)
- [ ] Gerar Framer API key
- [ ] Guardar em GitHub Secret: `FRAMER_API_KEY`
- [ ] Criar script `scripts/framer-publish.mjs` para publicar via API
- [ ] Integrar em GitHub Actions (opcional)

---

## 13. EXEMPLO DE SCRIPT DE AUTOMACAO (Node.js)

```javascript
// scripts/framer-publish.mjs
import { connect } from "framer-api";

const FRAMER_PROJECT_URL = process.env.FRAMER_PROJECT_URL;
const FRAMER_API_KEY = process.env.FRAMER_API_KEY;

async function main() {
  const framer = await connect(FRAMER_PROJECT_URL, FRAMER_API_KEY);

  const info = await framer.getProjectInfo();
  console.log(`Projeto: ${info.name}`);

  const changes = await framer.getChangedPaths();
  console.log("Mudancas:", changes);

  if (changes.added.length || changes.modified.length || changes.removed.length) {
    const result = await framer.publish();
    console.log(`Preview publicado: ${result.deployment.id}`);

    await framer.deploy(result.deployment.id);
    console.log("Promovido para producao!");
  } else {
    console.log("Sem mudancas para publicar.");
  }

  await framer.close();
}

main().catch(console.error);
```

---

## 14. RESUMO EXECUTIVO

| Item | Estado |
|------|--------|
| Site institucional (Framer) | A criar |
| App Flutter Web (Netlify) | Deployado em `moonlit-pothos-c56cd4.netlify.app` |
| Paginas legais | Criadas em `docs/legal/` e deployadas no Netlify |
| Dominio custom | Pendente (configurar DNS) |
| Bug deep_link_service | Pendente (corrigir dominio + path) |
| API Framer | Disponivel (beta gratuito), pode automatizar publicacao |

**Separacao de responsabilidades:**
- Framer = marketing, SEO, conversao
- Flutter Web = produto funcional (auth, pets, medicacoes, QR)

**Modelo: stripe.com (marketing) + dashboard.stripe.com (app)**

---

Documento gerado em 02 de setembro de 2026.
Adaptado ao estado real do projeto PetCare.
