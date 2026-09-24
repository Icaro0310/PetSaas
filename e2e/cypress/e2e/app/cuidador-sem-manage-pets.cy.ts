/// <reference types="cypress" />

const CG_EMAIL = 'petcare.e2e.caregiver+clerk_test@example.com';

// Funcionalidade: Cuidadores
//   Cenario: Cuidador sem permissao manage_pets nao gere animais
//     Dado que o cuidador so tem "view" e "mark_dose"
//     Quando tenta inserir ou eliminar um animal do dono
//     Entao a base de dados recusa (RLS)
describe('Cuidadores — sem manage_pets', () => {
  const stamp = Date.now() % 100000;
  const petName = `CgNeg E2E ${stamp}`;
  let ownerId = '';
  let petId = '';

  before(() => {
    cy.openApp();
    cy.clerkUserId().then((id) => (ownerId = id));
    cy.createPetViaApi(petName).then((id) => (petId = id));
    cy.signInAs(CG_EMAIL);
    cy.clerkUserId().then((cgId) => {
      cy.wait(4000); // propagacao do profile via clerk-webhook
      cy.signInAs(Cypress.expose('E2E_EMAIL') as string);
      cy.createActiveCaregiverViaApi(petId, cgId, CG_EMAIL, [
        'view',
        'mark_dose',
      ]);
    });
  });

  after(() => {
    cy.openApp();
    cy.cleanupTestPets('CgNeg E2E');
    cy.cleanupTestPets('Negado E2E');
  });

  it('a RLS recusa inserir e eliminar animais do dono', () => {
    cy.signInAs(CG_EMAIL);
    cy.window()
      .then(async (win: any) => {
        const clerk = win.Clerk;
        try {
          return await clerk.session.getToken({ template: 'supabase' });
        } catch {
          return await clerk.session.getToken();
        }
      })
      .then((jwt) => {
        const headers = {
          apikey: Cypress.expose('SB_ANON_KEY') as string,
          Authorization: `Bearer ${jwt}`,
          'Content-Type': 'application/json',
          Prefer: 'return=representation',
        };
        const base = `${Cypress.expose('SB_URL')}/rest/v1`;
        cy.request({
          method: 'POST',
          url: `${base}/pets`,
          failOnStatusCode: false,
          headers,
          body: { owner_id: ownerId, name: 'Negado E2E', species: 'dog' },
        }).then((res) => {
          expect(res.status).to.be.oneOf([401, 403]);
        });
        cy.request({
          method: 'DELETE',
          url: `${base}/pets?id=eq.${petId}`,
          failOnStatusCode: false,
          headers,
        }).then((res) => {
          expect(res.status).to.be.oneOf([200, 401, 403]);
          // DELETE em RLS devolve 200 mas nao apaga nada — confirmo:
          cy.sbRest('GET', 'pets', `select=id&id=eq.${petId}`).should(
            'have.length',
            1,
          );
        });
      });
  });
});
