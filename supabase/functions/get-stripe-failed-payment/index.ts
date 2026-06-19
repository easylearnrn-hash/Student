/**
 * ARNOMA – get-stripe-failed-payment Edge Function
 *
 * Looks up the most recent failed Stripe charge for a student.
 * Called by Calendar-NEW.html when admin selects "Payment Failed Notice" email.
 *
 * Environment secrets (set in Supabase Dashboard → Settings → Edge Functions):
 *   STRIPE_SECRET_KEY  – sk_live_... key
 *
 * Deploy:
 *   supabase functions deploy get-stripe-failed-payment --no-verify-jwt
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY') ?? '';

const CORS = {
  'Access-Control-Allow-Origin' : '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: CORS });
  }

  if (!STRIPE_SECRET_KEY) {
    return new Response(
      JSON.stringify({ found: false, error: 'Stripe not configured on server' }),
      { status: 503, headers: { ...CORS, 'Content-Type': 'application/json' } },
    );
  }

  let studentId: string;
  let studentEmail: string;
  try {
    const body = await req.json();
    studentId   = String(body.student_id    || '').trim();
    studentEmail = String(body.student_email || '').trim();
    if (!studentId && !studentEmail) throw new Error('student_id or student_email required');
  } catch {
    return new Response(
      JSON.stringify({ found: false, error: 'Invalid request body — student_id required' }),
      { status: 400, headers: { ...CORS, 'Content-Type': 'application/json' } },
    );
  }

  const stripeHeaders = {
    'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
    'Content-Type' : 'application/x-www-form-urlencoded',
  };

  try {
    // ── 1. Find Stripe customer — try metadata first, then email ──────────
    let customerId: string | null = null;

    if (studentId) {
      const searchQuery = encodeURIComponent(`metadata['arnoma_student_id']:'${studentId}'`);
      const customerResp = await fetch(
        `https://api.stripe.com/v1/customers/search?query=${searchQuery}&limit=1`,
        { headers: stripeHeaders },
      );
      if (customerResp.ok) {
        const data = await customerResp.json();
        if (data.data && data.data.length > 0) customerId = data.data[0].id;
      }
    }

    // Fallback: search by email if metadata search found nothing
    if (!customerId && studentEmail) {
      const emailQuery = encodeURIComponent(`email:'${studentEmail}'`);
      const emailResp  = await fetch(
        `https://api.stripe.com/v1/customers/search?query=${emailQuery}&limit=1`,
        { headers: stripeHeaders },
      );
      if (emailResp.ok) {
        const data = await emailResp.json();
        if (data.data && data.data.length > 0) customerId = data.data[0].id;
      }
    }

    if (!customerId) {
      return new Response(
        JSON.stringify({ found: false, reason: 'No Stripe customer found for this student' }),
        { headers: { ...CORS, 'Content-Type': 'application/json' } },
      );
    }

    // ── 2. Fetch recent charges for this customer ─────────────────────────
    const chargesResp = await fetch(
      `https://api.stripe.com/v1/charges?customer=${customerId}&limit=30`,
      { headers: stripeHeaders },
    );

    if (!chargesResp.ok) {
      return new Response(
        JSON.stringify({ found: false, error: 'Failed to fetch Stripe charges' }),
        { headers: { ...CORS, 'Content-Type': 'application/json' } },
      );
    }

    const chargesData = await chargesResp.json();
    const allCharges: any[] = chargesData.data || [];

    // ── 3. Find the most recent failed charge ─────────────────────────────
    const failedCharge = allCharges.find((c) => c.status === 'failed');

    if (!failedCharge) {
      return new Response(
        JSON.stringify({ found: false, reason: 'No failed payments found in Stripe history' }),
        { headers: { ...CORS, 'Content-Type': 'application/json' } },
      );
    }

    // ── 4. Extract failure details ────────────────────────────────────────
    const createdDate = new Date(failedCharge.created * 1000).toISOString().split('T')[0];
    const card = failedCharge.payment_method_details?.card ?? null;

    return new Response(
      JSON.stringify({
        found         : true,
        amount        : failedCharge.amount / 100,          // cents → dollars
        failure_message: failedCharge.failure_message ?? null,
        failure_code  : failedCharge.failure_code ?? null,
        date          : createdDate,
        card_brand    : card?.brand ?? null,
        card_last4    : card?.last4 ?? null,
        charge_id     : failedCharge.id,
      }),
      { headers: { ...CORS, 'Content-Type': 'application/json' } },
    );

  } catch (err) {
    console.error('get-stripe-failed-payment error:', err);
    return new Response(
      JSON.stringify({ found: false, error: String(err) }),
      { status: 500, headers: { ...CORS, 'Content-Type': 'application/json' } },
    );
  }
});
