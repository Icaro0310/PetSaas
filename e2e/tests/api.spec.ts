import { test, expect } from '@playwright/test';
import {
  SUBSCRIBE_URL,
  ALLOWED_ORIGIN,
  SB_URL,
  SB_ANON_KEY,
} from '../playwright.config';

// Testes de API/seguranca correm so no projeto desktop para nao duplicar
// chamadas a Edge Function (rate limit: 5 inserts/hora por IP).
test.describe('Edge Function subscribe - API e seguranca', () => {
  test.beforeEach(async ({}, testInfo) => {
    test.skip(
      testInfo.project.name !== 'desktop',
      'API tests correm apenas no desktop'
    );
  });

  test('OPTIONS preflight devolve 204 com CORS', async ({ request }) => {
    const res = await request.fetch(SUBSCRIBE_URL, {
      method: 'OPTIONS',
      headers: { Origin: ALLOWED_ORIGIN },
    });
    expect(res.status()).toBe(204);
    expect(res.headers()['access-control-allow-origin']).toBeTruthy();
  });

  test('GET nao e permitido (405)', async ({ request }) => {
    const res = await request.fetch(SUBSCRIBE_URL, {
      method: 'GET',
      headers: { Origin: ALLOWED_ORIGIN },
    });
    expect(res.status()).toBe(405);
  });

  test('email invalido -> 400', async ({ request }) => {
    const res = await request.post(SUBSCRIBE_URL, {
      headers: { Origin: ALLOWED_ORIGIN },
      data: { email: 'invalido' },
    });
    expect(res.status()).toBe(400);
  });

  test('payload com campo extra -> 400 (schema strict)', async ({
    request,
  }) => {
    const res = await request.post(SUBSCRIBE_URL, {
      headers: { Origin: ALLOWED_ORIGIN },
      data: { email: 'e2e+website@petcare.dev', hack: true },
    });
    expect(res.status()).toBe(400);
  });

  test('email valido -> 200 success', async ({ request }) => {
    const res = await request.post(SUBSCRIBE_URL, {
      headers: { Origin: ALLOWED_ORIGIN },
      data: { email: 'e2e+website@petcare.dev', source: 'e2e' },
    });
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.success).toBe(true);
  });

  test('RLS: anon nao le a waitlist', async ({ request }) => {
    const res = await request.get(`${SB_URL}/rest/v1/waitlist?select=*`, {
      headers: {
        apikey: SB_ANON_KEY,
        Authorization: `Bearer ${SB_ANON_KEY}`,
      },
    });
    expect(res.status()).toBe(200);
    expect(await res.json()).toEqual([]); // sem rows visiveis para anon
  });

  test('RLS: anon nao escreve na waitlist', async ({ request }) => {
    const res = await request.post(`${SB_URL}/rest/v1/waitlist`, {
      headers: {
        apikey: SB_ANON_KEY,
        Authorization: `Bearer ${SB_ANON_KEY}`,
        'Content-Type': 'application/json',
      },
      data: { email: 'e2e-anon@petcare.dev' },
    });
    expect([401, 403]).toContain(res.status());
  });

  test('health Edge Function responde ok', async ({ request }) => {
    const res = await request.get(`${SB_URL}/functions/v1/health`);
    expect(res.status()).toBe(200);
    const body = await res.json();
    expect(body.status).toBe('ok');
  });
});
