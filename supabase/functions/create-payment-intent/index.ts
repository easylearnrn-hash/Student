/**
 * ARNOMA – create-payment-intent Edge Function
 *
 * Called by payment.html to create a Stripe PaymentIntent and
 * return the clientSecret to the browser.
 *
 * Environment secrets (set in Supabase Dashboard → Settings → Edge Functions):
 *   STRIPE_SECRET_KEY   – your sk_live_... key (NEVER in client code)
 *
 * Deploy:
 *   supabase functions deploy create-payment-intent --no-verify-jwt
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY') ?? '';

const CORS = {
  'Access-Control-Allow-Origin' : '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

serve(async (req: Request) => {
  // Preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS });
  }

  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: CORS });
  }

  if (!STRIPE_SECRET_KEY) {
    console.error('STRIPE_SECRET_KEY env var is missing');
    return new Response(
      JSON.stringify({ error: 'Payment service not configured.' }),
      { status: 500, headers: { ...CORS, 'Content-Type': 'application/json' } },
    );
  }

  let body: {
    amount_cents : number;
    currency     : string;
    student_id   : string;
    student_name : string;
    student_email: string;
    invoice_ref  : string;
    for_class    ?: string;
  };

  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({ error: 'Invalid JSON body.' }),
      { status: 400, headers: { ...CORS, 'Content-Type': 'application/json' } },
    );
  }

  const { amount_cents, currency, student_id, student_name, student_email, invoice_ref, for_class } = body;

  if (!amount_cents || amount_cents < 50) {
    // Stripe minimum is 50 cents
    return new Response(
      JSON.stringify({ error: 'Amount must be at least $0.50.' }),
      { status: 400, headers: { ...CORS, 'Content-Type': 'application/json' } },
    );
  }

  // Build Stripe PaymentIntent via REST API
  const stripeBody = new URLSearchParams({
    amount               : String(amount_cents),
    currency             : (currency || 'usd').toLowerCase(),
    'automatic_payment_methods[enabled]': 'true',
    description          : `ARNOMA class payment – ${student_name || 'Student'}`,
    'metadata[student_id]'  : student_id    || '',
    'metadata[invoice_ref]' : invoice_ref   || '',
    'metadata[student_name]': student_name  || '',
    'metadata[for_class]'   : for_class     || '',
  });

  if (student_email) {
    stripeBody.set('receipt_email', student_email);
  }

  const stripeResp = await fetch('https://api.stripe.com/v1/payment_intents', {
    method : 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type' : 'application/x-www-form-urlencoded',
    },
    body: stripeBody.toString(),
  });

  const stripeData = await stripeResp.json();

  if (!stripeResp.ok) {
    console.error('Stripe error:', stripeData);
    return new Response(
      JSON.stringify({ error: stripeData?.error?.message ?? 'Stripe error' }),
      { status: 502, headers: { ...CORS, 'Content-Type': 'application/json' } },
    );
  }

  return new Response(
    JSON.stringify({ clientSecret: stripeData.client_secret }),
    { status: 200, headers: { ...CORS, 'Content-Type': 'application/json' } },
  );
});
