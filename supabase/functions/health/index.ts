// Edge Function: health
// Endpoint publico de health check para o UptimeRobot.
// Nao requer autenticacao. Retorna 200 OK se o Supabase estiver funcionando.

Deno.serve(async (req) => {
  // Verifica se o Postgres responde
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const resp = await fetch(`${supabaseUrl}/rest/v1/keep_alive?select=id&limit=1`, {
      headers: {
        "apikey": serviceKey,
        "Authorization": `Bearer ${serviceKey}`,
      },
    });

    if (resp.ok) {
      return new Response(
        JSON.stringify({ status: "ok", database: "up" }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    } else {
      return new Response(
        JSON.stringify({ status: "error", database: "down", code: resp.status }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }
  } catch (e) {
    return new Response(
      JSON.stringify({ status: "error", message: String(e) }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
