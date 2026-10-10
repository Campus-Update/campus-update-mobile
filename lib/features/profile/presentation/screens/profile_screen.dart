import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/auth/auth_state.dart';
import '../../data/profile_providers.dart';
import '../../domain/user_profile.dart';
import '../widgets/dashed_card.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_menu_card.dart';
import '../widgets/profile_screen_header.dart';

/// The root Profile tab screen showing the user's dashed summary card
/// and quick navigation options.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final user = profile ?? defaultMockUserProfile;
    final displayName = user.fullName;
    final displayEmail = user.email ?? '';
    final displayInstitution = user.institutionName ?? 'Lead City University';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileScreenHeader(title: 'Profile'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    DashedCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              try {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1024,
                                  maxHeight: 1024,
                                  imageQuality: 85,
                                );
                                if (image != null) {
                                  await ref
                                      .read(userProfileProvider.notifier)
                                      .updateProfile(avatarPath: image.path);
                                }
                              } catch (_) {}
                            },
                            child: ProfileAvatar(
                              radius: 42,
                              imagePath: profile?.avatarPath,
                              name: displayName,
                              initials: user.initials,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontFamily: AppFonts.family,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.graphite,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            displayEmail,
                            style: const TextStyle(
                              fontFamily: AppFonts.family,
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_balance_outlined,
                                size: 15,
                                color: AppColors.indigo,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                displayInstitution,
                                style: const TextStyle(
                                  fontFamily: AppFonts.family,
                                  fontSize: 12.5,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Material(
                            color: const Color(0xFF2C2D2F),
                            borderRadius: BorderRadius.circular(100),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => context.push(Routes.editProfile),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 7,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontFamily: AppFonts.family,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProfileMenuCard(
                      items: [
                        ProfileMenuItem(
                          title: 'Account information',
                          onTap: () => context.push(Routes.accountInformation),
                        ),
                        ProfileMenuItem(
                          title: 'Preference',
                          onTap: () => context.push(Routes.preferences),
                        ),
                        ProfileMenuItem(
                          title: 'Settings',
                          onTap: () => context.push(Routes.settings),
                        ),
                        ProfileMenuItem(
                          title: 'Security',
                          onTap: () => context.push(Routes.settings),
                        ),
                        ProfileMenuItem(
                          title: 'Saved articles',
                          trailingIcon: Icons.bookmark_border_outlined,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Saved articles coming soon'),
                              ),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          title: 'Support',
                          onTap: () => context.push(Routes.support),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            ref.read(authProvider.notifier).signOut(),
                        child: const Text(
                          'Sign out',
                          style: TextStyle(
                            fontFamily: AppFonts.family,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
