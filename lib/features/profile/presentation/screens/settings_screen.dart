import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/preferences_provider.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/profile_screen_header.dart';

/// Screen allowing the user to manage authentication, security switches,
/// change password, and view active sessions.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileScreenHeader(title: 'Settings'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Authentication & Login
                    const Text(
                      'Authentication & Login',
                      style: TextStyle(
                        fontFamily: AppFonts.family,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SettingsSwitchRow(
                            title: 'Push Notification',
                            value: prefs.pushNotification,
                            onChanged: (val) => _saveOrSay(
                              context,
                              notifier.updatePreferences(pushNotification: val),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SettingsSwitchRow(
                            title: 'Two-Factor Authentication',
                            value: prefs.twoFactorAuth,
                            onChanged: (val) =>
                                notifier.updatePreferences(twoFactorAuth: val),
                          ),
                          const SizedBox(height: 12),
                          _SettingsSwitchRow(
                            title: 'Pass-key',
                            value: prefs.passKey,
                            onChanged: (val) =>
                                notifier.updatePreferences(passKey: val),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'Change Password',
                            variant: AppButtonVariant.grey,
                            onPressed: () =>
                                context.push(Routes.changePassword),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Active Sessions
                    const Text(
                      'Active Sessions',
                      style: TextStyle(
                        fontFamily: AppFonts.family,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Phone icon: square grey box, no separate border stroke.
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.fieldHintDot,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.phone_iphone_rounded,
                            size: 24,
                            color: AppColors.neutral700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'iPhone 13',
                                style: TextStyle(
                                  fontFamily: AppFonts.family,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.graphite,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'This Device  •  Lagos, Nigeria',
                                style: TextStyle(
                                  fontFamily: AppFonts.family,
                                  fontSize: 12,
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final confirmed = await LogoutConfirmationDialog.show(
                          context,
                        );
                        if (confirmed == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Logged out of all other active sessions',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Logout from all devices',
                        style: TextStyle(
                          fontFamily: AppFonts.family,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.graphite,
                          decoration: TextDecoration.underline,
                        ),
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
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppFonts.family,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.graphite,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.switchTrack,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.neutral200,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

/// Waits for [save] and, if the API refused it, says so.
Future<void> _saveOrSay(BuildContext context, Future<void> save) async {
  try {
    await save;
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
