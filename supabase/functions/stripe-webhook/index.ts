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
      metadata   : { student_id?: string; invoice_ref?: string; student_name?: string; for_class?: string; for_class_dates?: string };
      receipt_email: string | null;
    };

    const { student_id, invoice_ref, for_class, for_class_dates } = pi.metadata ?? {};
    const amountDollars = pi.amount / 100;

    console.log(`✅ PaymentIntent succeeded: ${pi.id} | student: ${student_id} | $${amountDollars} | for_class: ${for_class} | for_class_dates: ${for_class_dates}`);

    if (student_id && SUPABASE_URL && SERVICE_ROLE_KEY) {
      const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

      // Build the array of class dates this payment covers.
      // Prefer for_class_dates (JSON array) over for_class (comma string) — more precise.
      let forClassArray: string[] = [];
      if (for_class_dates) {
        try {
          const parsed = JSON.parse(for_class_dates);
          if (Array.isArray(parsed)) forClassArray = parsed.map((d: string) => String(d).trim()).filter(Boolean);
        } catch {
          forClassArray = for_class_dates.split(',').map((d: string) => d.trim()).filter(Boolean);
        }
      }
      if (forClassArray.length === 0 && for_class) {
        forClassArray = for_class.split(',').map((d: string) => d.trim()).filter(Boolean);
      }

      // Use today's date only as last resort — so Calendar always has an explicit for_class
      const todayDate = new Date().toISOString().split('T')[0];
      const primaryClassDate = forClassArray.length > 0 ? forClassArray[0] : todayDate;

      // Insert a paid record in payment_records.
      // CRITICAL: date = primaryClassDate (the actual class date, NOT the receipt date).
      // Calendar-NEW matches green dots by payment_records.date === class_date.
      const { data: insertedRows, error } = await supabaseAdmin
        .from('payment_records')
        .insert({
          student_id     : student_id,
          amount         : amountDollars,
          status         : 'paid',
          payment_method : 'Stripe',
          date           : primaryClassDate,
          notes          : invoice_ref ? `Stripe PI: ${pi.id} | Ref: ${invoice_ref}` : `Stripe PI: ${pi.id}`,
        })
        .select()
        .single();

      if (error) {
        console.error('❌ Supabase insert error:', error);
      } else {
        console.log(`✅ payment_records inserted for student ${student_id} covering classes: ${forClassArray.join(', ') || primaryClassDate}`);

        // ── Send payment receipt email (non-blocking) ──────────────────────
        sendStripeReceipt(supabaseAdmin, {
          studentId:       student_id,
          paymentRecordId: insertedRows?.id ?? null,
          amount:          amountDollars,
          classDate:       primaryClassDate,
          piId:            pi.id,
        }).catch((err: Error) => console.warn('⚠️ Receipt send failed (non-fatal):', err.message));
      }
    }
  }

  return new Response(JSON.stringify({ received: true }), {
    status: 200,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });
});

