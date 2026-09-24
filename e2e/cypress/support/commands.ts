/// <reference types="cypress" />

/**
 * Comandos Cypress para a app Flutter Web + website PetCare.
 *
 * Flutter Web desenha em canvas — os elementos DOM so existem depois de
 * ativar a arvore de semantica (botao invisivel "Enable accessibility").
 * A arvore usa <flt-semantics>: botoes tem role="button" + texto no
 * conteudo; text fields ganham um <input data-semantics-role="text-field"
 * aria-label="..."> injetado pela engine dentro do no de campo.
 */

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Cypress {
    interface Chainable {
      /** Ativa a arvore de semantica (placeholder ou auto-ativa). */
      enableSemantics(): Chainable<void>;
      /** Espera ate o ClerkJS (bridge) estar inicializado na pagina. */
      waitForClerk(): Chainable<void>;
      /** Abre a app, autentica (email_code clerk_test) e espera 'Meus pets'. */
      openApp(): Chainable<void>;
      /** Ultimo no flt-semantics cujo texto/aria-label contem o label. */
      semNode(label: string): Chainable<JQuery<HTMLElement>>;
      /** Ultimo no tappable (role=button|flt-tappable) com o nome acessivel. */
      semButton(name: string): Chainable<JQuery<HTMLElement>>;
      /** Clica num botao/no Flutter pelo nome acessivel. */
      tapButton(name: string): Chainable<void>;
      /** Tap + espera pelo marker de destino com retry (nos stale em transicoes). */
      tapAndWait(
        tap: string,
        marker: { heading?: string; text?: string },
        retries?: number,
      ): Chainable<void>;
      /** Abre o detalhe de um pet na lista com retry. */
      openPet(petName: string, marker?: string): Chainable<void>;
      /** Preenche um TextFormField Flutter pela label. */
      fillField(label: string, value: string): Chainable<void>;
      /** id do utilizador Clerk autenticado na pagina. */
      clerkUserId(): Chainable<string>;
      /** REST Supabase com o JWT do utilizador (respeita RLS). */
      sbRest(
        method: string,
        table: string,
        query: string,
        body?: unknown,
      ): Chainable<any>;
      /** Cria um pet via REST (setup de testes). Devolve o id. */
      createPetViaApi(name: string): Chainable<string>;
      /** Apaga pets de teste por prefixo (isola specs). */
      cleanupTestPets(prefix: string): Chainable<void>;
      /** Cria uma medicacao diaria via REST (setup). Devolve o id. */
      createMedicationViaApi(petId: string, name: string): Chainable<string>;
      /** Cria uma dose pending para hoje via REST (setup). Devolve o id. */
      createPendingDoseViaApi(
        petId: string,
        medicationId: string,
      ): Chainable<string>;
      /** Cria um cuidador pending via REST (setup). Devolve o id. */
      createCaregiverViaApi(
        petId: string,
        email: string,
      ): Chainable<string>;
      /** prefers-reduced-motion via CDP (chromium-family apenas). */
      emulateReducedMotion(): Chainable<void>;
    }
  }
}

export {};

/* ------------------------------------------------------------------ */
/* Ritmo legivel (self-healing + observacao humana)                    */
/* ------------------------------------------------------------------ */

/**
 * Em modo headed/interativo cada acao visivel faz uma pausa — suites
 * corridas a velocidade de maquina sao impossiveis de acompanhar.
 * Override via env: CYPRESS_SLOW_MO=1200 (0 desliga).
 */
const SLOW_MO = Number(
  Cypress.expose('SLOW_MO') ?? (Cypress.browser.isHeaded ? 900 : 0),
);

if (SLOW_MO > 0) {
  (['click', 'type', 'clear', 'selectFile', 'check', 'uncheck'] as const).forEach(
    (cmd) => {
      Cypress.Commands.overwrite(
        cmd as 'click',
        ((orig: (...a: any[]) => Cypress.Chainable, ...args: any[]) =>
          orig(...args).then((res: unknown) =>
            cy.wait(SLOW_MO).then(() => res),
          )) as never,
      );
    },
  );
}

