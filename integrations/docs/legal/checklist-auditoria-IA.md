# Checklist de Auditoria de IA - PetCare

> Conformidade com FTC (Federal Trade Commission) sobre declaracoes de IA.
> Referencia: FTC Enforcement Policy Statement Regarding Deceptive AI Claims (2023)

## Contexto

O PetCare **NAO utiliza IA generativa** nem modelos de machine learning proprios. As funcionalidades do app sao baseadas em:
- CRUD tradicional (base de dados Supabase);
- Notificacoes agendadas (cron + FCM);
- QR Codes (geracao deterministica);
- Analytics (PostHog/Firebase - agregacao de eventos, nao IA).

Este checklist garante que NAO fazemos declaracoes enganosas ("AI washing") sobre capacidades de IA no produto.

---

## 1. VERIFICACAO DE DECLARACOES PUBLICAS

### 1.1 Site, app stores e marketing

- [ ] **Nao afirmar "powered by AI"** sem fundamentacao tecnica real
- [ ] Nao usar termos como "inteligente", "automatico" ou "predicao" sem explicar o que realmente faz
- [ ] Se usar IA de terceiros (ex: analytics preditivos do Firebase), declarar de forma transparente
- [ ] Revisar todas as descricoes na Google Play Store, Netlify e README

### 1.2 Descricoes de funcionalidades

| Funcionalidade | Declaracao atual | Risco de AI washing? |
|---------------|-----------------|---------------------|
| Notificacoes de dose | "Notificacoes locais para doses pendentes" | NAO - e cron simples |
| Doses perdidas | "Dose pending passa a missed apos 2h" | NAO - e logica temporal |
| QR Code | "QR unico por pet" | NAO - e geracao UUID |
| Analytics | "Analytics de produto" | NAO - e agregacao de eventos |
| Relatorio semanal | "Estatisticas dos GitHub Actions runs" | NAO - e contagem simples |

**Resultado:** Nenhuma funcionalidade usa IA. Nao ha risco de AI washing.

---

## 2. VERIFICACAO DE CAPACIDADES EXAGERADAS

### 2.1 O que NAO afirmar

- [ ] Nao afirmar que o app "prediz" quando dar medicacao (e o utilizador que define os horarios)
- [ ] Nao afirmar que o app "diagnostica" problemas de saude do pet
- [ ] Nao afirmar que o QR Code "garante" recuperacao do pet
- [ ] Nao afirmar que o app "aprende" com os habitos do utilizador

### 2.2 O que afirmar com seguranca

- [ ] "Rastreia quem administrou cada dose" - VERDADEIRO (registra owner_id/caregiver_id)
- [ ] "Notifica quando uma dose esta atrasada" - VERDADEIRO (cron + FCM)
- [ ] "Permite que terceiros avisem o dono via QR Code" - VERDADEIRO (edge function + notificacao)

---

## 3. TRANSPARENCIA SOBRE DADOS DE TREINO

### 3.1 Se no futuro adicionarmos IA

Se o PetCare adicionar funcionalidades de IA no futuro (ex: predicao de doses esquecidas, recomendacoes de medicacao):

- [ ] Declarar que dados do utilizador NAO sao usados para treinar modelos sem consentimento explicito
- [ ] Declarar o modelo utilizado (ex: "modelo X da OpenAI" ou "modelo proprio")
- [ ] Declarar limitacoes conhecidas (ex: "pode recomendar doses incorretas em casos raros")
- [ ] Permitir opt-out do uso de dados para treino
- [ ] Atualizar a Politica de Privacidade com nova finalidade de tratamento

### 3.2 Provedores de IA de terceiros

Atualmente NENHUM provedor de IA e utilizado. Se adicionarmos:
- [ ] Verificar os termos de servico do provedor (ex: OpenAI nao permite uso dos dados para treino se opt-out)
- [ ] Assinar DPA (Data Processing Agreement) com o provedor
- [ ] Garantir que dados de saude do pet nao violam politicas do provedor

---

## 4. AUDITORIA DE CODIGO

### 4.1 Verificacao de dependencias de IA

```bash
grep -riE "openai|anthropic|langchain|tensorflow|pytorch|sklearn|huggingface" pubspec.yaml lib/
```

- [ ] Executar e confirmar que NAO ha dependencias de IA
- [ ] Se houver, documentar o uso e obter consentimento do utilizador

### 4.2 Edge functions

- [ ] Verificar que nenhuma edge function chama APIs de IA
- [ ] Verificar que analytics (PostHog/Firebase) nao usam modelos preditivos sem consentimento

---

## 5. CONFORMIDADE FTC - RESUMO

| Requisito FTC | Status |
|--------------|--------|
| Nao fazer declaracoes falsas sobre IA | APROVADO - nao usamos IA |
| Nao exagerar capacidades | APROVADO - descricoes sao factuais |
| Transparencia sobre dados de treino | N/A - sem IA |
| Consentimento para uso de dados em IA | N/A - sem IA |
| Atualizar politicas se IA for adicionada | PENDENTE - apenas se IA for adicionada |

---

## 6. REVISAO PERIODICA

- [ ] Revisar este checklist a cada 6 meses
- [ ] Revisar apos adicionar qualquer nova funcionalidade que possa usar IA
- [ ] Revisar apos atualizacoes de politicas do FTC sobre IA

---

Documento gerado em 02 de setembro de 2026.
