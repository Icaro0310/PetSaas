import { app } from 'electron';
import * as http from 'http';
import * as crypto from 'crypto';
import * as path from 'path';
import * as fs from 'fs';
import { AddressInfo } from 'net';

export interface ControlHandlers {
  getState: () => unknown;
  setState: (state: string, ms?: number) => void;
  say: (text: string, ms?: number) => void;
  startPomodoro: () => void;
  cancelPomodoro: () => void;
  show: () => void;
  hide: () => void;
  listPets: () => unknown;
  setPet: (id: string) => boolean;
  installPetpack: (zipPath: string) => Promise<unknown>;
}

const MAX_BODY = 16 * 1024;

/**
 * Servidor de controlo local: loopback only, Bearer token aleatorio por
 * sessao. Escreve userData/petdesk-mcp.json para o adapter MCP descobrir
 * porta+token. Sem auth -> 401; fora de loopback nem sequer escuta.
 */
export function startControlServer(handlers: ControlHandlers): http.Server {
  const token = crypto.randomBytes(24).toString('hex');

  const server = http.createServer((req, res) => {
    const reply = (code: number, body: unknown) => {
      const json = JSON.stringify(body);
      res.writeHead(code, {
        'content-type': 'application/json',
        'content-length': Buffer.byteLength(json),
      });
      res.end(json);
    };

    if (req.headers.authorization !== `Bearer ${token}`) {
      return reply(401, { error: 'unauthorized' });
    }

    const url = new URL(req.url ?? '/', 'http://127.0.0.1');

    if (req.method === 'GET' && url.pathname === '/state') {
      return reply(200, handlers.getState());
    }
    if (req.method === 'GET' && url.pathname === '/pets') {
      return reply(200, handlers.listPets());
    }
    if (req.method !== 'POST') {
      return reply(404, { error: 'not found' });
    }

    let body = '';
    let tooBig = false;
    req.on('data', (c) => {
      body += c;
      if (body.length > MAX_BODY) {
        tooBig = true;
        req.destroy();
      }
    });
    req.on('end', async () => {
      if (tooBig) return;
      let payload: Record<string, unknown> = {};
      try {
        if (body) payload = JSON.parse(body);
      } catch {
        return reply(400, { error: 'invalid json' });
      }

      try {
        switch (url.pathname) {
        case '/state': {
          const s = payload.state;
          if (typeof s !== 'string' || !/^[a-z_-]{1,32}$/.test(s)) {
            return reply(400, { error: 'state invalido' });
          }
          const ms =
            typeof payload.ms === 'number' && payload.ms > 0 && payload.ms <= 60_000
              ? payload.ms
              : undefined;
          handlers.setState(s, ms);
          return reply(200, { ok: true });
        }
        case '/say': {
          const t = payload.text;
          if (typeof t !== 'string' || t.length === 0 || t.length > 200) {
            return reply(400, { error: 'text invalido' });
          }
          handlers.say(t, typeof payload.ms === 'number' ? payload.ms : 3000);
          return reply(200, { ok: true });
        }
        case '/pomodoro': {
          if (payload.action === 'start') handlers.startPomodoro();
          else if (payload.action === 'cancel') handlers.cancelPomodoro();
          else return reply(400, { error: 'action: start|cancel' });
          return reply(200, { ok: true });
        }
        case '/show':
          handlers.show();
          return reply(200, { ok: true });
        case '/hide':
          handlers.hide();
          return reply(200, { ok: true });
        case '/pet': {
          const id = payload.id;
          if (typeof id !== 'string') {
            return reply(400, { error: 'id em falta' });
          }
          return handlers.setPet(id)
            ? reply(200, { ok: true })
            : reply(404, { error: 'pet desconhecido' });
        }
        case '/install-petpack': {
          const p = payload.path;
          if (typeof p !== 'string' || !fs.existsSync(p)) {
            return reply(400, { error: 'path inexistente' });
          }
          const res = await handlers.installPetpack(p);
          return reply(200, res);
        }
        default:
          return reply(404, { error: 'not found' });
        }
      } catch (e) {
        return reply(500, { error: String((e as Error).message || e) });
      }
    });
  });

  server.listen(0, '127.0.0.1', () => {
    const { port } = server.address() as AddressInfo;
    const file = path.join(app.getPath('userData'), 'petdesk-mcp.json');
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, JSON.stringify({ port, token }), { mode: 0o600 });
  });

  server.on('close', () => {
    try {
      fs.unlinkSync(path.join(app.getPath('userData'), 'petdesk-mcp.json'));
    } catch {
      /* ja removido */
    }
  });

  return server;
}
