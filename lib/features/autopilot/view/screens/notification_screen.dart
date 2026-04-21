import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import '../../../../core/constants/constants.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            const OmvrtiAppBar(),
            const Expanded(
              child: Center(child: Text('Notifications — Coming Soon')),
            ),
          ],
        ),
      ),
    );
  }
}
