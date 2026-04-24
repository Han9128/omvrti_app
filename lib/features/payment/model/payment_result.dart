// ─────────────────────────────────────────────────────────────────────────────
// PaymentResult — Data returned by Razorpay after a successful payment
// ─────────────────────────────────────────────────────────────────────────────
//
// When payment succeeds, Razorpay calls our success callback with these values.
// We store them in this model and pass them to the BookingConfirmedScreen
// so we can show the user a real transaction ID — not a fake message.
//
// In production: these values are sent to YOUR backend for signature
// verification before marking the booking as paid.

class PaymentResult {
  /// Unique payment ID from Razorpay: "pay_Mfm3xyz..."
  /// This is the real transaction reference number.
  final String paymentId;

  /// The order ID associated with this payment.
  /// In prototype mode this is null (we skipped order creation).
  /// In production this comes from your backend's /create-order endpoint.
  final String? orderId;

  /// Cryptographic signature from Razorpay.
  /// In prototype mode this is null.
  /// In production your backend verifies this to confirm authenticity.
  final String? signature;

  /// The amount that was paid, in cents (1 USD = 100 cents).
  /// e.g. $1,875.00 → amountPaise = 187500
  final int amountPaise;

  const PaymentResult({
    required this.paymentId,
    this.orderId,
    this.signature,
    required this.amountPaise,
  });

  /// Converts cents to a human-readable USD string.
  /// 187500 → "$1,875.00"
  String get formattedAmount {
    final dollars = amountPaise ~/ 100;
    final cents = amountPaise % 100;
    final centsStr = cents.toString().padLeft(2, '0');
    if (dollars >= 1000) {
      final thousands = dollars ~/ 1000;
      final hundreds = (dollars % 1000).toString().padLeft(3, '0');
      return '\$$thousands,$hundreds.$centsStr';
    }
    return '\$$dollars.$centsStr';
  }
}