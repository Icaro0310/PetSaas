// Edge Function: clerk-webhook
// Recebe webhooks do Clerk (user.created, user.updated, user.deleted)
// e sincroniza os dados do utilizador na tabela profiles do Supabase.
//
// Configurar no Clerk Dashboard:
//   Endpoint: https://dotplnbakltelacsxvjz.supabase.co/functions/v1/clerk-webhook
//   Events: user.created, user.updated, user.deleted

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const CLERK_WEBHOOK_SECRET = Deno.env.get("CLERK_WEBHOOK_SECRET");

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const payload = await req.json();
  const eventType = payload.type;
  const user = payload.data;

  // TODO: verificar assinatura do webhook com CLERK_WEBHOOK_SECRET
  // Por agora, confiamos no URL secreto da edge function.

  try {
    if (eventType === "user.created" || eventType === "user.updated") {
      const { error } = await supabase
        .from("profiles")
        .upsert({
          id: user.id,
          email: user.email_addresses?.[0]?.email_address ?? null,
          full_name: [user.first_name, user.last_name]
            .filter(Boolean)
            .join(" ") || null,
          phone: user.phone_numbers?.[0]?.phone_number ?? null,
          updated_at: new Date().toISOString(),
        });

      if (error) {
        console.error("Upsert error:", error);
        return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
        });
      }
    } else if (eventType === "user.deleted") {
      const { error } = await supabase
        .from("profiles")
        .delete()
        .eq("id", user.id);

      if (error) {
        console.error("Delete error:", error);
        return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
        });
      }
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("Webhook error:", e);
    return new Response(JSON.stringify({ error: "Internal error" }), {
      status: 500,
    });
  }
});
