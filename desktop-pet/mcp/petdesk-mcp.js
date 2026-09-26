#!/usr/bin/env node
/* PetDeskSaas MCP adapter — stdio (NDJSON JSON-RPC), zero deps.
 * Le userData/petdesk-mcp.json {port, token} escrito pelo control server
 * da app e faz forward das tool calls para 127.0.0.1. */

const fs = require('fs');
const path = require('path');
const http = require('http');

const APPDATA = process.env.APPDATA || '';
const CONF_CANDIDATES = [
  path.join(APPDATA, 'petdesksaas', 'petdesk-mcp.json'),
  path.join(APPDATA, 'PetDeskSaas', 'petdesk-mcp.json'),
];

function loadConf() {
  for (const p of CONF_CANDIDATES) {
    try {
      return JSON.parse(fs.readFileSync(p, 'utf8'));
    } catch {}
  }
  return null;
}

function api(method, route, body) {
  return new Promise((resolve, reject) => {
    const conf = loadConf();
    if (!conf) {
      return reject(
        new Error('PetDeskSaas nao esta a correr (sem petdesk-mcp.json)')
      );
    }
    const data = body ? JSON.stringify(body) : null;
    const req = http.request(
      {
        host: '127.0.0.1',
        port: conf.port,
        path: route,
        method,
        headers: {
          authorization: `Bearer ${conf.token}`,
          ...(data
            ? { 'content-type': 'application/json', 'content-length': Buffer.byteLength(data) }
            : {}),
        },
        timeout: 5000,
      },
      (res) => {
        let out = '';
        res.on('data', (c) => (out += c));
        res.on('end', () => {
          try {
            resolve(JSON.parse(out));
          } catch {
            resolve({ raw: out });
          }
        });
      }
    );
    req.on('timeout', () => req.destroy(new Error('timeout')));
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

const TOOLS = [
  {
    name: 'pet_get_state',
    description: 'Estado atual do pet (modo, estado do sprite, pomodoro)',
    inputSchema: { type: 'object', properties: {} },
  },
  {
    name: 'pet_set_state',
    description: 'Muda o estado do pet (idle, walking, sleeping, waving, petted, playing, jumping, alert, sad, grooming, eating, thinking). ms opcional = duracao temporaria.',
    inputSchema: {
      type: 'object',
      properties: {
        state: { type: 'string' },
        ms: { type: 'number', description: 'duracao em ms (temporario)' },
      },
      required: ['state'],
    },
  },
  {
    name: 'pet_say',
    description: 'Mostra um speech bubble com texto (max 200 chars)',
    inputSchema: {
      type: 'object',
      properties: {
        text: { type: 'string' },
        ms: { type: 'number' },
      },
      required: ['text'],
    },
  },
  {
    name: 'pet_pomodoro',
    description: 'Inicia ou cancela o Pomodoro de 25 min',
    inputSchema: {
      type: 'object',
      properties: { action: { type: 'string', enum: ['start', 'cancel'] } },
      required: ['action'],
    },
  },
  {
    name: 'pet_show',
    description: 'Mostra o pet no desktop',
    inputSchema: { type: 'object', properties: {} },
  },
  {
    name: 'pet_hide',
    description: 'Esconde o pet (continua na tray)',
    inputSchema: { type: 'object', properties: {} },
  },
  {
    name: 'pet_list',
    description: 'Lista pets instalados',
    inputSchema: { type: 'object', properties: {} },
  },
  {
    name: 'pet_select',
    description: 'Troca o pet ativo por id',
    inputSchema: {
      type: 'object',
      properties: { id: { type: 'string' } },
      required: ['id'],
    },
  },
  {
    name: 'pet_install',
    description: 'Instala um .petpack (ZIP com pet.json + spritesheet) a partir de um path local',
    inputSchema: {
      type: 'object',
      properties: { path: { type: 'string' } },
      required: ['path'],
    },
  },
];

async function callTool(name, args = {}) {
  switch (name) {
    case 'pet_get_state':
      return api('GET', '/state');
    case 'pet_set_state':
      return api('POST', '/state', { state: args.state, ms: args.ms });
    case 'pet_say':
      return api('POST', '/say', { text: args.text, ms: args.ms });
    case 'pet_pomodoro':
      return api('POST', '/pomodoro', { action: args.action });
    case 'pet_show':
      return api('POST', '/show');
    case 'pet_hide':
      return api('POST', '/hide');
    case 'pet_list':
      return api('GET', '/pets');
    case 'pet_select':
      return api('POST', '/pet', { id: args.id });
    case 'pet_install':
      return api('POST', '/install-petpack', { path: args.path });
    default:
      throw new Error(`tool desconhecida: ${name}`);
  }
}

// ---- MCP stdio (NDJSON JSON-RPC) ---------------------------------------

const PROTOCOL_VERSION = '2024-11-05';

function send(msg) {
  process.stdout.write(JSON.stringify(msg) + '\n');
}

function sendResult(id, result) {
  send({ jsonrpc: '2.0', id, result });
}

function sendError(id, code, message) {
  send({ jsonrpc: '2.0', id, error: { code, message } });
}

let buffer = '';
process.stdin.on('data', (chunk) => {
  buffer += chunk;
  let idx;
  while ((idx = buffer.indexOf('\n')) >= 0) {
    const line = buffer.slice(0, idx).trim();
    buffer = buffer.slice(idx + 1);
    if (!line) continue;
    let msg;
    try {
      msg = JSON.parse(line);
    } catch {
      continue;
    }
    handle(msg);
  }
});

async function handle(msg) {
  if (msg.method && msg.id === undefined) return; // notification

  try {
    switch (msg.method) {
      case 'initialize':
        return sendResult(msg.id, {
          protocolVersion: PROTOCOL_VERSION,
          capabilities: { tools: {} },
          serverInfo: { name: 'petdesksaas', version: '0.1.0' },
        });
      case 'ping':
        return sendResult(msg.id, {});
      case 'tools/list':
        return sendResult(msg.id, { tools: TOOLS });
      case 'tools/call': {
        const { name, arguments: args } = msg.params || {};
        try {
          const result = await callTool(name, args);
          return sendResult(msg.id, {
            content: [{ type: 'text', text: JSON.stringify(result) }],
          });
        } catch (e) {
          return sendResult(msg.id, {
            content: [{ type: 'text', text: String(e.message || e) }],
            isError: true,
          });
        }
      }
      default:
        return sendError(msg.id, -32601, `metodo desconhecido: ${msg.method}`);
    }
  } catch (e) {
    return sendError(msg.id, -32603, String(e.message || e));
  }
}
