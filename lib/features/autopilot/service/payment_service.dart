import 'package:omvrti_app/features/autopilot/model/payment_model.dart';

class PaymentService {
  Future<PaymentModel> fetchPaymentDetails() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock data matching the design exactly:
    // Flight $600 + Hotel $1100 + Car $260 = $1960 - $85 rewards = $1875
    return PaymentModel.fromCosts(
      flightCost: 600,
      hotelCost: 1100,
      carRentalCost: 260,
      rewardsApplied: 75,
    );
  }
}