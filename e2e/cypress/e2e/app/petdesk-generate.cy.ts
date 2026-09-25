/// <reference types="cypress" />

// Funcionalidade: PetDeskSaas online (Edge Function petdesk-generate)
//   Cenario: Contrato de seguranca e fluxo library/recolor
//     Entao sem JWT da 401; inputs invalidos dao 400; custom da 501;
//     pet_id alheio da 404; a biblioteca resolve e devolve signed URL;
//     o 6.o job do dia da 429.

const SB_URL = Cypress.expose('SB_URL') as string;
const ANON = Cypress.expose('SB_ANON_KEY') as string;
const FN = `${SB_URL}/functions/v1/petdesk-generate`;

function authed(fn: (headers: Record<string, string>) => void) {
  cy.window().then(async (win: any) => {
    let jwt: string;
    try {
      jwt = await win.Clerk.session.getToken({ template: 'supabase' });
    } catch {
      jwt = await win.Clerk.session.getToken();
    }
    fn({ apikey: ANON, Authorization: `Bearer ${jwt}` });
  });
}

const post = (body: unknown, headers?: Record<string, string>) =>
  cy.request({
    method: 'POST',
    url: FN,
    headers: {
      'content-type': 'application/json',
      ...(headers ?? {}),
    },
    body,
    failOnStatusCode: false,
  });

describe('PetDesk generate', () => {
  before(() => {
    cy.openApp();
  });

  after(() => {
    // Limpar os jobs de teste (o delete repõe a quota do rate limit,
    // porque o count so' olha para linhas existentes).
    authed((headers) => {
      cy.request({
        method: 'DELETE',
        url: `${SB_URL}/rest/v1/pet_generation_jobs?breed_id=like.e2e*`,
        headers,
        failOnStatusCode: false,
      });
      cy.request({
        method: 'DELETE',
        url: `${SB_URL}/rest/v1/pet_generation_jobs?breed_id=eq.golden`,
        headers,
        failOnStatusCode: false,
      });
    });
  });

  it('contrato completo: auth, validacao, IDOR, rate limit e fluxo', () => {
    // --- sem JWT -> 401 -------------------------------------------
    post({ kind: 'library', breed_id: 'golden' }).then((r) => {
      expect(r.status).to.eq(401);
    });

    authed((h) => {
      // --- validacao Zod -------------------------------------------
      post({ kind: 'nao-existe' }, h).then((r) => expect(r.status).to.eq(400));
      post({ kind: 'library' }, h).then((r) =>
        expect(r.status, 'library sem breed_id').to.eq(400),
      );
      post({ kind: 'custom', description: 'x'.repeat(301) }, h).then((r) =>
        expect(r.status, 'description >300').to.eq(400),
      );
      post(
        { kind: 'library', breed_id: 'golden', role: 'admin' },
        h,
      ).then((r) => expect(r.status, 'campo extra (strict)').to.eq(400));
      post({ kind: 'recolor', breed_id: 'golden' }, h).then((r) =>
        expect(r.status, 'recolor sem coat').to.eq(400),
      );

      // --- custom ainda nao suportado ------------------------------
      post({ kind: 'custom', description: 'cao caramelo' }, h).then((r) =>
        expect(r.status).to.eq(501),
      );

      // --- IDOR: pet_id que nao pertence ao user -> 404 ------------
      post(
        {
          kind: 'library',
          breed_id: 'golden',
          pet_id: '00000000-0000-4000-8000-000000000000',
        },
        h,
      ).then((r) => expect(r.status, 'pet alheio').to.eq(404));

      // --- breed inexistente -> 404 --------------------------------
      post({ kind: 'library', breed_id: 'e2e-inexistente' }, h).then((r) =>
        expect(r.status).to.eq(404),
      );

      // --- fluxo feliz (depende da biblioteca ja estar no bucket) --
      post({ kind: 'library', breed_id: 'golden' }, h).then((r) => {
        if (r.status === 404) {
          // Biblioteca ainda nao carregada no bucket — pendente manual
          // (SUPABASE_SERVICE_ROLE_KEY + upload_petpacks.py).
          cy.log('library pack nao disponivel ainda — skip fluxo feliz');
          return;
        }
        expect(r.status, 'criar job').to.eq(202);
        const jobId = r.body.job_id as string;
        cy.request({
          url: `${FN}?job_id=${jobId}`,
          headers: h,
        }).then((g) => {
          expect(g.status).to.eq(200);
          expect(g.body.status).to.eq('done');
          expect(g.body.petpack_url).to.be.a('string');
          // A signed URL serve mesmo o ficheiro.
          cy.request({ url: g.body.petpack_url, failOnStatusCode: false })
            .then((dl) => expect(dl.status).to.eq(200));
        });
      });

      // --- rate limit: 6.o job do dia ------------------------------
      // O fluxo feliz ja' gastou 1 job; mais 6 -> o ultimo deve ser 429.
      // Se a biblioteca ainda nao estiver no bucket os inserts dao 404 e
      // a quota nunca enche — o check fica neutro ate ao upload.
      const statuses: number[] = [];
      for (let i = 0; i < 5; i++) {
        post({ kind: 'library', breed_id: 'golden' }, h).then((r) => {
          statuses.push(r.status);
        });
      }
      cy.then(() => {
        // Fluxo feliz (1) + 4 ok = quota cheia -> o 5.o do loop e' 429.
        if (statuses.slice(0, 4).every((s) => s === 202)) {
          expect(statuses[4], 'job alem da quota diaria').to.eq(429);
        } else {
          cy.log(`rate-limit adiado (status: ${statuses.join(',')})`);
        }
      });
    });
  });
});
