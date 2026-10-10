import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../data/preferences_provider.dart';
import '../../domain/user_preferences.dart';
import '../widgets/dashed_card.dart';
import '../widgets/profile_screen_header.dart';

/// Screen allowing the user to configure their feed preference mode
/// and notification digests.
class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileScreenHeader(title: 'Preference'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: 12,
                ),
                child: DashedCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FeedModeCard(
                        title: 'Personalized',
                        description:
                            'Puts your faculty, department and level first. '
                            'Institution-wide and urgent notices still always reach you.',
                        isSelected:
                            prefs.feedMode == FeedPreferenceMode.personalized,
                        onTap: () => notifier.updatePreferences(
                          feedMode: FeedPreferenceMode.personalized,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FeedModeCard(
                        title: 'All campus information',
                        description:
                            'Everything published by your institution, whoever it was aimed at.',
                        isSelected:
                            prefs.feedMode == FeedPreferenceMode.allCampus,
                        onTap: () => notifier.updatePreferences(
                          feedMode: FeedPreferenceMode.allCampus,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _TogglePreferenceCard(
                        title: 'Emergency Alerts',
                        subtitle: 'Push notifications for critical updates',
                        value: prefs.emergencyAlerts,
                        onChanged: (val) =>
                            notifier.updatePreferences(emergencyAlerts: val),
                      ),
                      const SizedBox(height: 12),
                      _TogglePreferenceCard(
                        title: 'Daily News Digest',
                        subtitle: 'Receive a morning summary email',
                        value: prefs.dailyNewsDigest,
                        onChanged: (val) =>
                            notifier.updatePreferences(dailyNewsDigest: val),
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
}

class _FeedModeCard extends StatelessWidget {
  const _FeedModeCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF4F46E5);

    return Material(
      color: isSelected ? activeColor : const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? null
                : Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppFonts.family,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.graphite,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  description,
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 12.5,
                    height: 1.4,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.88)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TogglePreferenceCard extends StatelessWidget {
  const _TogglePreferenceCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.graphite,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF5B52E0),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
