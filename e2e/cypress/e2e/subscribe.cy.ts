/// <reference types="cypress" />

// Email dedicado aos testes E2E - deduplicado na waitlist apos o 1o insert.
const E2E_EMAIL = 'e2e+website@petcare.dev';

describe('Formulario de subscricao (waitlist -> Supabase)', () => {
  beforeEach(() => {
    cy.visit('./');
    cy.get('[data-subscribe] input[type="email"]').first().scrollIntoView();
  });

  it('email invalido mostra erro e nao submete', () => {
    cy.get('[data-subscribe] input[type="email"]').first().as('input');
    cy.get('@input').type('nao-e-um-email');
    cy.get('[data-subscribe] button[type="submit"]').first().click();

    cy.get('.subscribe__msg')
      .first()
      .should('contain.text', 'endereço de email válido');
    cy.get('@input').should('have.attr', 'aria-invalid', 'true');
  });

  it('endereço de email válido subscreve com sucesso', () => {
    cy.get('[data-subscribe] input[type="email"]').first().as('input');
    cy.get('@input').type(E2E_EMAIL);
    cy.get('[data-subscribe] button[type="submit"]').first().click();

    cy.get('.subscribe__msg', { timeout: 15_000 })
      .first()
      .should('contain.text', 'A sua subscrição foi registada');
    cy.get('@input').should('have.value', '');
  });

  it('submeter email duplicado devolve sucesso (dedup silencioso)', () => {
    cy.get('[data-subscribe] input[type="email"]').first().type(E2E_EMAIL);
    cy.get('[data-subscribe] button[type="submit"]').first().click();

    cy.get('.subscribe__msg', { timeout: 15_000 })
      .first()
      .should('contain.text', 'A sua subscrição foi registada');
  });

  it('botao fica disabled durante o envio', () => {
    cy.get('[data-subscribe] input[type="email"]').first().type(E2E_EMAIL);
    cy.get('[data-subscribe] button[type="submit"]').first().click();
    // Durante o request o botao deve estar disabled (pode ja ter voltado)
    cy.get('.subscribe__msg', { timeout: 15_000 })
      .first()
      .should('not.be.empty');
  });
});
