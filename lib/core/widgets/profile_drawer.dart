// ─────────────────────────────────────────────────────────────────────────────
// PROFILE DRAWER  (lib/core/widgets/profile_drawer.dart)
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the slide-in profile menu that opens from the RIGHT when the user
// taps the profile picture in OmvrtiAppBar.
//
// DESIGN STRUCTURE:
//   ┌─────────────────────────────┐
//   │                       [  X ]│  ← close button
//   │                             │
//   │      👤 Sam Watson          │  ← user info
//   │      sam.watson@omvrti.ai   │
//   │                             │
//   │  ─────────────────────────  │
//   │                             │
//   │  👤 My Profile              │  ← menu items
//   │  🎁 OmVrti.ai Rewards       │
//   │  ⚙️ My Preferences          │
//   │  🔔 Notifications           │
//   │  📱 App                     │
//   │  🔗 Linked Accounts         │
//   │  💳 Payment Methods         │
//   │  👛 My Wallet               │
//   │                             │
//   │  ─────────────────────────  │
//   │                             │
//   │  🚪 Logout                  │
//   └─────────────────────────────┘

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omvrti_app/core/constants/constants.dart';
import 'package:omvrti_app/core/router/app_router.dart';
import 'package:omvrti_app/features/auth/viewmodel/auth_viewmodel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

/// One tappable row in the profile drawer
class _ProfileMenuItem {
  final IconData icon;
  final String label;
  final String? route;
  final bool isLogout; // Special styling for logout

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.route,
    this.isLogout = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE DRAWER WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class ProfileDrawer extends ConsumerWidget {
  final String userName;
  final String userEmail;
  final String? userAvatar;

  const ProfileDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
  });

  // ── Menu Items ─────────────────────────────────────────────────────────────
  static List<_ProfileMenuItem> _getMenuItems() => const [
        _ProfileMenuItem(
          icon: Icons.person_outline_rounded,
          label: 'My Profile',
          route: '/profile',
        ),
        _ProfileMenuItem(
          icon: Icons.card_giftcard_outlined,
          label: 'OmVrti.ai Rewards',
          route: '/rewards',
        ),
        _ProfileMenuItem(
          icon: Icons.settings_outlined,
          label: 'My Preferences',
          route: '/settings',
        ),
        _ProfileMenuItem(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          route: '/notifications',
        ),
        _ProfileMenuItem(
          icon: Icons.calendar_month_outlined,
          label: 'Apps',
          route: '/calendar',
        ),
        _ProfileMenuItem(
          icon: Icons.link_outlined,
          label: 'Linked Accounts',
          route: null,
        ),
        _ProfileMenuItem(
          icon: Icons.credit_card_outlined,
          label: 'Payment Methods',
          route: null,
        ),
        _ProfileMenuItem(
          icon: Icons.account_balance_wallet_outlined,
          label: 'My Wallet',
          route: null,
        ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = _getMenuItems();

    return Drawer(
      backgroundColor: AppColors.surface,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.82,

      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header with close button ───────────────────────────────────
            _buildHeader(context),

            const SizedBox(height: AppSpacing.lg),

            // ── User Info Section ──────────────────────────────────────────
            _buildUserInfo(context),

            const SizedBox(height: AppSpacing.xl),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Container(
                height: 1,
                color: AppColors.textMuted.withValues(alpha:0.15),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Menu Items ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    // Regular menu items
                    for (final item in menuItems)
                      _buildMenuItem(context, ref, item),

                    const SizedBox(height: AppSpacing.lg),

                    // Divider before logout
                    Container(
                      height: 1,
                      color: AppColors.textMuted.withValues(alpha:0.15),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Logout item
                    _buildMenuItem(
                      context,
                      ref,
                      const _ProfileMenuItem(
                        icon: Icons.logout_outlined,
                        label: 'Logout',
                        isLogout: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header (just close button on the right) ───────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ✕ Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── User Info (Avatar + Name + Email) ────────────────────────────────────
  Widget _buildUserInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundImage: userAvatar != null
                ? NetworkImage(userAvatar!)
                : const NetworkImage('https://i.pravatar.cc/150?img=12'),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Menu Item ──────────────────────────────────────────────────────────────
  Widget _buildMenuItem(BuildContext context, WidgetRef ref, _ProfileMenuItem item) {
    return InkWell(
      onTap: item.isLogout
          ? () => _handleLogout(context, ref)
          : (item.route != null
              ? () => _handleItemTap(context, item.route!)
              : null),
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      splashColor: item.isLogout
          ? AppColors.error.withValues(alpha:0.06)
          : AppColors.primary.withValues(alpha:0.06),
      highlightColor: item.isLogout
          ? AppColors.error.withValues(alpha:0.04)
          : AppColors.primary.withValues(alpha:0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            // Icon
            Icon(
              item.icon,
              size: 22,
              color: item.isLogout
                  ? AppColors.error
                  : AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.md),

            // Label
            Text(
              item.label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: item.isLogout
                    ? AppColors.error
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation Handler ─────────────────────────────────────────────────────
  void _handleItemTap(BuildContext context, String route) {
    Navigator.pop(context);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (context.mounted) {
        context.go(route);
      }
    });
  }

  // ── Logout Handler ────────────────────────────────────────────────────────
  void _handleLogout(BuildContext context, WidgetRef ref) {
    // Capture root navigator BEFORE closing the drawer.
    // After the drawer closes, the drawer's own context becomes unmounted,
    // but the root navigator (from MaterialApp) is always alive.
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    // Close the drawer first
    Navigator.pop(context);

    // Wait for drawer close animation, then show dialog via root navigator
    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: rootNavigator.context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                AppRouter.router.go('/login');
                ref.read(authProvider.notifier).logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    });
  }
}