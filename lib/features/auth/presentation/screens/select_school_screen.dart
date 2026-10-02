import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/school_repository.dart';
import '../../domain/institution.dart';
import '../widgets/kyu_page.dart';

/// Step one: which school the account belongs to.
class SelectSchoolScreen extends ConsumerStatefulWidget {
  const SelectSchoolScreen({super.key});

  @override
  ConsumerState<SelectSchoolScreen> createState() => _SelectSchoolScreenState();
}

class _SelectSchoolScreenState extends ConsumerState<SelectSchoolScreen> {
  final _search = TextEditingController();
  Institution? _picked;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Institution> _matching(List<Institution> all) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  void _continue() {
    if (_picked == null) return;
    context.push(Routes.selectRole);
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    final schools = ref.watch(schoolsProvider);

    return KyuPage(
      step: 1,
      title: 'Which school are you at?',
      subtitle:
          'Search for your institution. Your account is tied to the school '
          'you pick, and you will only ever see what that school publishes.',
      body: Column(
        children: [
          AppInput(
            controller: _search,
            hint: 'Search institution...',
            onChanged: (_) => setState(() {}),
            suffix: const Icon(
              Icons.search,
              size: 22,
              color: AppColors.graphite,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: schools.when(
              loading: () => const Loader(),
              // The dev API is serverless and sleeps, so a first call after
              // idle can take several seconds. Offer a retry rather than
              // leaving someone stuck on a failure they can clear themselves.
              error: (e, _) => ErrorState(
                message: e is ApiException
                    ? e.message
                    : 'Could not load schools.',
                onRetry: () => ref.invalidate(schoolsProvider),
              ),
              data: (all) {
                final shown = _matching(all);
                if (shown.isEmpty) {
                  return const EmptyState(
                    message: 'No school matches that search.',
                    icon: Icons.search_off_outlined,
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: shown.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: OptionRow.gap),
                  itemBuilder: (_, i) {
                    final it = shown[i];
                    return OptionRow(
                      title: it.name,
                      subtitle: it.subtitle.isEmpty ? null : it.subtitle,
                      selected: it.id == picked?.id,
                      onTap: it.isAvailable
                          ? () => setState(() => _picked = it)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          if (picked != null) ...[
            const SizedBox(height: 16),
            InfoBanner(
              'Your account will be associated with ${picked.name}. Content '
              'belonging to any other institution stays inaccessible to you.',
            ),
          ],
        ],
      ),
      // No Skip: registration cannot go through without an institutionId,
      // so there is no outcome for skipping this to produce.
      footer: AppButton(
        label: 'Continue',
        onPressed: picked == null ? null : _continue,
      ),
    );
  }
}
