// Email de boas-vindas enviado via MailerSend API apos nova inscricao.
// Seguranca: o token vive apenas em secrets do Supabase (servidor).

const MAILERSEND_API = 'https://api.mailersend.com/v1/email'
const APP_URL = 'https://moonlit-pothos-c56cd4.netlify.app/'

function welcomeHtml(email: string): string {
  return `<!doctype html>
<html lang="pt">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#FAFBF6;font-family:Inter,Segoe UI,Arial,sans-serif;color:#1E2B1E">
  <div style="max-width:560px;margin:0 auto;padding:32px 20px">
    <div style="text-align:center;margin-bottom:24px">
      <div style="display:inline-block;background:#2E7D32;border-radius:14px;width:44px;height:44px;line-height:44px;font-size:22px;color:#fff">&#128062;</div>
      <div style="font-size:20px;font-weight:700;margin-top:8px">PetCare</div>
    </div>
    <div style="background:#fff;border:1px solid #E4E9DF;border-radius:16px;padding:32px 28px">
      <h1 style="font-size:22px;margin:0 0 12px">Bem-vindo ao PetCare!</h1>
      <p style="font-size:15px;line-height:1.6;margin:0 0 16px">
        A tua inscricao foi confirmada. O PetCare e <strong>100% gratuito</strong> e ja podes comecar a usar:
      </p>
      <ul style="font-size:15px;line-height:1.8;margin:0 0 24px;padding-left:20px">
        <li>Saber quando o teu pet tomou medicacao e foi passear</li>
        <li>Convidar cuidadores para ajudar nos cuidados</li>
        <li>QR Code unico na coleira - encontra-lo mais rapido se se perder</li>
      </ul>
      <div style="text-align:center;margin-bottom:16px">
        <a href="${APP_URL}" style="display:inline-block;background:#2E7D32;color:#fff;text-decoration:none;font-weight:600;font-size:16px;padding:14px 32px;border-radius:12px">Criar a minha conta gratis</a>
      </div>
      <p style="font-size:13px;color:#4E5D4B;text-align:center;margin:0">
        Gratuito. Sem cartao de credito.
      </p>
    </div>
    <p style="font-size:12px;color:#4E5D4B;text-align:center;margin-top:24px">
      Recebeste este email porque ${email} se inscreveu em
      <a href="https://icaro0310.github.io/PetSaas/" style="color:#2E7D32">petcare</a>.
      Se nao foste tu, podes ignorar esta mensagem.
    </p>
  </div>
</body>
</html>`
}

function welcomeText(email: string): string {
  return `Bem-vindo ao PetCare!

A tua inscricao foi confirmada. O PetCare e 100% gratuito e ja podes comecar a usar:

- Saber quando o teu pet tomou medicacao e foi passear
- Convidar cuidadores para ajudar nos cuidados
- QR Code unico na coleira - encontra-lo mais rapido se se perder

Cria a tua conta gratis em ${APP_URL}

Gratuito. Sem cartao de credito.

Recebeste este email porque ${email} se inscreveu no site do PetCare.
Se nao foste tu, podes ignorar esta mensagem.`
}

export async function sendWelcomeEmail(email: string): Promise<boolean> {
  const token = Deno.env.get('MAILERSEND_API_TOKEN')
  const from = Deno.env.get('MAILERSEND_FROM_ADDRESS')
    ?? 'noreply@test-z0vklo638kvl7qrx.mlsender.net'
  if (!token) return false

  try {
    const res = await fetch(MAILERSEND_API, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: { email: from, name: 'PetCare' },
        to: [{ email }],
        subject: 'Bem-vindo ao PetCare!',
        text: welcomeText(email),
        html: welcomeHtml(email),
      }),
    })
    if (!res.ok) {
      console.error('mailersend send failed:', res.status)
      return false
    }
    return true
  } catch (e) {
    console.error('mailersend send error:', (e as Error).message)
    return false
  }
}
