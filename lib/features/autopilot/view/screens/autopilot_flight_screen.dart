import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/core/constants/app_colors.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';

class AutopilotFlightScreen extends ConsumerWidget {
  const AutopilotFlightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const OmvrtiAppBar(showBack: true),
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [Expanded(child: Text("Fligt Screen - Coming Soon..."))],
        ),
      ),
    );
  }
}
