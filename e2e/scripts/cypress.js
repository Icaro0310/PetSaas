#!/usr/bin/env node
/**
 * Launcher do Cypress que remove ELECTRON_RUN_AS_NODE.
 *
 * Esta maquina tem ELECTRON_RUN_AS_NODE=1 definido globalmente — com a
 * variavel presente, o binario Electron do Cypress corre como Node e
 * falha com "bad option: --smoke-test". Usar sempre via npm scripts:
 *   npm test / npm run test:headed / npm run test:open
 */
delete process.env.ELECTRON_RUN_AS_NODE;

const { spawnSync } = require('child_process');
const args = process.argv.slice(2);
const cmd = `npx cypress ${args.join(' ')}`;
const res = spawnSync(cmd, {
  stdio: 'inherit',
  shell: true,
  env: process.env,
});
process.exit(res.status ?? 1);
