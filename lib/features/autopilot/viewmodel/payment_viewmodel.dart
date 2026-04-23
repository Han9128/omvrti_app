import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/model/payment_model.dart';
import 'package:omvrti_app/features/autopilot/service/payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>(
  (ref) => PaymentService(),
);

// FutureProvider automatically handles loading/error/data states.
// The screen uses tripAsync.when(...) to render each state.
final paymentProvider = FutureProvider<PaymentModel>((ref) async {
  final service = ref.watch(paymentServiceProvider);
  return service.fetchPaymentDetails();
});