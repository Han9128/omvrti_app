import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/features/autopilot/model/summary_model.dart';
import 'package:omvrti_app/features/autopilot/service/summary_service.dart';

// Service provider
final summaryServiceProvider = Provider<SummaryService>(
  (ref) => SummaryService(),
);

// FutureProvider — fetches summary data when screen mounts.
// Uses AsyncValue so the screen can handle loading/error/data states.
final summaryProvider = FutureProvider<SummaryModel>((ref) async {
  final service = ref.watch(summaryServiceProvider);
  return service.fetchSummary();
});