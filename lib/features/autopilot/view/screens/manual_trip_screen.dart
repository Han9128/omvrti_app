import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/widgets/app_button.dart';
import 'package:omvrti_app/core/widgets/omvrti_app_bar.dart';
import 'package:omvrti_app/features/autopilot/model/trip_model.dart';
import 'package:omvrti_app/features/autopilot/viewmodel/autopilot_viewmodel.dart';

// ManualTripScreen is a full-screen form that allows the user
// to manually enter all trip details.
//
// After submission:
//   → Builds a TripModel from the form fields
//   → Writes it into selectedTripProvider (the shared bridge)
//   → Navigates to /autopilot/alert just like the calendar flow
//
// Uses ConsumerStatefulWidget because:
//   - Many TextEditingControllers need initState/dispose
//   - Date pickers need local state
//   - Form sections can collapse/expand (optional sections)

class ManualTripScreen extends ConsumerStatefulWidget {
  const ManualTripScreen({super.key});

  @override
  ConsumerState<ManualTripScreen> createState() => _ManualTripScreenState();
}

class _ManualTripScreenState extends ConsumerState<ManualTripScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // ── Controllers — one per text field ──────────────────────────────────────
  final _purposeController = TextEditingController();
  final _companyController = TextEditingController();
  final _originCityController = TextEditingController();
  final _originStateController = TextEditingController();
  final _destCityController = TextEditingController();
  final _destStateController = TextEditingController();
  final _travelerNameController = TextEditingController();
  final _budgetController = TextEditingController();

  // Optional fields
  final _meetingLocationController = TextEditingController();
  final _firstMeetingController = TextEditingController();
  final _lastMeetingController = TextEditingController();
  final _accommodationController = TextEditingController();
  final _carRentalController = TextEditingController();

  // ── Local state ────────────────────────────────────────────────────────────
  DateTime? _departDate;
  DateTime? _returnDate;

  // Controls whether optional sections are visible
  bool _showMeetingSection = false;
  bool _showServicesSection = false;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _purposeController.dispose();
    _companyController.dispose();
    _originCityController.dispose();
    _originStateController.dispose();
    _destCityController.dispose();
    _destStateController.dispose();
    _travelerNameController.dispose();
    _budgetController.dispose();
    _meetingLocationController.dispose();
    _firstMeetingController.dispose();
    _lastMeetingController.dispose();
    _accommodationController.dispose();
    _carRentalController.dispose();
    super.dispose();
  }

  // ── Date picker helper ─────────────────────────────────────────────────────
  Future<void> _pickDate({required bool isDeparture}) async {
    final now = DateTime.now();
    final initial = isDeparture
        ? (_departDate ?? now.add(const Duration(days: 7)))
        : (_returnDate ?? (_departDate ?? now).add(const Duration(days: 3)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(2030),
      builder: (context, child) {
        // Apply brand colors to the date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departDate = picked;
          // If return is before new depart, clear it
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = null;
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  // ── Form submission ────────────────────────────────────────────────────────
  void _handleSubmit() {
    // Validate all required fields
    if (!_formKey.currentState!.validate()) return;

    if (_departDate == null) {
      _showError('Please select a departure date.');
      return;
    }
    if (_returnDate == null) {
      _showError('Please select a return date.');
      return;
    }

    setState(() => _isSubmitting = true);

    // Build TripModel from form inputs
    final trip = TripModel(
      purpose: _purposeController.text.trim(),
      company: _companyController.text.trim(),
      estimatedBudget: double.tryParse(
            _budgetController.text.replaceAll(',', ''),
          ) ??
          0,
      originCity: _originCityController.text.trim(),
      originState: _originStateController.text.trim(),
      // Airport derived from city — user can edit later on Alert Screen
      originAirport:
          '${_originCityController.text.trim()} Airport, Terminal 1',
      destCity: _destCityController.text.trim(),
      destState: _destStateController.text.trim(),
      destAirport: '${_destCityController.text.trim()} Airport, Terminal 1',
      departDate: _departDate!,
      returnDate: _returnDate!,
      tripDuration: _returnDate!.difference(_departDate!).inDays,
      travelerName: _travelerNameController.text.trim(),

      // Optional fields — only set if user filled them in
      meetingLocation: _meetingLocationController.text.trim().isEmpty
          ? null
          : _meetingLocationController.text.trim(),
      firstMeeting: _firstMeetingController.text.trim().isEmpty
          ? null
          : _firstMeetingController.text.trim(),
      lastMeeting: _lastMeetingController.text.trim().isEmpty
          ? null
          : _lastMeetingController.text.trim(),
      accommodationNote: _accommodationController.text.trim().isEmpty
          ? null
          : _accommodationController.text.trim(),
      carRentalNote: _carRentalController.text.trim().isEmpty
          ? null
          : _carRentalController.text.trim(),
    );

    // Write to shared bridge provider — Alert Screen will use this trip
    ref.read(selectedTripProvider.notifier).state = trip;

    // Navigate to Alert Screen — same as calendar flow
    context.go('/autopilot/alert');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Format date for display ────────────────────────────────────────────────
  String _displayDate(DateTime? date) {
    if (date == null) return 'Select date';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // Back arrow AppBar
            const OmvrtiAppBar(showBack: true),

            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page title + subtitle
                      Text(
                        'Add Trip Manually',
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fill in your trip details below.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Section 1: Trip Purpose ──────────────────────
                      _buildSectionCard(
                        title: 'Trip Purpose',
                        icon: Icons.work_outline_rounded,
                        children: [
                          _buildTextField(
                            controller: _purposeController,
                            label: 'Purpose',
                            hint: 'e.g. Client Meeting, Conference',
                            icon: Icons.flag_outlined,
                            validator: _required,
                            capitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _companyController,
                            label: 'Company / Organization',
                            hint: 'e.g. Smart Client Inc.',
                            icon: Icons.business_outlined,
                            validator: _required,
                            capitalization: TextCapitalization.words,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Section 2: Route ─────────────────────────────
                      _buildSectionCard(
                        title: 'Route',
                        icon: Icons.flight_outlined,
                        children: [
                          // Origin
                          _buildSubLabel('From'),
                          const SizedBox(height: AppSpacing.sm),
                          _buildTextField(
                            controller: _originCityController,
                            label: 'Origin City',
                            hint: 'e.g. San Francisco',
                            icon: Icons.location_on_outlined,
                            validator: _required,
                            capitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildTextField(
                            controller: _originStateController,
                            label: 'State / Country',
                            hint: 'e.g. CA, United States',
                            icon: Icons.map_outlined,
                            validator: _required,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Destination
                          _buildSubLabel('To'),
                          const SizedBox(height: AppSpacing.sm),
                          _buildTextField(
                            controller: _destCityController,
                            label: 'Destination City',
                            hint: 'e.g. New York',
                            icon: Icons.location_on_outlined,
                            validator: _required,
                            capitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildTextField(
                            controller: _destStateController,
                            label: 'State / Country',
                            hint: 'e.g. NY, United States',
                            icon: Icons.map_outlined,
                            validator: _required,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Section 3: Dates ─────────────────────────────
                      _buildSectionCard(
                        title: 'Travel Dates',
                        icon: Icons.calendar_month_outlined,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateTile(
                                  label: 'Departure',
                                  date: _departDate,
                                  onTap: () =>
                                      _pickDate(isDeparture: true),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _buildDateTile(
                                  label: 'Return',
                                  date: _returnDate,
                                  onTap: () =>
                                      _pickDate(isDeparture: false),
                                ),
                              ),
                            ],
                          ),
                          // Show calculated duration when both dates selected
                          if (_departDate != null && _returnDate != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                                horizontal: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Trip Duration: ${_returnDate!.difference(_departDate!).inDays} Days',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Section 4: Traveler + Budget ─────────────────
                      _buildSectionCard(
                        title: 'Traveler & Budget',
                        icon: Icons.person_outline_rounded,
                        children: [
                          _buildTextField(
                            controller: _travelerNameController,
                            label: 'Traveler Name',
                            hint: 'e.g. Mr. Sam Watson',
                            icon: Icons.person_outline_rounded,
                            validator: _required,
                            capitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _budgetController,
                            label: 'Estimated Budget (USD)',
                            hint: 'e.g. 2500',
                            icon: Icons.attach_money_rounded,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter a budget';
                              }
                              if (double.tryParse(
                                    v.replaceAll(',', ''),
                                  ) ==
                                  null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Section 5: Meeting Details (optional) ─────────
                      _buildExpandableSection(
                        title: 'Meeting Details',
                        subtitle: 'Optional',
                        icon: Icons.event_outlined,
                        isExpanded: _showMeetingSection,
                        onToggle: () => setState(
                          () => _showMeetingSection = !_showMeetingSection,
                        ),
                        children: [
                          _buildTextField(
                            controller: _firstMeetingController,
                            label: 'First Meeting',
                            hint:
                                'e.g. First Meeting: 4 PM – 6 PM, Mon, Jun 1, 2026',
                            icon: Icons.access_time_outlined,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _lastMeetingController,
                            label: 'Last Meeting',
                            hint:
                                'e.g. Last Meeting: 2 PM – 4 PM, Mon, Jun 1, 2026',
                            icon: Icons.access_time_outlined,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _meetingLocationController,
                            label: 'Meeting Location',
                            hint: 'e.g. 200 Main St, New York, NY',
                            icon: Icons.place_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Section 6: Services (optional) ───────────────
                      _buildExpandableSection(
                        title: 'Accommodation & Transport',
                        subtitle: 'Optional',
                        icon: Icons.hotel_outlined,
                        isExpanded: _showServicesSection,
                        onToggle: () => setState(
                          () =>
                              _showServicesSection = !_showServicesSection,
                        ),
                        children: [
                          _buildTextField(
                            controller: _accommodationController,
                            label: 'Accommodation Note',
                            hint: 'e.g. Book a hotel for 4 nights',
                            icon: Icons.hotel_outlined,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTextField(
                            controller: _carRentalController,
                            label: 'Car Rental Note',
                            hint: 'e.g. Rent a car for 5 days',
                            icon: Icons.directions_car_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Submit button ────────────────────────────────
                      AppFilledButton(
                        text: 'Continue to Trip Review',
                        icon: AppIcons.forward,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget builders ────────────────────────────────────────────────────────

  // Section card — white rounded card with title row + children
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }

  // Expandable optional section — collapsed by default
  Widget _buildExpandableSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Column(
        children: [
          // Tappable header row
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.textSecondary, size: 16),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron rotates when expanded
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(children: children),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // Standard text field — consistent style across all sections
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          validator: validator,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            filled: true,
            fillColor: AppColors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.textMuted,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Date tile — tappable box showing selected date or placeholder
  Widget _buildDateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate ? AppColors.primary : AppColors.textMuted,
            width: hasDate ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: hasDate ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _displayDate(date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: hasDate
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontWeight: hasDate
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Sub-label for route sections ("From" / "To")
  Widget _buildSubLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  // Required field validator
  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}