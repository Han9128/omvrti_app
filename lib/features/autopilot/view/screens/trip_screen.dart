// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:omvrti_app/core/constants/constants.dart';
// import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';

// class TripScreen extends ConsumerWidget {
//   const TripScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ColoredBox(
//       color: AppColors.pageBackground,
//       child: SafeArea(
//         top: false,
//         bottom: false,
//         child: Column(
//           children: [
//             const OmvrtiAppBar(),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(AppSpacing.lg),
//                 child: _buildTripPlanningCard(context),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTripPlanningCard(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [AppColors.primary, AppColors.pageBackground],
//         ),
//         borderRadius: BorderRadius.circular(AppSpacing.xl),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // "Trip Planning" header title
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               vertical: AppSpacing.lg,
//               horizontal: AppSpacing.lg,
//             ),
//             child: Text(
//               'Trip Planning',
//               style: AppTextStyles.h3.copyWith(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),

//           // White content card
//           Container(
//             margin: const EdgeInsets.fromLTRB(
//               AppSpacing.md,
//               0,
//               AppSpacing.md,
//               AppSpacing.md,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(AppSpacing.xl),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.06),
//                   blurRadius: 16,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Period row
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(
//                     AppSpacing.lg,
//                     AppSpacing.lg,
//                     AppSpacing.lg,
//                     AppSpacing.sm,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Trip Planning Period',
//                         style: AppTextStyles.h4.copyWith(
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       _buildPeriodDropdown(),
//                     ],
//                   ),
//                 ),

//                 // Total trips count
//                 Text(
//                   'Total Trips: 42',
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: AppSpacing.md),

//                 const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

//                 // Column headers row
//                 _buildColumnHeaders(),

//                 const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

//                 // Trip type rows
//                 _buildTripRow(
//                   name: 'Autopilot Trips',
//                   subtitle: 'Almost certain trips',
//                   total: 20,
//                   accepted: 5,
//                 ),
//                 const Divider(
//                   height: 1,
//                   thickness: 1,
//                   color: Color(0xFFEEEEEE),
//                   indent: AppSpacing.lg,
//                   endIndent: AppSpacing.lg,
//                 ),
//                 _buildTripRow(
//                   name: 'Copilot Trips',
//                   subtitle: 'very likely trips',
//                   total: 15,
//                   accepted: 2,
//                 ),
//                 const Divider(
//                   height: 1,
//                   thickness: 1,
//                   color: Color(0xFFEEEEEE),
//                   indent: AppSpacing.lg,
//                   endIndent: AppSpacing.lg,
//                 ),
//                 _buildTripRow(
//                   name: 'Discover Trips',
//                   subtitle: 'Adhoc trips',
//                   total: 7,
//                   accepted: 0,
//                 ),
//                 const SizedBox(height: AppSpacing.sm),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPeriodDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppSpacing.md,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: AppColors.textMuted.withValues(alpha: 0.5),
//           width: 1,
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Current Year',
//             style: AppTextStyles.bodySmall.copyWith(
//               color: AppColors.textPrimary,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(width: 4),
//           const Icon(
//             Icons.keyboard_arrow_down_rounded,
//             size: 16,
//             color: AppColors.textPrimary,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildColumnHeaders() {
//     const Color totalColor = Color(0xFF4A90D9);
//     const Color acceptedColor = Color(0xFF27AE60);

