import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../data/profile_providers.dart';
import '../../domain/user_profile.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_screen_header.dart';

/// Screen displaying the user's detailed account and academic information.
class AccountInformationScreen extends ConsumerWidget {
  const AccountInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final user = profile ?? defaultMockUserProfile;

    final firstName = user.firstName ?? '';
    final lastName = user.lastName ?? '';
    final institution = user.institutionName ?? 'Lead City University';
    final faculty = user.facultyName ?? '—';
    final department = user.departmentName ?? '—';
    final programme = user.programmeName ?? '—';
    final level = user.academicLevelName ?? '—';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileScreenHeader(title: 'Account Information'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ProfileAvatar(
                        radius: 46,
                        imagePath: profile?.avatarPath,
                        name: '$firstName $lastName',
                        initials: user.initials,
                        showEditBadge: true,
                        onEditPhoto: () async {
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
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not pick image: $e'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Personal details',
                      actionLabel: 'Edit',
                      onAction: () => context.push(Routes.editProfile),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(label: 'First Name', value: firstName),
                          _DetailRow(label: 'Last Name', value: lastName),
                          _DetailRow(label: 'Institution', value: institution),
                          _DetailRow(label: 'Faculty', value: faculty),
                          _DetailRow(label: 'Department', value: department),
                          _DetailRow(label: 'Programme', value: programme),
                          _DetailRow(
                            label: 'Level',
                            value: level,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: AppColors.graphite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
