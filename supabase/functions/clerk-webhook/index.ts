// Edge Function: clerk-webhook
// Recebe webhooks do Clerk (user.created, user.updated, user.deleted)
// e sincroniza os dados do utilizador na tabela profiles do Supabase.
//
// Configurar no Clerk Dashboard:
//   Endpoint: https://dotplnbakltelacsxvjz.supabase.co/functions/v1/clerk-webhook
//   Events: user.created, user.updated, user.deleted
//
// Seguranca: valida assinatura Svix do Clerk usando Webhook.verify.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { Webhook } from "https://esm.sh/svix@1.24.0";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const CLERK_WEBHOOK_SECRET = Deno.env.get("CLERK_WEBHOOK_SECRET");

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  // Verifica assinatura Svix do webhook.
  // O Clerk assina cada webhook com o secret configurado no Dashboard.
  // Sem isto, qualquer pessoa que descubra o URL pode enviar webhooks falsos.
  if (!CLERK_WEBHOOK_SECRET) {
    console.error("CLERK_WEBHOOK_SECRET nao configurado");
    return new Response("Webhook secret not configured", { status: 500 });
  }

  const svixId = req.headers.get("svix-id");
  const svixTimestamp = req.headers.get("svix-timestamp");
  const svixSignature = req.headers.get("svix-signature");

  if (!svixId || !svixTimestamp || !svixSignature) {
    return new Response("Missing Svix headers", { status: 400 });
  }

  const body = await req.text();

  const wh = new Webhook(CLERK_WEBHOOK_SECRET);
  let payload: any;
  try {
    payload = wh.verify(body, {
      "svix-id": svixId,
      "svix-timestamp": svixTimestamp,
      "svix-signature": svixSignature,
    });
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    return new Response("Invalid signature", { status: 401 });
  }

  const eventType = payload.type;
  const user = payload.data;

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
