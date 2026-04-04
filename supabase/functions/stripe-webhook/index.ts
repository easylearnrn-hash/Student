/**
 * ARNOMA – stripe-webhook Edge Function
 *
 * Listens for Stripe webhook events and updates Supabase payment_records.
 *
 * Environment secrets (set in Supabase Dashboard → Settings → Edge Functions):
 *   STRIPE_SECRET_KEY       – sk_live_... (to verify the webhook signature)
 *   STRIPE_WEBHOOK_SECRET   – whsec_... (from Stripe Dashboard → Webhooks)
 *   SUPABASE_URL            – your project URL
 *   SUPABASE_SERVICE_ROLE_KEY – service role key (bypasses RLS for DB writes)
 *
 * Deploy:
 *   supabase functions deploy stripe-webhook --no-verify-jwt
 *
 * In Stripe Dashboard → Developers → Webhooks → Add endpoint:
 *   URL: https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/stripe-webhook
 *   Events: payment_intent.succeeded
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.1';

const STRIPE_SECRET_KEY     = Deno.env.get('STRIPE_SECRET_KEY')       ?? '';
const STRIPE_WEBHOOK_SECRET = Deno.env.get('STRIPE_WEBHOOK_SECRET')   ?? '';
const SUPABASE_URL          = Deno.env.get('DB_URL')                  ?? '';
const SERVICE_ROLE_KEY      = Deno.env.get('DB_SERVICE_ROLE_KEY')     ?? '';

const CORS = {
  'Access-Control-Allow-Origin' : '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, stripe-signature',
};

// Stripe webhook signature verification (Deno-native crypto)
async function verifyStripeSignature(
  payload: string,
  sigHeader: string,
  secret: string,
): Promise<boolean> {
  const parts  = sigHeader.split(',');
  const tPart  = parts.find((p) => p.startsWith('t='));
  const v1Part = parts.find((p) => p.startsWith('v1='));
  if (!tPart || !v1Part) return false;

  const timestamp  = tPart.slice(2);
  const v1Received = v1Part.slice(3);
  const signed     = `${timestamp}.${payload}`;

  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const sig    = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(signed));
  const v1Expected = Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');

  return v1Expected === v1Received;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405, headers: CORS });

  const rawBody   = await req.text();
  const sigHeader = req.headers.get('stripe-signature') ?? '';

  // Verify webhook authenticity
  const valid = STRIPE_WEBHOOK_SECRET
    ? await verifyStripeSignature(rawBody, sigHeader, STRIPE_WEBHOOK_SECRET)
    : false;

  if (!valid) {
    console.warn('⚠️ Invalid Stripe webhook signature');
    return new Response(JSON.stringify({ error: 'Invalid signature' }), {
      status: 400,
      headers: { ...CORS, 'Content-Type': 'application/json' },
    });
  }

  let event: { type: string; data: { object: Record<string, unknown> } };
  try {
    event = JSON.parse(rawBody);
  } catch {
    return new Response(JSON.stringify({ error: 'Bad JSON' }), { status: 400, headers: CORS });
  }

  // ── Handle payment_intent.succeeded ──────────────────────────────────────
  if (event.type === 'payment_intent.succeeded') {
    const pi = event.data.object as {
      id         : string;
      amount     : number;
      currency   : string;
      metadata   : { student_id?: string; invoice_ref?: string; student_name?: string; for_class?: string };
      receipt_email: string | null;
    };

    const { student_id, invoice_ref, for_class } = pi.metadata ?? {};
    const amountDollars = pi.amount / 100;

    console.log(`✅ PaymentIntent succeeded: ${pi.id} | student: ${student_id} | $${amountDollars}`);

    if (student_id && SUPABASE_URL && SERVICE_ROLE_KEY) {
      const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
      
      const forClassArray = for_class ? for_class.split(',').map((d: string) => d.trim()).filter(Boolean) : [];

      // Insert a paid record in payment_records
      const { error } = await supabaseAdmin.from('payment_records').insert({
        student_id    : student_id,
        amount        : amountDollars,
        status        : 'paid',
        payment_method: 'Stripe',
        date          : forClassArray.length > 0 ? forClassArray[0] : new Date().toISOString().split('T')[0],
        for_class_dates: forClassArray.length > 0 ? forClassArray : undefined,
        notes         : invoice_ref ? `Stripe PI: ${pi.id} | Ref: ${invoice_ref}` : `Stripe PI: ${pi.id}`,
      });

      if (error) {
        console.error('❌ Supabase insert error:', error);
      } else {
        console.log(`✅ payment_records row inserted for student ${student_id}`);
      }
    }
  }

  return new Response(JSON.stringify({ received: true }), {
    status: 200,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });
});