// ── Receipt sender ────────────────────────────────────────────────────────────
async function sendStripeReceipt(
  supabaseAdmin: ReturnType<typeof createClient>,
  opts: { studentId: string; paymentRecordId: number | null; amount: number; classDate: string; piId: string },
) {
  const { studentId, paymentRecordId, amount, classDate, piId } = opts;

  // Fetch student name + email
  const { data: student, error: stuErr } = await supabaseAdmin
    .from('students')
    .select('id, name, email, group_name')
    .eq('id', studentId)
    .single();

  if (stuErr || !student) {
    console.warn('⚠️ Receipt: student not found for id', studentId);
    return;
  }

  // Parse email (handles JSON-array format)
  let cleanEmail = String(student.email || '').trim();
  if (cleanEmail.startsWith('[')) {
    try {
      const arr = JSON.parse(cleanEmail);
      if (Array.isArray(arr) && arr.length) cleanEmail = String(arr[0]).trim();
    } catch (_) { /* ignore */ }
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!cleanEmail || !emailRegex.test(cleanEmail)) {
    console.warn('⚠️ Receipt: no valid email for student', student.name);
    return;
  }

  const receiptNumber = 'M' + String(paymentRecordId ?? piId).padStart(5, '0');
  const issuedDate = new Date().toLocaleDateString('en-US', {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',
  });
  const classDateFormatted = classDate
    ? new Date(classDate + 'T12:00:00').toLocaleDateString('en-US', {
        weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',
      })
    : 'N/A';
  const groupText = student.group_name ? `Group ${student.group_name}` : 'ARNOMA Student';
  const year = new Date().getFullYear();

  const receiptHTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Payment Receipt #${receiptNumber} — ARNOMA</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
</head>
<body style="margin:0;padding:0;background:#04080f;font-family:'Inter',Helvetica,Arial,sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#04080f;padding:48px 16px;">
  <tr><td align="center">
  <table width="100%" cellpadding="0" cellspacing="0" border="0" style="max-width:600px;background:#07111f;border-radius:24px;overflow:hidden;box-shadow:0 8px 60px rgba(0,0,0,0.7),0 0 0 1px rgba(196,163,82,0.2);">
    <tr>
      <td style="background:linear-gradient(160deg,#020c1b 0%,#071428 50%,#0a1e3d 100%);padding:52px 48px 44px;text-align:center;border-bottom:1px solid rgba(196,163,82,0.3);">
        <div style="width:80px;height:2px;background:linear-gradient(90deg,transparent,#c4a352,#e8d082,#c4a352,transparent);margin:0 auto 32px;"></div>
        <img src="https://raw.githubusercontent.com/easylearnrn-hash/ARNOMA/main/richyfesta-logo.png" alt="ARNOMA" width="80" style="display:block;margin:0 auto 20px;filter:drop-shadow(0 0 20px rgba(196,163,82,0.5)) brightness(0) invert(1);"/>
        <p style="margin:0 0 6px;font-size:10px;letter-spacing:5px;text-transform:uppercase;color:#c4a352;font-weight:600;">Armenian Nurses Online Mentoring Association</p>
        <h1 style="margin:10px 0 0;font-family:'Playfair Display',Georgia,serif;font-size:30px;font-weight:700;color:#f0e0a0;letter-spacing:1px;">Payment Receipt</h1>
        <div style="width:80px;height:2px;background:linear-gradient(90deg,transparent,#c4a352,#e8d082,#c4a352,transparent);margin:28px auto 0;"></div>
      </td>
    </tr>
    <tr>
      <td style="background:#040f1d;padding:28px 48px;text-align:center;border-bottom:1px solid rgba(196,163,82,0.15);">
        <div style="display:inline-block;background:linear-gradient(135deg,rgba(16,185,129,0.15),rgba(16,185,129,0.05));border:2px solid rgba(16,185,129,0.5);border-radius:50px;padding:12px 36px;">
          <span style="font-family:'Playfair Display',Georgia,serif;font-size:22px;font-weight:700;color:#10b981;letter-spacing:4px;text-transform:uppercase;">✓ &nbsp;PAID</span>
        </div>
        <p style="margin:16px 0 0;font-size:13px;color:rgba(196,163,82,0.55);letter-spacing:1px;">RECEIPT NO. &nbsp;<strong style="color:#c4a352;letter-spacing:2px;">#${receiptNumber}</strong></p>
      </td>
    </tr>
    <tr>
      <td style="background:#051020;padding:20px 48px;border-bottom:1px solid rgba(196,163,82,0.12);">
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td>
              <p style="margin:0;font-size:9px;letter-spacing:3.5px;text-transform:uppercase;color:#c4a352;font-weight:700;">Issued To</p>
              <p style="margin:6px 0 0;font-size:17px;font-weight:700;color:#f0e0a0;">${student.name}</p>
              <p style="margin:4px 0 0;font-size:12px;color:rgba(196,163,82,0.5);">${groupText} · NCLEX-RN Program</p>
            </td>
            <td style="text-align:right;vertical-align:top;">
              <p style="margin:0;font-size:9px;letter-spacing:3.5px;text-transform:uppercase;color:#c4a352;font-weight:700;">Date Issued</p>
              <p style="margin:6px 0 0;font-size:14px;font-weight:500;color:rgba(240,224,160,0.75);">${issuedDate}</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td style="padding:40px 48px 0;background:#07111f;">
        <p style="margin:0 0 28px;font-size:15px;color:#d4c4a0;line-height:1.8;">Dear <strong style="color:#e8d082;">${student.name}</strong>,<br/><span style="color:rgba(212,196,160,0.75);">Thank you for your payment. This is your official payment receipt from ARNOMA. Please keep it for your records.</span></p>
        <p style="margin:0 0 14px;font-size:9px;letter-spacing:4px;text-transform:uppercase;color:#c4a352;font-weight:700;">Payment Details</p>
        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border:1px solid rgba(196,163,82,0.25);border-radius:14px;overflow:hidden;margin-bottom:36px;">
          <tr style="background:#040f1d;">
            <th style="padding:14px 22px;text-align:left;font-size:9px;letter-spacing:3px;text-transform:uppercase;color:#c4a352;font-weight:700;border-bottom:1px solid rgba(196,163,82,0.2);">Description</th>
            <th style="padding:14px 22px;text-align:right;font-size:9px;letter-spacing:3px;text-transform:uppercase;color:#c4a352;font-weight:700;border-bottom:1px solid rgba(196,163,82,0.2);">Amount</th>
          </tr>
          <tr style="background:#07111f;">
            <td style="padding:18px 22px;border-bottom:1px solid rgba(196,163,82,0.08);">
              <p style="margin:0;font-size:14px;font-weight:600;color:#cce0f5;">NCLEX-RN Class Session</p>
              <p style="margin:4px 0 0;font-size:12px;color:rgba(196,163,82,0.55);">Class Date: ${classDateFormatted}</p>
            </td>
            <td style="padding:18px 22px;text-align:right;border-bottom:1px solid rgba(196,163,82,0.08);">
              <span style="font-family:'Playfair Display',Georgia,serif;font-size:18px;font-weight:700;color:#e8d082;">$${amount.toFixed(2)}</span>
            </td>
          </tr>
          <tr style="background:#040f1d;">
            <td style="padding:14px 22px;border-bottom:1px solid rgba(196,163,82,0.08);"><p style="margin:0;font-size:12px;color:rgba(196,163,82,0.55);">Payment Method</p></td>
            <td style="padding:14px 22px;text-align:right;border-bottom:1px solid rgba(196,163,82,0.08);"><span style="font-size:13px;font-weight:600;color:#8aaccc;">💳 Stripe · Online Payment</span></td>
          </tr>
          <tr style="background:linear-gradient(135deg,#0a1e3d 0%,#061428 100%);">
            <td style="padding:20px 22px;"><strong style="font-size:13px;font-weight:700;color:#c4a352;letter-spacing:2px;text-transform:uppercase;">Total Paid</strong></td>
            <td style="padding:20px 22px;text-align:right;"><strong style="font-family:'Playfair Display',Georgia,serif;font-size:24px;font-weight:800;color:#e8d082;">$${amount.toFixed(2)}</strong></td>
          </tr>
        </table>
        <table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#051628;border:1px solid rgba(16,185,129,0.25);border-radius:14px;margin-bottom:40px;">
          <tr><td style="padding:22px 26px;border-left:3px solid #10b981;">
            <p style="margin:0 0 8px;font-size:14px;font-weight:700;color:#a7f3d0;">✓ &nbsp;Your Account is Up to Date</p>
            <p style="margin:0;font-size:13px;color:rgba(212,196,160,0.75);line-height:1.8;">Your payment has been recorded and your access to class notes and study materials remains fully active. Thank you for staying current with your account.</p>
          </td></tr>
        </table>
        <p style="margin:0 0 8px;font-size:15px;color:rgba(212,196,160,0.75);line-height:1.9;">Thank you for your continued commitment to excellence.</p>
        <p style="margin:0 0 44px;font-size:15px;color:rgba(212,196,160,0.75);">With regard,<br/><strong style="color:#e8d082;font-size:16px;">ARNOMA Academic Office</strong></p>
      </td>
    </tr>
    <tr>
      <td style="background:#020c1b;padding:36px 48px;text-align:center;border-top:1px solid rgba(196,163,82,0.25);">
        <div style="width:60px;height:2px;background:linear-gradient(90deg,transparent,#c4a352,#e8d082,#c4a352,transparent);margin:0 auto 22px;"></div>
        <img src="https://raw.githubusercontent.com/easylearnrn-hash/ARNOMA/main/richyfesta-logo.png" alt="ARNOMA" width="44" style="display:block;margin:0 auto 14px;filter:brightness(0) invert(1);opacity:0.65;"/>
        <p style="margin:0 0 6px;font-size:13px;font-weight:700;color:#c4a352;letter-spacing:2px;text-transform:uppercase;">ARNOMA · NCLEX-RN</p>
        <p style="margin:0 0 18px;font-size:12px;color:rgba(196,163,82,0.4);">nclex.rn@arnoma.us &nbsp;·&nbsp; richy@arnoma.us &nbsp;·&nbsp; 909-808-1818</p>
        <p style="margin:0;font-size:11px;color:rgba(196,163,82,0.22);">© ${year} ARNOMA. All rights reserved. · Official payment receipt — Receipt #${receiptNumber}</p>
      </td>
    </tr>
  </table>
  </td></tr>
</table>
</body></html>`;

  // Send via send-email Edge Function (same project, use service role)
  const sendEmailUrl = `${SUPABASE_URL}/functions/v1/send-email`;
  const sendRes = await fetch(sendEmailUrl, {
    method: 'POST',
    headers: {
      'Content-Type' : 'application/json',
      'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
    },
    body: JSON.stringify({
      to     : cleanEmail,
      subject: `Payment Receipt #${receiptNumber} — ARNOMA NCLEX-RN`,
      html   : receiptHTML,
    }),
  });

  const sendResult = await sendRes.json().catch(() => ({}));
  const resendId   = sendResult?.id || sendResult?.data?.id || null;

  if (!sendRes.ok) {
    console.warn('⚠️ send-email returned error:', sendResult);
  } else {
    console.log(`✅ Receipt #${receiptNumber} sent to ${cleanEmail}`);
  }

  // Log to sent_emails
  await supabaseAdmin.from('sent_emails').insert({
    recipient_email : cleanEmail,
    recipient_name  : student.name,
    subject         : `Payment Receipt #${receiptNumber} — ARNOMA NCLEX-RN`,
    html_content    : receiptHTML,
    template_name   : 'Payment Receipt',
    email_type      : 'payment_receipt',
    resend_id       : resendId,
    delivery_status : sendRes.ok ? 'delivered' : 'failed',
    status          : sendRes.ok ? 'sent' : 'failed',
    sent_at         : new Date().toISOString(),
    metadata        : {
      student_id       : studentId,
      student_name     : student.name,
      receipt_number   : receiptNumber,
      amount,
      class_date       : classDate,
      method           : 'stripe',
      payment_record_id: paymentRecordId,
      stripe_pi_id     : piId,
    },
  });
}
