/// <reference types="cypress" />

// Funcionalidade: Site resistente a falhas
//   Cenario: Uma pagina que nao existe mostra o erro 404
//     Dado que um visitante abre um endereco inexistente
//     Entao o servidor responde 404 e o site mostra a pagina de erro
describe('Site resistente a falhas', () => {
  it('um endereço inexistente devolve a página 404', () => {
    cy.request({
      url: `${Cypress.expose('SITE_URL')}/pagina-que-nao-existe-${Date.now()}`,
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(404);
      // GitHub Pages serve o 404.html com a lógica SPA — verificamos
      // que o conteudo e a pagina de erro do site.
      expect(res.body).to.match(/404|não encontrada|not found/i);
    });
  });
});
