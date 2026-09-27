import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/kyu_page.dart';

/// An institution the app can be tied to.
///
/// Stands in for what `GET /api/v1/schools` will return. The API gives id,
/// name, slug, acronym and logo but neither a location nor whether it is
/// live, both of which the design shows — worth raising before this is wired.
class Institution {
  const Institution({
    required this.id,
    required this.name,
    required this.where,
    this.available = false,
  });

  final String id;
  final String name;

  /// "Osogbo, Osun" — the line under the name.
  final String where;

  /// The others are drawn "coming soon" and cannot be picked.
  final bool available;

  String get subtitle => available ? where : '$where · coming soon';
}

/// Step one: which school the account belongs to.
class SelectSchoolScreen extends ConsumerStatefulWidget {
  const SelectSchoolScreen({super.key});

  @override
  ConsumerState<SelectSchoolScreen> createState() => _SelectSchoolScreenState();
}

class _SelectSchoolScreenState extends ConsumerState<SelectSchoolScreen> {
  // Placeholder until the schools endpoint is wired.
  static const _all = [
    Institution(
      id: 'osun',
      name: 'Osun State University',
      where: 'Osogbo, Osun',
      available: true,
    ),
    Institution(id: 'ui', name: 'University of Ibadan', where: 'Ibadan, Oyo'),
    Institution(
      id: 'illesha',
      name: 'University of Illesha',
      where: 'Osogbo, Osun',
    ),
    Institution(
      id: 'oau',
      name: 'Obafemi Awolowo University',
      where: 'Ibadan, Oyo',
    ),
  ];

  final _search = TextEditingController();
  Institution? _picked;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Institution> get _shown {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  void _continue() {
    if (_picked == null) return;
    context.push(Routes.selectRole);
  }

  void _skip() => context.push(Routes.selectRole);

  @override
  Widget build(BuildContext context) {
    final picked = _picked;

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
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _shown.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: OptionRow.gap),
              itemBuilder: (_, i) {
                final it = _shown[i];
                return OptionRow(
                  title: it.name,
                  subtitle: it.subtitle,
                  selected: it.id == picked?.id,
                  onTap: it.available
                      ? () => setState(() => _picked = it)
                      : null,
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
      footer: picked == null
          ? Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Skip',
                    variant: AppButtonVariant.secondary,
                    onPressed: _skip,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: AppButton(label: 'Next', onPressed: null)),
              ],
            )
          : AppButton(label: 'Continue', onPressed: _continue),
    );
  }
}