/* ------------------------------------------------------------------ */
/* Utilitarios internos                                                */
/* ------------------------------------------------------------------ */

// Configuracao publica (expose) — valores nao-sensiveis legiveis no
// browser. Sensiveis como E2E_PASSWORD leem-se via cy.env() (async).
const cfg = (k: string) => Cypress.expose(k) as string;

const text = (el: Element) =>
  (el.getAttribute('aria-label') ?? '') + ' ' + (el.textContent ?? '');

/** Filtra nos cujo conteudo contem o label (exact primeiro, parcial depois). */
function matchNodes($els: JQuery<HTMLElement>, label: string) {
  const trimmed = label.trim();
  const all = $els.filter((_, el) => text(el).includes(trimmed));
  const exact = all.filter((_, el) => (el.textContent ?? '').trim() === trimmed);
  return exact.length ? exact : all;
}

const SEM_BUTTONS = 'flt-semantics[role="button"], flt-semantics[flt-tappable]';

function markerInDom(doc: Document, m: { heading?: string; text?: string }) {
  const needle = m.heading ?? m.text!;
  // O Flutter renderiza headers de AppBar como <h2> reais (nao flt-semantics)
  // — por isso o marker de heading tem de incluir h1-h6.
  const els = m.heading
    ? doc.querySelectorAll('h1, h2, h3, h4, h5, h6, [role="heading"]')
    : doc.querySelectorAll('flt-semantics, h1, h2, h3, h4, h5, h6');
  return Array.from(els).some((el) => text(el).includes(needle));
}

/** Polling generico contra o documento AUT: true quando pred, false no deadline. */
function poll(
  pred: (doc: Document) => boolean,
  deadlineMs: number,
): Cypress.Chainable<boolean> {
  return cy
    .document()
    .then((doc) => pred(doc))
    .then((ok) => {
      if (ok) return true;
      if (Date.now() > deadlineMs) return false;
      cy.wait(500);
      return poll(pred, deadlineMs);
    });
}

/**
 * Procura um no de semantica por polling — a arvore flt-semantics e
 * derrubada e reconstruida pelo Flutter em transicoes (e ate desativada
 * temporariamente), por isso um cy.get() resolvido contra o frame
 * anterior devolve nos stale/vazios.
 */
function findSem(
  scopeSel: string,
  label: string,
  opts: { first?: boolean; timeout?: number } = {},
): Cypress.Chainable<JQuery<HTMLElement>> {
  const deadline = Date.now() + (opts.timeout ?? 20_000);
  const step = (): Cypress.Chainable<JQuery<HTMLElement>> =>
    cy.document().then((doc) => {
      const $m = matchNodes(
        Cypress.$(scopeSel, doc) as JQuery<HTMLElement>,
        label,
      );
      if ($m.length) {
        return (opts.first ? $m.first() : $m.last()) as JQuery<HTMLElement>;
      }
      if (Date.now() > deadline) {
        throw new Error(`nó '${label}' (${scopeSel}) não encontrado`);
      }
      cy.wait(400);
      return step();
    });
  return step();
}

/* ------------------------------------------------------------------ */
/* Semantica Flutter                                                    */
/* ------------------------------------------------------------------ */

Cypress.Commands.add('enableSemantics', () => {
  cy.get('flt-semantics-placeholder, flt-semantics', { timeout: 90_000 })
    .should('exist')
    .then(() => {
      cy.document().then((doc) => {
        if (doc.querySelector('flt-semantics')) return;
        const ph = doc.querySelector(
          'flt-semantics-placeholder',
        ) as HTMLElement | null;
        ph?.click();
      });
      cy.get('flt-semantics', { timeout: 30_000 }).should('exist');
    });
});

