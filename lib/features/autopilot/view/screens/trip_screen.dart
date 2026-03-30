import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import '../../../../core/constants/constants.dart';

class TripScreen extends ConsumerWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OmvrtiAppBar(),
            const Expanded(child: Center(child: Text('Trips — Coming Soon'))),
          ],
        ),
      ),
    );
  }
}
