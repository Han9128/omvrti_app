# OmVrti.ai — Payment Integration
### Technical Planning Document

**Prepared for:** OmVrti.ai Engineering Team  
**Version:** 1.0  
**Date:** April 2026  
**Status:** Planning & Review

---

## Table of Contents

1. [Overview](#1-overview)
2. [Why We Cannot Build Payments From Scratch](#2-why-we-cannot-build-payments-from-scratch)
3. [Chosen Gateway — Razorpay](#3-chosen-gateway--razorpay)
4. [How the Payment Flow Works](#4-how-the-payment-flow-works)
5. [System Architecture](#5-system-architecture)
6. [What Each Team Builds](#6-what-each-team-builds)
7. [Folder Structure — Flutter App](#7-folder-structure--flutter-app)
8. [Backend API Contracts](#8-backend-api-contracts)
9. [Flutter Implementation Plan](#9-flutter-implementation-plan)
10. [Security Rules — Non-Negotiable](#10-security-rules--non-negotiable)
11. [Testing Strategy](#11-testing-strategy)
12. [Setup Checklist](#12-setup-checklist)
13. [Timeline Estimate](#13-timeline-estimate)
14. [Risks & Mitigations](#14-risks--mitigations)
15. [Glossary](#15-glossary)

---

## 1. Overview

The OmVrti.ai mobile app needs to let corporate travelers pay for their auto-pilot booked trips — which include flights, hotels, and car rentals — directly inside the app.

The payment page shows clean bottom sheet showing all available payment methods (UPI, Credit/Debit Card, Net Banking, Wallet), where the user picks one and completes the payment without leaving the app.

This document covers how that is built, who builds what, and how all the pieces fit together.

---

## 2. Why We Cannot Build Payments From Scratch

This is a common question from non-technical stakeholders. The answer is simple:

**Processing real money requires compliance certifications that take years and millions of dollars to obtain.**

| Requirement | What It Means | Cost / Time |
|---|---|---|
| PCI-DSS Certification | If you store or transmit card numbers, you must be certified | ₹50L+ / 1–2 years |
| RBI Approval | Required to process payments in India | Long regulatory process |
| Bank Partnerships | Need agreements with acquiring banks | Not available to startups |
| Fraud Detection | Real-time ML models to block fraudulent transactions | Dedicated team required |
| Encryption Infrastructure | Card data must be encrypted end-to-end | Significant infra cost |

**The solution:** Use a Payment Gateway. A payment gateway is a company that has already done all of the above. We simply connect to their service. They handle the money; we handle our app.

> **Analogy:** You don't build your own electricity generator to power your office. You connect to the grid. A payment gateway is the financial grid.

---

## 3. Chosen Gateway — Razorpay

After evaluating the options available in the Indian market, **Razorpay** is the recommended gateway for OmVrti.ai.

### 3.1 Comparison of Gateways

| Feature | Razorpay | Stripe | PayU | Cashfree |
|---|---|---|---|---|
| UPI Support | Full | No | Full | Full |
| International Cards | Yes | Yes | Yes | Yes |
| Flutter SDK | Official | Community | Community | Official |
| India Focus | Built for India | US-first | Yes | Yes |
| Transaction Fee | 2% per transaction | 2.9% + ₹30 | 2% | 1.75% |
| Corporate/B2B Features | Strong | Limited | Limited | Limited |

**Razorpay wins** because: official Flutter SDK, best UPI support, India-first, excellent documentation, and strong B2B/corporate payment features that align with OmVrti.ai's business model.

### 3.2 What Razorpay Provides Out of the Box

When we integrate Razorpay, we get the full payment UI shown to the user for free — we do not build it:

```
┌─────────────────────────────────────┐
│  Pay ₹1,875  •  OmVrti.ai          │
├─────────────────────────────────────┤
│                                     │
│  🔵  UPI                        >  │
│       Google Pay, PhonePe, BHIM     │
│                                     │
│  💳  Credit / Debit Card        >  │
│       Visa, Mastercard, RuPay       │
│                                     │
│  🏦  Net Banking                >  │
│       SBI, HDFC, ICICI, Axis...     │
│                                     │
│  👜  Wallets                    >  │
│       Paytm, Amazon Pay, Mobikwik   │
│                                     │
│  📅  EMI                        >  │
│       No-cost EMI available         │
│                                     │
└─────────────────────────────────────┘
```

Razorpay renders this sheet, handles all user input, communicates with banks, and tells us the result. Our app only opens it and listens for the result.

---

## 4. How the Payment Flow Works

This is the most important section. Read it carefully.

### 4.1 The Golden Rule

> **The Flutter app NEVER touches real money directly. It always goes through your backend server, which holds the secret key.**

If the secret key were inside the Flutter app, anyone could decompile the APK (Android app file) and extract it. They could then create fake orders, refund real ones, or access all transaction data. This is not a theoretical risk — it happens regularly to apps that make this mistake.

### 4.2 Step-by-Step Flow

```
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│  Flutter App │      │  Your Backend│      │   Razorpay   │
│   (Mobile)   │      │   (Server)   │      │   (Gateway)  │
└──────┬───────┘      └──────┬───────┘      └──────┬───────┘
       │                     │                     │
  [1]  │ POST /create-order  │                     │
       │ { amount: 187500,   │                     │
       │   currency: "INR" } │                     │
       │────────────────────>│                     │
       │                     │                     │
       │                [2]  │ POST /v1/orders     │
       │                     │ (with SECRET KEY)   │
       │                     │────────────────────>│
       │                     │                     │
       │                     │      { order_id,    │
       │                [3]  │        amount,      │
       │                     │        currency }   │
       │                     │<────────────────────│
       │                     │                     │
       │  { order_id,   [4]  │                     │
       │    key_id,          │                     │
       │    amount }         │                     │
       │<────────────────────│                     │
       │                     │                     │
  [5]  │ Open Razorpay SDK   │                     │
       │ with order_id       │                     │
       │ ┌──────────────┐    │                     │
       │ │ Pay ₹1,875   │    │                     │
       │ │ [UPI]        │    │                     │
       │ │ [Card]       │    │                     │
       │ │ [Wallet]     │    │                     │
       │ └──────────────┘    │                     │
       │         │           │                     │
  [6]  │ User selects UPI    │                     │
       │ and pays            │                     │
       │────────────────────────────────────────>  │
       │                     │                     │
       │  { payment_id, [7]  │                     │
       │    order_id,        │                     │
       │    signature }      │                     │
       │<────────────────────────────────────────  │
       │                     │                     │
  [8]  │ POST /verify        │                     │
       │ { payment_id,       │                     │
       │   order_id,         │                     │
       │   signature }       │                     │
       │────────────────────>│                     │
       │                     │                     │
       │                [9]  │ Verify HMAC-SHA256  │
       │                     │ signature locally   │
       │                     │ (no API call needed)│
       │                     │                     │
       │  { success: true,   │                     │
  [10] │    booking_id }     │                     │
       │<────────────────────│                     │
       │                     │                     │
  [11] │ Navigate to         │                     │
       │ Success Screen      │                     │
       │                     │                     │
```

### 4.3 Plain English Explanation of Each Step

| Step | Who | What Happens | Why |
|---|---|---|---|
| 1 | Flutter → Backend | App asks backend to create a payment order | App can't create orders directly — no secret key |
| 2 | Backend → Razorpay | Backend creates order using secret key | Backend is the only one with the key |
| 3 | Razorpay → Backend | Razorpay returns a unique `order_id` | This ID tracks this specific payment attempt |
| 4 | Backend → Flutter | Backend sends `order_id` + `key_id` to the app | App now has what it needs to open the SDK |
| 5 | Flutter | App opens Razorpay SDK with the order details | SDK shows the payment bottom sheet to user |
| 6 | User | User selects UPI / Card / Wallet and pays | Razorpay handles everything here |
| 7 | Razorpay → Flutter | SDK returns 3 values on success | These prove the payment happened |
| 8 | Flutter → Backend | App sends the 3 values to backend to verify | We can't trust the app alone — backend verifies |
| 9 | Backend | Backend verifies the digital signature | Confirms Razorpay actually processed it |
| 10 | Backend → Flutter | Backend confirms success | Booking is now marked as paid in the database |
| 11 | Flutter | App shows success screen | User flow complete |

### 4.4 Why Step 9 (Signature Verification) Matters

When Razorpay returns `{ payment_id, order_id, signature }`, the signature is a cryptographic hash created using your secret key. Your backend recomputes this hash and checks if it matches.

If someone tried to fake a successful payment response from their own device, they couldn't produce the correct signature because they don't have the secret key. This is the security guarantee.

```
// How Razorpay computes the signature (your backend replicates this):
signature = HMAC_SHA256(
  key    = YOUR_SECRET_KEY,
  data   = order_id + "|" + payment_id
)
```

---

## 5. System Architecture

### 5.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    OmVrti.ai System                      │
│                                                         │
│   ┌───────────────────┐       ┌───────────────────┐    │
│   │   Flutter App     │       │   Backend Server  │    │
│   │   (iOS & Android) │◄─────►│   (Node.js/Python)│    │
│   │                   │       │                   │    │
│   │ • UI Screens      │       │ • Business Logic  │    │
│   │ • State Mgmt      │       │ • Database        │    │
│   │ • Razorpay SDK    │       │ • Razorpay API    │    │
│   └───────────────────┘       └─────────┬─────────┘    │
│                                         │               │
└─────────────────────────────────────────┼───────────────┘
                                          │
                                          ▼
                              ┌───────────────────────┐
                              │   Razorpay Servers    │
                              │                       │
                              │ • Order Management    │
                              │ • Payment Processing  │
                              │ • Bank Communication  │
                              │ • Fraud Detection     │
                              └───────────────────────┘
```

### 5.2 Data That Flows Through Each Layer

```
Flutter App holds:
  ✅ key_id (public — safe to expose)
  ✅ order_id (per-session — safe)
  ✅ payment result (payment_id, signature)
  ❌ NEVER the secret key
  ❌ NEVER raw card numbers

Backend Server holds:
  ✅ key_id
  ✅ secret_key (ONLY here)
  ✅ All booking and payment records
  ✅ Verification logic

Razorpay holds:
  ✅ Encrypted card data (PCI-DSS compliant)
  ✅ Bank communication credentials
  ✅ Fraud detection models
```

---

## 6. What Each Team Builds

### 6.1 Flutter Team

| Task | Description | Complexity |
|---|---|---|
| Add `razorpay_flutter` package | One line in `pubspec.yaml` | Easy |
| `PaymentService.createOrder()` | HTTP POST to backend `/create-order` | Easy |
| Open Razorpay SDK | Call `razorpay.open(options)` | Easy |
| Handle success callback | Collect `payment_id`, `order_id`, `signature` | Easy |
| Handle failure callback | Show error, allow retry | Medium |
| `PaymentService.verifyPayment()` | HTTP POST to backend `/verify-payment` | Easy |
| Payment success screen | Show booking confirmed UI | Medium |
| Loading states | Spinner while API calls are in flight | Easy |

**Total Flutter effort: 3–5 days**

### 6.2 Backend Team

| Task | Description | Complexity |
|---|---|---|
| Install Razorpay Node/Python SDK | Package install | Easy |
| `POST /api/create-order` endpoint | Create Razorpay order, return order_id | Medium |
| `POST /api/verify-payment` endpoint | Verify HMAC-SHA256 signature | Medium |
| Store payment record in DB | Save payment_id → booking_id mapping | Medium |
| Update booking status | Mark booking as "PAID" after verification | Medium |
| Error handling + logging | Handle Razorpay API failures gracefully | Important |
| Webhook endpoint | Razorpay can notify your server of payment events | Important |

**Total Backend effort: 5–7 days**

### 6.3 What Razorpay Builds (We Get For Free)

- Complete payment method selection UI
- UPI deep-linking (Google Pay, PhonePe, BHIM)
- Card number entry with PCI compliance
- Net banking redirect flows
- OTP handling
- Wallet integration
- EMI calculation
- Refund processing

---

## 7. Folder Structure — Flutter App

The payment feature follows the same MVVM folder structure established for the rest of the OmVrti.ai app:

```
lib/
└── features/
    └── payment/
        │
        ├── model/
        │   └── payment_model.dart         ← Data classes
        │       ├── PaymentModel           (total + payers list)
        │       ├── PaymentPayer           (Company / Traveler section)
        │       ├── PaymentCard            (individual card)
        │       ├── CardNetwork            (enum: mastercard, visa...)
        │       ├── PaymentState           (UI state with copyWith)
        │       └── PaymentResult          (success result from Razorpay)
        │
        ├── service/
        │   └── payment_service.dart       ← Network calls
        │       ├── fetchPaymentOptions()  → GET  /api/payment-options
        │       ├── createOrder()          → POST /api/create-order
        │       └── verifyPayment()        → POST /api/verify-payment
        │
        ├── viewmodel/
        │   └── payment_viewmodel.dart     ← Business logic (StateNotifier)
        │       ├── PaymentState           (what the UI renders)
        │       ├── PaymentNotifier        (manages state + Razorpay lifecycle)
        │       └── paymentProvider        (StateNotifierProvider)
        │
        └── view/
            └── screens/
                ├── payment_screen.dart    ← Payment options display screen
                └── payment_success_screen.dart  ← Booking confirmed screen
```

---

## 8. Backend API Contracts

These are the two endpoints the Flutter app needs. The backend team must build these exactly as specified.

### 8.1 Create Order

**Request**
```
POST /api/create-order
Authorization: Bearer <user_jwt_token>
Content-Type: application/json

{
  "booking_id": "booking_abc123",
  "amount_inr": 1875
}
```

**Response — Success (200)**
```json
{
  "success": true,
  "order_id": "order_MfmA0ZzIasuXBs",
  "key_id": "rzp_test_xxxxxxxxxxxxxxx",
  "amount_paise": 187500,
  "currency": "INR",
  "booking_id": "booking_abc123"
}
```
> **Note:** Razorpay works in **paise** (1 INR = 100 paise). ₹1,875 = `187500` paise. The backend must do this conversion.

**Response — Error (400 / 500)**
```json
{
  "success": false,
  "error": "Failed to create order: <reason>"
}
```

---

### 8.2 Verify Payment

**Request**
```
POST /api/verify-payment
Authorization: Bearer <user_jwt_token>
Content-Type: application/json

{
  "razorpay_payment_id": "pay_MfmA0ZzIasuXBs",
  "razorpay_order_id": "order_MfmA0ZzIasuXBs",
  "razorpay_signature": "9ef4dffbfd84f1318f6739b3a6<...>",
  "booking_id": "booking_abc123"
}
```

**Response — Success (200)**
```json
{
  "success": true,
  "booking_id": "booking_abc123",
  "payment_id": "pay_MfmA0ZzIasuXBs",
  "status": "CONFIRMED"
}
```

**Response — Signature Mismatch (400)**
```json
{
  "success": false,
  "error": "Payment verification failed. Invalid signature."
}
```

> **Security Note:** A `400` here means someone may have tampered with the payment response. Log this with high priority and do NOT mark the booking as paid.

---

### 8.3 How the Backend Verifies the Signature (Node.js Example)

```javascript
const crypto = require('crypto');

function verifyRazorpaySignature(orderId, paymentId, receivedSignature) {
  const body = orderId + "|" + paymentId;
  
  const expectedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_SECRET_KEY)
    .update(body)
    .digest('hex');

  // Use timingSafeEqual to prevent timing attacks
  return crypto.timingSafeEqual(
    Buffer.from(expectedSignature),
    Buffer.from(receivedSignature)
  );
}
```

---

## 9. Flutter Implementation Plan

### 9.1 Package Setup

Add to `pubspec.yaml`:
```yaml
dependencies:
  razorpay_flutter: ^1.3.6
```

### 9.2 Android Minimum SDK

In `android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 21   // Required by Razorpay Flutter SDK
}
```

### 9.3 What the ViewModel Does

The `PaymentNotifier` (StateNotifier) manages the entire payment lifecycle:

```
State: PaymentState
  ├── paymentModel          (data from API — null while loading)
  ├── selectedCardIds       (Map: payerId → cardId, tracks radio selection)
  ├── isCreatingOrder       (true while POST /create-order is in flight)
  ├── isConfirming          (true while POST /verify-payment is in flight)
  └── errorMessage          (null = no error, String = show error to user)

Methods:
  ├── _fetchPaymentOptions()   called on init, loads payer/card data
  ├── selectCard(payerId, cardId)  called on radio tap, updates selectedCardIds
  ├── proceedToPayment()       creates order → opens Razorpay SDK
  ├── _onPaymentSuccess(response)  handles Razorpay success callback
  ├── _onPaymentError(response)    handles Razorpay failure callback
  └── _onExternalWallet(response)  handles wallet selection
```

### 9.4 Opening Razorpay (Core Code Pattern)

```dart
void proceedToPayment() async {
  // Step 1: Tell the UI we are loading
  state = state.copyWith(isCreatingOrder: true);

  // Step 2: Ask our backend to create a Razorpay order
  final orderResponse = await _service.createOrder(
    bookingId: bookingId,
    amountInr: state.paymentModel!.totalAmount,
  );

  // Step 3: Open the Razorpay payment sheet
  final options = {
    'key':         orderResponse.keyId,       // Your Razorpay Key ID
    'order_id':    orderResponse.orderId,     // From our backend
    'amount':      orderResponse.amountPaise, // In paise
    'currency':    'INR',
    'name':        'OmVrti.ai',
    'description': 'AutoPilot Trip Booking',
    'prefill': {
      'name':    travelerName,
      'email':   travelerEmail,
      'contact': travelerPhone,
    },
    'theme': {
      'color': '#3B82F6', // OmVrti primary blue
    },
  };

  _razorpay.open(options); // This shows the Zomato-style payment sheet
}
```

### 9.5 Handling Razorpay Callbacks

Razorpay gives us three callbacks we must register:

```dart
// SUCCESS — user paid, we get 3 values to verify
void _onPaymentSuccess(PaymentSuccessResponse response) async {
  state = state.copyWith(isConfirming: true);
  
  await _service.verifyPayment(
    paymentId: response.paymentId,
    orderId:   response.orderId,
    signature: response.signature,
  );

  // If verification passes → navigate to success screen
  state = state.copyWith(isConfirming: false);
  onSuccess();
}

// FAILURE — user cancelled or payment failed
void _onPaymentError(PaymentFailureResponse response) {
  state = state.copyWith(
    isConfirming: false,
    errorMessage: 'Payment failed. Please try again.',
  );
}

// EXTERNAL WALLET — user chose Paytm etc.
void _onExternalWallet(ExternalWalletResponse response) {
  // Show a message: "Redirecting to ${response.walletName}"
}
```

---

## 10. Security Rules — Non-Negotiable

These rules are **mandatory**. No exceptions, no shortcuts.

| # | Rule | Why |
|---|---|---|
| 1 | **Secret key ONLY on the backend server** | Anyone can decompile an APK and steal it |
| 2 | **Always verify signature on the backend** | A fake success response could mark unpaid bookings as paid |
| 3 | **Use HTTPS for all API calls** | Prevents man-in-the-middle interception |
| 4 | **Never log card numbers or CVVs** | PCI-DSS violation — Razorpay handles this, not you |
| 5 | **Store only payment_id in your DB** | Not card data, not CVV — only the reference ID |
| 6 | **Use environment variables for keys** | Never commit API keys to Git |
| 7 | **Set up Razorpay webhooks** | So your backend knows about payment even if the app crashes |

### 10.1 Environment Variables Setup

**Flutter app** — store public key ID in `.env`:
```
# .env (add to .gitignore)
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxxxx
```

**Backend** — store secret key in server environment:
```
# Never in code, always in server environment
RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxxxxx
RAZORPAY_SECRET_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## 11. Testing Strategy

### 11.1 Test Mode vs Live Mode

Razorpay provides a complete test environment. No real money moves during testing.

Switch between modes by changing the key:
- `rzp_test_...` → Test mode (fake payments)
- `rzp_live_...` → Live mode (real payments)

### 11.2 Razorpay Test Card Numbers

Use these during development — they always succeed:

| Card Type | Number | CVV | Expiry |
|---|---|---|---|
| Mastercard (Success) | 5267 3181 8797 5449 | Any 3 digits | Any future date |
| Visa (Success) | 4111 1111 1111 1111 | Any 3 digits | Any future date |
| Card (Failure) | 4000 0000 0000 0002 | Any 3 digits | Any future date |
| Rupay | 6076 2900 0000 0005 | Any 3 digits | Any future date |

### 11.3 Test UPI IDs

| Result | UPI ID |
|---|---|
| Success | `success@razorpay` |
| Failure | `failure@razorpay` |

### 11.4 Test Scenarios to Cover

```
✅ Successful payment via UPI
✅ Successful payment via Card
✅ Successful payment via Net Banking
✅ User cancels mid-payment (hits back button)
✅ Card declined (insufficient funds)
✅ Network error during order creation
✅ Network error during payment verification
✅ App crashes after payment but before verification
   → Webhook should still confirm it
✅ Signature mismatch (tampered response)
```

---

## 12. Setup Checklist

### For the Flutter Team

- [ ] Create a Razorpay account at [razorpay.com](https://razorpay.com)
- [ ] Navigate to Settings → API Keys → Generate Test Keys
- [ ] Copy `Key ID` and `Key Secret` — store them safely
- [ ] Add `razorpay_flutter: ^1.3.6` to `pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Set `minSdkVersion 21` in `android/app/build.gradle`
- [ ] Add internet permission to `AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  ```
- [ ] Confirm backend `/create-order` endpoint is available (or use mock)
- [ ] Confirm backend `/verify-payment` endpoint is available (or use mock)

### For the Backend Team

- [ ] Install Razorpay SDK:
  ```bash
  # Node.js
  npm install razorpay
  
  # Python
  pip install razorpay
  ```
- [ ] Add Razorpay Key ID and Secret to environment variables
- [ ] Implement `POST /api/create-order`
- [ ] Implement `POST /api/verify-payment` with HMAC-SHA256 verification
- [ ] Add payment record table to database
- [ ] Set up Razorpay webhook endpoint
- [ ] Test with Razorpay test credentials
- [ ] Write unit tests for signature verification logic

---

## 13. Timeline Estimate

| Phase | Task | Team | Days |
|---|---|---|---|
| **Phase 1** | Backend: `/create-order` endpoint | Backend | 2 |
| **Phase 1** | Backend: `/verify-payment` + signature verification | Backend | 2 |
| **Phase 1** | Backend: DB schema + booking status update | Backend | 1 |
| **Phase 2** | Flutter: Razorpay SDK integration + ViewModel | Flutter | 2 |
| **Phase 2** | Flutter: Payment screen UI (already designed) | Flutter | 2 |
| **Phase 2** | Flutter: Payment success screen | Flutter | 1 |
| **Phase 3** | End-to-end testing with test credentials | Both | 2 |
| **Phase 3** | Bug fixes + edge case handling | Both | 2 |
| **Phase 4** | Switch to live keys + go-live verification | Both | 1 |
| | **Total** | | **~15 days** |

> This estimate assumes parallel work by Flutter and Backend teams. If sequential, add 5–7 days.

---

## 14. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Secret key accidentally committed to Git | Medium | Critical | Add `.env` to `.gitignore` immediately. Use git-secrets tool. |
| App crashes between payment and verification | Low | Critical | Set up Razorpay webhooks — backend verifies independently |
| User pays but sees failure screen | Low | High | Check Razorpay dashboard manually + webhook reconciliation |
| Razorpay service outage | Very Low | High | Show clear error message, don't retry automatically |
| Wrong amount sent to Razorpay | Low | High | Always compute amount on backend, not frontend |
| Slow network causes timeout | Medium | Medium | Implement retry logic with exponential backoff |
| User double-taps "Pay" button | Medium | Medium | Disable button after first tap (already implemented in our UI) |

---

## 15. Glossary

| Term | Definition |
|---|---|
| **Payment Gateway** | A third-party service that processes card/UPI/wallet payments on your behalf |
| **Order ID** | A unique identifier Razorpay creates for each payment attempt |
| **Payment ID** | A unique identifier Razorpay assigns after a successful payment |
| **HMAC-SHA256** | A cryptographic algorithm used to create and verify digital signatures |
| **Signature** | A tamper-proof hash that proves Razorpay processed the payment |
| **Paise** | Indian subunit of currency. 1 INR = 100 paise. Razorpay uses paise. |
| **PCI-DSS** | Payment Card Industry Data Security Standard — compliance required to store card data |
| **Webhook** | An HTTP callback from Razorpay to your server notifying you of payment events |
| **Key ID** | The public part of your Razorpay credentials — safe to use in the app |
| **Secret Key** | The private part of your Razorpay credentials — NEVER put this in the app |
| **Test Mode** | Razorpay environment where no real money moves — for development |
| **Live Mode** | Razorpay environment with real money — for production |
| **SDK** | Software Development Kit — Razorpay's pre-built Flutter code for showing the payment UI |
| **StateNotifier** | Riverpod class that manages interactive UI state (used for payment screen) |
| **MVVM** | Model-View-ViewModel — the architecture pattern used in OmVrti.ai |

---

*Document prepared by the OmVrti.ai mobile engineering team.*  
*For questions, contact the Flutter team lead.*