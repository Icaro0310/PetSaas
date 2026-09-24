/// <reference types="cypress" />

// Funcionalidade: Site resistente a falhas
//   Cenario: Links para outros sites nao comprometem a pagina
//     Dado que a pagina tem links que abrem num separador novo
//     Entao esses links usam a protecao "noopener"
describe('Site resistente a falhas', () => {
  it('links externos em novo separador usam rel="noopener"', () => {
    cy.visit('./');
    // Se a pagina nao tiver links target=_blank, o teste passa
    // vacuamente — a protecao fica garantida para links futuros.
    cy.document().then((doc) => {
      const links = Array.from(
        doc.querySelectorAll('a[target="_blank"]'),
      );
      for (const a of links) {
        expect(a.getAttribute('rel') ?? '').to.include('noopener');
      }
    });
  });
});