Cypress.Commands.add('semNode', (label: string) =>
  findSem('flt-semantics', label),
);

Cypress.Commands.add('semButton', (name: string) => findSem(SEM_BUTTONS, name));

Cypress.Commands.add('tapButton', (name: string) => {
  // Botao tappable primeiro; fallback para qualquer no com o texto
  // (cards/list tiles nem sempre tem role="button").
  const deadline = Date.now() + 20_000;
  const step = (): Cypress.Chainable<void> =>
    cy.document().then((doc) => {
      let $m = matchNodes(Cypress.$(SEM_BUTTONS, doc), name);
      if (!$m.length) {
        $m = matchNodes(Cypress.$('flt-semantics', doc), name);
      }
      if ($m.length) {
        cy.wrap($m.last()).click({ force: true });
        return;
      }
      if (Date.now() > deadline) {
        throw new Error(`alvo '${name}' não encontrado`);
      }
      cy.wait(400);
      return step();
    });
  return step();
});

Cypress.Commands.add(
  'tapAndWait',
  (tap: string, marker: { heading?: string; text?: string }, retries = 3) => {
    const attempt = (left: number): Cypress.Chainable<void> =>
      cy
        .tapButton(tap)
        .then(() =>
          poll((doc) => markerInDom(doc, marker), Date.now() + 12_000),
        )
        .then((ok) => {
          if (ok) return;
          if (left <= 1) {
            throw new Error(
              `tap '${tap}' não chegou a ${JSON.stringify(marker)}`,
            );
          }
          return attempt(left - 1);
        });
    return attempt(retries);
  },
);

Cypress.Commands.add('openPet', (petName: string, marker = 'Cuidadores') => {
  const attempt = (left: number): Cypress.Chainable<void> =>
    // A stream realtime pode demorar a emitir — findSem espera o card.
    findSem(SEM_BUTTONS, petName, { first: true, timeout: 30_000 })
      .click({ force: true })
      .then(() =>
        poll(
          (doc) => markerInDom(doc, { text: marker }),
          Date.now() + 10_000,
        ),
      )
      .then((ok) => {
        if (ok) return;
        if (left <= 1)
          throw new Error(`Não abriu o detalhe do pet ${petName}`);
        cy.wait(1000);
        return attempt(left - 1);
      });
  return attempt(3);
});

Cypress.Commands.add('fillField', (label: string, value: string) => {
  const INPUT = 'flt-semantics input[data-semantics-role="text-field"]';
  const deadline = Date.now() + 20_000;
  const step = (): Cypress.Chainable<void> =>
    cy.document().then((doc) => {
      // O aria-label do input conserva a labelText mesmo com valor —
      // ao contrario do nome acessivel do no, que passa a ser o valor.
      const $inp = Cypress.$(INPUT, doc).filter((_, el) =>
        (el.getAttribute('aria-label') ?? '').includes(label),
      );
      if ($inp.length) {
        cy.wrap($inp.last() as JQuery<HTMLElement>)
          .clear({ force: true })
          .type(value, { force: true });
        cy.wait(150);
        return;
      }
      const $any = matchNodes(Cypress.$('flt-semantics', doc), label);
      if ($any.length) {
        cy.wrap($any.last() as JQuery<HTMLElement>).click({ force: true });
        cy.wait(400);
        cy.focused().type(value);
        cy.wait(150);
        return;
      }
      if (Date.now() > deadline) {
        throw new Error(`campo '${label}' não encontrado`);
      }
      cy.wait(400);
      return step();
    });
  return step();
});

/* ------------------------------------------------------------------ */
/* Clerk — sign-in programatico por contexto                           */
/* ------------------------------------------------------------------ */

