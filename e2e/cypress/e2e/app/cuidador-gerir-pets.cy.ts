/// <reference types="cypress" />

const CG_EMAIL = 'petcare.e2e.caregiver+clerk_test@example.com';

// Funcionalidade: Cuidadores
//   Cenario: Cuidador autorizado insere e elimina animais do dono
//     Dado que o dono concedeu a permissao "manage_pets" ao cuidador
//     Quando o cuidador inicia sessao
//     Entao consegue inserir, editar e eliminar animais na conta do dono
describe('Cuidadores — manage_pets', () => {
  const stamp = Date.now() % 100000;
  const petName = `CgPet E2E ${stamp}`;
  const cgPetName = `CgAdd E2E ${stamp}`;
  let ownerId = '';
  let petId = '';

  before(function () {
    cy.openApp();
    // A conta de cuidador nao pode ser criada programaticamente (CAPTCHA).
    // Cria-la uma vez via UI: email petcare.e2e.caregiver+clerk_test@example.com
    // com codigo 424242 — depois esta spec corre normalmente.
    cy.accountExists(CG_EMAIL).then((exists) => {
      if (!exists) {
        cy.log(
          'SKIP: cria a conta ' + CG_EMAIL + ' uma vez via UI (codigo 424242)',
        );
        this.skip();
      }
    });
    // accountExists terminou a sessao — repor a sessao do dono.
    cy.signInAs(Cypress.expose('E2E_EMAIL') as string);
    cy.clerkUserId().then((id) => (ownerId = id));
    cy.createPetViaApi(petName).then((id) => (petId = id));
    // Entro como cuidador uma vez — garante conta + profile (webhook).
    cy.signInAs(CG_EMAIL);
    cy.clerkUserId().then((cgId) => {
      cy.wait(4000); // propagacao do profile via clerk-webhook
      cy.signInAs(Cypress.expose('E2E_EMAIL') as string);
      cy.createActiveCaregiverViaApi(petId, cgId, CG_EMAIL, [
        'view',
        'mark_dose',
        'manage_pets',
      ]);
    });
  });

  after(() => {
    // A sessao fica no cuidador — voltar ao dono para apagar os pets.
    cy.signInAs(Cypress.expose('E2E_EMAIL') as string);
    cy.cleanupTestPets('CgPet E2E');
    cy.cleanupTestPets('CgAdd E2E');
  });

  it('insere, edita e elimina animais com autorizacao do dono', () => {
    cy.signInAs(CG_EMAIL);
    cy.sbRest('POST', 'pets', '', {
      owner_id: ownerId,
      name: cgPetName,
      species: 'cat',
    }).then((rows) => {
      const newPetId = rows[0].id as string;
      cy.sbRest('PATCH', 'pets', `id=eq.${newPetId}`, { breed: 'Siames' });
      cy.sbRest('DELETE', 'pets', `id=eq.${newPetId}`);
    });
    cy.sbRest('GET', 'pets', `select=id&name=eq.${cgPetName}`).should(
      'have.length',
      0,
    );
  });
});
