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

/** Format a YYYY-MM-DD string as "Jun 12, 2026" */
function formatClassDate(dateStr: string): string {
  try {
    const [year, month, day] = dateStr.split('-').map(Number);
    const d = new Date(year, month - 1, day);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  } catch {
    return dateStr;
  }
}

/** Find or create a Stripe Customer keyed by our internal student_id.
 *  Returns the Stripe customer ID string, or null on failure. */
async function findOrCreateStripeCustomer(
  studentId: string,
  studentName: string,
  studentEmail: string,
): Promise<string | null> {
  const headers = {
    'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
    'Content-Type' : 'application/x-www-form-urlencoded',
  };

  // 1. Search for existing customer by arnoma_student_id metadata
  const searchQuery = encodeURIComponent(`metadata['arnoma_student_id']:'${studentId}'`);
  const searchResp = await fetch(
    `https://api.stripe.com/v1/customers/search?query=${searchQuery}&limit=1`,
    { headers },
  );
  if (searchResp.ok) {
    const searchData = await searchResp.json();
    if (searchData.data && searchData.data.length > 0) {
      const existing = searchData.data[0];
      // Update name if it changed
      if (existing.name !== studentName && studentName) {
        await fetch(`https://api.stripe.com/v1/customers/${existing.id}`, {
          method : 'POST',
          headers,
          body   : new URLSearchParams({ name: studentName }).toString(),
        });
      }
      return existing.id;
    }
  }

  // 2. Create new customer
  const createBody = new URLSearchParams({
    name                          : studentName || 'Student',
    'metadata[arnoma_student_id]' : studentId,
  });
  if (studentEmail) createBody.set('email', studentEmail);

  const createResp = await fetch('https://api.stripe.com/v1/customers', {
    method : 'POST',
    headers,
    body   : createBody.toString(),
  });
  if (createResp.ok) {
    const createData = await createResp.json();
    return createData.id ?? null;
  }

  console.error('Failed to create Stripe customer:', await createResp.text());
  return null;
}

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
    amount_cents     : number;
    currency         : string;
    student_id       : string;
    student_name     : string;
    student_email    : string;
    invoice_ref      : string;
    group_name      ?: string;
    for_class       ?: string;
    for_class_dates ?: string;
  };

  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({ error: 'Invalid JSON body.' }),
      { status: 400, headers: { ...CORS, 'Content-Type': 'application/json' } },
    );
  }

  const {
    amount_cents, currency, student_id, student_name, student_email,
    invoice_ref, group_name, for_class, for_class_dates,
  } = body;

  if (!amount_cents || amount_cents < 50) {
    return new Response(
      JSON.stringify({ error: 'Amount must be at least $0.50.' }),
      { status: 400, headers: { ...CORS, 'Content-Type': 'application/json' } },
    );
  }

  // ── Build human-readable description ──────────────────────────────────────
  // Parse class dates for display
  let classDatesArr: string[] = [];
  if (for_class_dates) {
    try { classDatesArr = (JSON.parse(for_class_dates) as string[]).filter(Boolean); } catch { /* ignore */ }
  }
  if (classDatesArr.length === 0 && for_class) {
    classDatesArr = for_class.split(',').map((d: string) => d.trim()).filter(Boolean);
  }

  const groupLabel = group_name ? ` Group ${group_name}` : '';
  let dateLabel = '';
  if (classDatesArr.length === 1) {
    dateLabel = ` for class ${formatClassDate(classDatesArr[0])}`;
  } else if (classDatesArr.length > 1) {
    dateLabel = ` for ${classDatesArr.length} classes (${formatClassDate(classDatesArr[0])} – ${formatClassDate(classDatesArr[classDatesArr.length - 1])})`;
  }
  const description = `ARNOMA class payment – ${student_name || 'Student'}${groupLabel}${dateLabel}`;

  // ── Find or create Stripe Customer (keyed by our student_id) ──────────────
  let stripeCustomerId: string | null = null;
  if (student_id) {
    stripeCustomerId = await findOrCreateStripeCustomer(student_id, student_name, student_email);
  }

  // ── Build PaymentIntent ───────────────────────────────────────────────────
  const paymentDate = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
  const stripeBody = new URLSearchParams({
    amount                            : String(amount_cents),
    currency                          : (currency || 'usd').toLowerCase(),
    'automatic_payment_methods[enabled]': 'true',
    description                       : description,
    'metadata[arnoma_student_id]'     : student_id       || '',
    'metadata[student_name]'          : student_name     || '',
    'metadata[student_email]'         : student_email    || '',
    'metadata[group_name]'            : group_name       || '',
    'metadata[invoice_ref]'           : invoice_ref      || '',
    'metadata[payment_date]'          : paymentDate,
    'metadata[for_class]'             : for_class        || '',
    'metadata[for_class_dates]'       : classDatesArr.join(','),
    'metadata[class_count]'           : String(classDatesArr.length || 1),
  });

  if (stripeCustomerId) {
    stripeBody.set('customer', stripeCustomerId);
  }
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