//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppSpacing.lg,
//         vertical: AppSpacing.sm,
//       ),
//       child: Row(
//         children: [
//           const Expanded(child: SizedBox()),
//           SizedBox(
//             width: 56,
//             child: Center(
//               child: Text(
//                 'Total',
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: totalColor,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 72,
//             child: Center(
//               child: Text(
//                 'Accepted',
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: acceptedColor,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildTripRow({
//     required String name,
//     required String subtitle,
//     required int total,
//     required int accepted,
//   }) {
//     const Color totalColor = Color(0xFF4A90D9);
//     const Color totalBg = Color(0xFFD6E8F9);
//     const Color acceptedColor = Color(0xFF27AE60);
//     const Color acceptedBg = Color(0xFFD4F4E2);

//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppSpacing.lg,
//         vertical: AppSpacing.md,
//       ),
//       child: Row(
//         children: [
//           // Trip name + subtitle
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Total circle
//           SizedBox(
//             width: 56,
//             child: Center(
//               child: _buildBadge(total.toString(), totalColor, totalBg),
//             ),
//           ),

//           // Accepted circle
//           SizedBox(
//             width: 72,
//             child: Center(
//               child: _buildBadge(accepted.toString(), acceptedColor, acceptedBg),
//             ),
//           ),

//           // Chevron
//           const Icon(
//             Icons.chevron_right_rounded,
//             color: AppColors.textMuted,
//             size: 20,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBadge(String text, Color textColor, Color bgColor) {
//     return Container(
//       width: 38,
//       height: 38,
//       decoration: BoxDecoration(
//         color: bgColor,
//         shape: BoxShape.circle,
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         text,
//         style: AppTextStyles.bodyMedium.copyWith(
//           color: textColor,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';

// Changed from ConsumerWidget → ConsumerStatefulWidget because we need
// local state to track the selected year in the dropdown.
// ConsumerWidget has no setState() — it's purely for watching providers.
// ConsumerStatefulWidget gives us both setState() AND ref.watch().
class TripScreen extends ConsumerStatefulWidget {
  const TripScreen({super.key});

  @override
  ConsumerState<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends ConsumerState<TripScreen> {
  // The currently selected year.
  // Defaults to the current year — shown as "Current Year" in the dropdown.
  int _selectedYear = DateTime.now().year;

  // The years available in the dropdown.
  // Shows current year + 3 previous years.
  late final List<int> _availableYears = List.generate(
    4,
    (i) => DateTime.now().year - i,
  );

  // Returns the display label for a year value.
  // Current year shows "Current Year", past years show the year number.
  String _yearLabel(int year) {
    if (year == DateTime.now().year) return 'Current Year';
    return year.toString();
  }

  // Shows a modal bottom sheet with year options.
  // We use a custom bottom sheet instead of Flutter's DropdownButton
  // because DropdownButton doesn't match our design system styling.
  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Select Period',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Year options list
                ..._availableYears.map((year) {
                  final isSelected = year == _selectedYear;
                  return GestureDetector(
                    onTap: () {
                      // Update selected year and close the sheet
                      setState(() => _selectedYear = year);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        // Highlight the currently selected year
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.4)
                              : AppColors.textMuted.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _yearLabel(year),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          // Checkmark on selected item
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            const OmvrtiAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildTripPlanningCard(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripPlanningCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.pageBackground],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // "Trip Planning" header title
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.lg,
            ),
            child: Text(
              'Trip Planning',
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // White content card
          Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.xl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Period row — dropdown now calls _showYearPicker()
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trip Planning Period',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Tappable dropdown pill — now functional
                      GestureDetector(
                        onTap: _showYearPicker,
                        child: _buildPeriodDropdown(),
                      ),
                    ],
                  ),
                ),

                // Total trips count
                Text(
                  'Total Trips: 42',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEEEEEE),
                ),

                // Column headers row
                _buildColumnHeaders(),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEEEEEE),
                ),

                // Trip type rows — unchanged
                _buildTripRow(
                  name: 'Autopilot Trips',
                  subtitle: 'Almost certain trips',
                  total: 20,
                  accepted: 5,
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEEEEEE),
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                ),
                _buildTripRow(
                  name: 'Copilot Trips',
                  subtitle: 'very likely trips',
                  total: 15,
                  accepted: 2,
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEEEEEE),
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                ),
                _buildTripRow(
                  name: 'Discover Trips',
                  subtitle: 'Adhoc trips',
                  total: 7,
                  accepted: 0,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // The dropdown pill widget — label now reflects _selectedYear
  Widget _buildPeriodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.textMuted.withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label updates reactively when _selectedYear changes
          Text(
            _yearLabel(_selectedYear),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  // Unchanged from original
  Widget _buildColumnHeaders() {
    const Color totalColor = Color(0xFF4A90D9);
    const Color acceptedColor = Color(0xFF27AE60);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Expanded(child: SizedBox()),
          SizedBox(
            width: 56,
            child: Center(
              child: Text(
                'Total',
                style: AppTextStyles.bodySmall.copyWith(
                  color: totalColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Center(
              child: Text(
                'Accepted',
                style: AppTextStyles.bodySmall.copyWith(
                  color: acceptedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  // Unchanged from original
  Widget _buildTripRow({
    required String name,
    required String subtitle,
    required int total,
    required int accepted,
  }) {
    const Color totalColor = Color(0xFF4A90D9);
    const Color totalBg = Color(0xFFD6E8F9);
    const Color acceptedColor = Color(0xFF27AE60);
    const Color acceptedBg = Color(0xFFD4F4E2);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 56,
            child: Center(
              child: _buildBadge(total.toString(), totalColor, totalBg),
            ),
          ),
          SizedBox(
            width: 72,
            child: Center(
              child: _buildBadge(
                accepted.toString(),
                acceptedColor,
                acceptedBg,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }

  // Unchanged from original
  Widget _buildBadge(String text, Color textColor, Color bgColor) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
