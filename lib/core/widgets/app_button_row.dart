import 'package:flutter/material.dart';
import 'package:omvrti_app/core/constants/app_spacing.dart';
import 'package:omvrti_app/core/widgets/app_button.dart';

class AppButtonRow extends StatelessWidget {
  final String filledText;
  final String outlinedText;

  final VoidCallback? onFilledPressed;
  final VoidCallback? onOutlinedPressed;

  final IconData? filledIcon;
  final IconData? outlinedIcon;

  final bool isOutlinedLoading;
  final bool isFilledLoading;

  const AppButtonRow({
    super.key,
    required this.outlinedText,
    required this.filledText,
    this.onOutlinedPressed,
    this.onFilledPressed,
    this.filledIcon,
    this.outlinedIcon,
    this.isFilledLoading = false,
    this.isOutlinedLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          // flex: 1,
          child: AppOutlinedButton(
            text: outlinedText,
            onPressed: onOutlinedPressed,
            icon: outlinedIcon,
            isLoading: isOutlinedLoading,
          ),
        ),

        const SizedBox(width: 64),

        Expanded(
          // flex: 1,
          child: AppFilledButton(
            text: filledText,
            onPressed: onFilledPressed,
            icon: filledIcon,
            isLoading: isFilledLoading,
          ),
        ),
      ],
    );
  }
}
