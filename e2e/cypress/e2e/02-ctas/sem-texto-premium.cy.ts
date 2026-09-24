/// <reference types="cypress" />

// Funcionalidade: Convites para criar conta
//   Cenario: Nao existe publicidade a planos pagos
//     Dado que a aplicacao e gratuita
//     Entao nenhuma pagina publica mostra precos, "premium" ou trial
describe('Convites para criar conta', () => {
  it('não há texto de planos pagos visível — a app é gratuita', () => {
    for (const path of ['./', 'pricing.html', 'terms.html']) {
      cy.visit(path);
      cy.get('body')
        .invoke('text')
        .should(
          'not.match',
          /premium|1,99|19,99|teste gratis|14 dias de teste|experimentar 14 dias/i,
        );
    }
  });
});