async function signInProgrammatic(win: any, email: string, code: string) {
  const C = win.Clerk;
  const password: string | null = win.__E2E_PASSWORD ?? null;
  try {
    const si = await C.client.signIn.create({ identifier: email });
    if (password) {
      const att = await si.attemptFirstFactor({
        strategy: 'password',
        password,
      });
      if (att.status === 'complete') return { session: att.createdSessionId };
      return { err: `signIn(password) status ${att.status}` };
    }
    const factor = si.supportedFirstFactors?.find(
      (f: any) => f.strategy === 'email_code',
    );
    if (!factor) {
      return {
        err:
          'email_code nao suportado: ' +
          JSON.stringify(
            si.supportedFirstFactors?.map((f: any) => f.strategy),
          ),
      };
    }
    await si.prepareFirstFactor({
      strategy: 'email_code',
      emailAddressId: factor.emailAddressId,
    });
    const att = await si.attemptFirstFactor({ strategy: 'email_code', code });
    if (att.status === 'complete') return { session: att.createdSessionId };
    return { err: `signIn status ${att.status}` };
  } catch (e: any) {
    const notFound = e?.errors?.some(
      (x: any) => x.code === 'form_identifier_not_found',
    );
    if (!notFound) {
      return { err: JSON.stringify(e?.errors ?? String(e)).slice(0, 400) };
    }
    try {
      const su = await C.client.signUp.create({ emailAddress: email });
      await su.prepareEmailAddressVerification({ strategy: 'email_code' });
      const att = await su.attemptEmailAddressVerification({ code });
      if (att.status === 'complete') return { session: att.createdSessionId };
      return { err: `signUp status ${att.status}` };
    } catch (e2: any) {
      return { err: `signUp: ${String(e2?.errors ?? e2).slice(0, 300)}` };
    }
  }
}

Cypress.Commands.add('waitForClerk', () => {
  cy.window().its('Clerk.client', { timeout: 60_000 }).should('exist');
});

Cypress.Commands.add('openApp', () => {
  const appUrl = cfg('APP_URL');
  // cy.env(): leitura assincrona (lista de chaves -> objeto) — a
  // password nao entra no estado do browser ate ser injetada na pagina
  // para o sign-in do Clerk.
  cy.env(['E2E_PASSWORD']).then((vars: Record<string, string>) => {
    const password = vars?.E2E_PASSWORD ?? null;
    // Deep links nao funcionam no boot: o redirect do router corre antes
    // do Clerk carregar. Navega-se sempre pela UI depois de 'Meus pets'.
    cy.visit(`${appUrl}/pets`, {
      // GitHub Pages serve 404.html para rotas SPA — o script de redirect
      // restaura a URL. Sem failOnStatusCode o visit falhava no 404.
      failOnStatusCode: false,
      onBeforeLoad(win: any) {
        try {
          // shared_preferences_web guarda chaves com prefixo flutter.
          win.localStorage.setItem('flutter.onboarding_seen', 'true');
          if (password) win.__E2E_PASSWORD = password;
        } catch {}
      },
    });
    cy.enableSemantics();
    // ClerkJS (bridge) inicializado.
    cy.window().its('Clerk.client', { timeout: 60_000 }).should('exist');
    // Sign-in programatico se necessario — cria sessao real sem CAPTCHA.
    cy.window()
      .then(async (win: any) => {
        if (win.Clerk?.user?.id) return { signed: false };
        const email = cfg('E2E_EMAIL');
        const res = await signInProgrammatic(win, email, '424242');
        if ((res as any).err) {
          throw new Error(
            `Login E2E falhou: ${(res as any).err}. Cria a conta ${email} ` +
              'uma vez via UI da app (codigo 424242) ou desliga "Bot sign-up ' +
              'protection" no Clerk dashboard.',
          );
        }
        await win.Clerk.setActive({ session: (res as any).session });
        return { signed: true };
      })
      .then(({ signed }) => {
        if (!signed) return;
        // Reload: a app arranca ja autenticada e o router estabiliza em /pets.
        cy.reload();
        cy.enableSemantics();
      });
    cy.window().its('Clerk.user.id', { timeout: 60_000 }).should('exist');
    cy.semNode('Meus pets').should('exist');
  });
});

