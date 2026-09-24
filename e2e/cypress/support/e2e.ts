// Support global — carregado antes de cada spec.
import './commands';
import 'cypress-real-events';

// A app Flutter lanca erros nao fatais durante transicoes de rota e
// callbacks async (ex.: streams canceladas, null-check em listeners).
// Ignora-os globalmente — os testes que querem detetar erros de pagina
// (site.cy.ts) registam o seu proprio listener e acumulam para assert.
Cypress.on('uncaught:exception', () => false);
