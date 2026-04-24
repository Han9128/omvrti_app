// ─────────────────────────────────────────────────────────────────────────────
// RazorpayConfig — Centralized configuration for Razorpay integration
// ─────────────────────────────────────────────────────────────────────────────
//
// WHY a separate config file?
//   → One place to change keys when switching test → live
//   → Easy to find for any team member
//   → When a real backend is added, only this file changes
//
// ══════════════════════════════════════════════════════════════════════════════
// 🔑 HOW TO ADD YOUR RAZORPAY KEY
// ══════════════════════════════════════════════════════════════════════════════
//
// STEP 1: Go to https://dashboard.razorpay.com
// STEP 2: Login → Settings → API Keys → Generate Test Keys
// STEP 3: Copy the "Key ID" — it starts with "rzp_test_"
// STEP 4: Paste it below where it says YOUR_KEY_ID_HERE
//
// ⚠️  IMPORTANT RULES:
//   → Paste ONLY the Key ID here (starts with rzp_test_)
//   → NEVER paste the Key Secret here — that goes on the backend only
//   → The Key ID is safe to be in the app — it's public by design
//   → When going to production: change rzp_test_ to rzp_live_
//
// Example of what Key ID looks like:
//   rzp_test_1DP5mmOlF5G5ag        ← this format, your value will differ
// ══════════════════════════════════════════════════════════════════════════════

class RazorpayConfig {
  RazorpayConfig._(); // prevent instantiation

  // ── 🔑 PASTE YOUR RAZORPAY TEST KEY ID HERE ───────────────────────────────
  static const String keyId = 'rzp_test_ShHbZoPvFZvB3j';
  // ─────────────────────────────────────────────────────────────────────────

  // App name shown at the top of Razorpay's payment sheet
  static const String appName = 'OmVrti.ai';

  // Short description shown under the amount on Razorpay's sheet
  static const String paymentDescription = 'AutoPilot Trip Booking';

  // Brand color shown on Razorpay's payment sheet (OmVrti primary blue)
  // Must be a hex string — Razorpay doesn't accept Flutter Color objects
  static const String themeColor = '#3B82F6';

  // Currency — USD for US prototype
  static const String currency = 'USD';

  // ── Test credentials (for your reference during development) ─────────────
  //
  // CARDS — enter these when Razorpay's sheet asks for card details:
  //
  //   ✅ Visa (US):        4111 1111 1111 1111 | CVV: 123 | Expiry: any future date
  //   ✅ Mastercard (US):  5267 3181 8797 5449 | CVV: 123 | Expiry: any future date
  //   ✅ Amex (US):        3782 822463 10005   | CVV: 1234 | Expiry: any future date
  //   ❌ Declined card:    4000 0000 0000 0002 | CVV: 123 | Expiry: any future date
  //
  // UPI (India test only):
  //   ✅ SUCCESS — UPI ID:  success@razorpay
  //   ❌ FAILURE — UPI ID:  failure@razorpay
  //
  // These are not used in code — documentation only.
}