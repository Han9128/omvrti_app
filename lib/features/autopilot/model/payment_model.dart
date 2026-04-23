// PaymentModel holds all cost breakdown data shown on the payment screen.
//
// The individual costs (flight, hotel, car) come from the booking flow.
// rewardsApplied is the discount from OmVrti Rewards.
// totalAmount is computed as (flight + hotel + car - rewardsApplied).

class PaymentModel {
  final double flightCost;
  final double hotelCost;
  final double carRentalCost;
  final double rewardsApplied; // stored as positive, displayed as negative
  final double totalAmount;

  const PaymentModel({
    required this.flightCost,
    required this.hotelCost,
    required this.carRentalCost,
    required this.rewardsApplied,
    required this.totalAmount,
  });

  // Convenience factory — computes totalAmount automatically
  factory PaymentModel.fromCosts({
    required double flightCost,
    required double hotelCost,
    required double carRentalCost,
    required double rewardsApplied,
  }) {
    return PaymentModel(
      flightCost: flightCost,
      hotelCost: hotelCost,
      carRentalCost: carRentalCost,
      rewardsApplied: rewardsApplied,
      totalAmount: flightCost + hotelCost + carRentalCost - rewardsApplied,
    );
  }
}