/* ------------------------------------------------------------------ */
/* Supabase REST (JWT do utilizador — respeita RLS)                    */
/* ------------------------------------------------------------------ */

Cypress.Commands.add('clerkUserId', () => {
  return cy
    .window()
    .its('Clerk.user.id')
    .then((id) => {
      if (!id) throw new Error('Sem user Clerk na pagina');
      return id as unknown as string;
    });
});

Cypress.Commands.add(
  'sbRest',
  (method: string, table: string, query: string, body?: unknown) => {
    return cy
      .window()
      .then(async (win: any) => {
        const clerk = win.Clerk;
        if (!clerk?.session) throw new Error('Sem sessao Clerk na pagina');
        try {
          return await clerk.session.getToken({ template: 'supabase' });
        } catch {
          return await clerk.session.getToken();
        }
      })
      .then((jwt) =>
        cy
          .request({
            method,
            url: `${cfg('SB_URL')}/rest/v1/${table}?${query}`,
            headers: {
              apikey: cfg('SB_ANON_KEY'),
              Authorization: `Bearer ${jwt}`,
              'Content-Type': 'application/json',
              Prefer: 'return=representation',
            },
            body,
          })
          .its('body'),
      );
  },
);

Cypress.Commands.add('createPetViaApi', (name: string) => {
  return cy.clerkUserId().then((ownerId) =>
    cy
      .sbRest('POST', 'pets', '', {
        owner_id: ownerId,
        name,
        species: 'dog',
      })
      .then((rows) => rows[0].id as string),
  );
});

Cypress.Commands.add('cleanupTestPets', (prefix: string) => {
  cy.sbRest('DELETE', 'pets', `name=like.${prefix}*`);
});

Cypress.Commands.add('createMedicationViaApi', (petId: string, name: string) => {
  return cy
    .sbRest('POST', 'medications', '', {
      pet_id: petId,
      name,
      dosage: '1 comprimido',
      frequency_type: 'daily',
      schedule_times: ['08:00'],
      start_date: new Date().toISOString().slice(0, 10),
    })
    .then((rows) => rows[0].id as string);
});

Cypress.Commands.add(
  'createPendingDoseViaApi',
  (petId: string, medicationId: string) => {
    // Horario futuro hoje — senao o cron marca 'missed' antes do clique.
    const in30min = new Date(Date.now() + 30 * 60 * 1000);
    const endOfToday = new Date();
    endOfToday.setUTCHours(23, 59, 0, 0);
    const scheduled =
      in30min < endOfToday ? in30min.toISOString() : endOfToday.toISOString();
    return cy
      .sbRest('POST', 'dose_logs', '', {
        medication_id: medicationId,
        pet_id: petId,
        scheduled_time: scheduled,
        status: 'pending',
      })
      .then((rows) => rows[0].id as string);
  },
);

Cypress.Commands.add('createCaregiverViaApi', (petId: string, email: string) => {
  return cy.clerkUserId().then((ownerId) =>
    cy
      .sbRest('POST', 'caregivers', '', {
        pet_id: petId,
        owner_id: ownerId,
        caregiver_email: email,
        status: 'pending',
      })
      .then((rows) => rows[0].id as string),
  );
});

/* ------------------------------------------------------------------ */
/* Emulacao                                                             */
/* ------------------------------------------------------------------ */

Cypress.Commands.add('emulateReducedMotion', () => {
  if (Cypress.browser.family !== 'chromium') {
    cy.log('emulateReducedMotion: apenas chromium-family — skip');
    return;
  }
  cy.wrap(
    Cypress.automation('remote:debugger:protocol', {
      command: 'Emulation.setEmulatedMedia',
      params: {
        features: [{ name: 'prefers-reduced-motion', value: 'reduce' }],
      },
    }),
  );
});
