// Verificacao de JWT Clerk nas Edge Functions.
//
// ATENCAO: o GoTrue deste projecto rejeita tokens RS256 de terceiros
// (/auth/v1/user -> "bad_jwt: signing method RS256 is invalid"), por
// isso `supabase.auth.getUser()` NAO funciona com Clerk JWTs.
// A verificacao faz-se aqui: assinatura RS256 contra o JWKS do issuer
// Clerk, com check de iss + exp (jwtVerify valida exp/nbf).

import { createRemoteJWKSet, jwtVerify } from 'https://esm.sh/jose@5.9.6'

const ISSUER =
  Deno.env.get('CLERK_ISSUER') ??
  'https://climbing-burro-4910.clerk.accounts.dev'

const JWKS = createRemoteJWKSet(new URL(`${ISSUER}/.well-known/jwks.json`))

// Devolve o `sub` do Clerk se o token for valido, senao null.
export async function clerkUserId(jwt: string): Promise<string | null> {
  try {
    const { payload } = await jwtVerify(jwt, JWKS, { issuer: ISSUER })
    return typeof payload.sub === 'string' && payload.sub ? payload.sub : null
  } catch {
    return null
  }
}
