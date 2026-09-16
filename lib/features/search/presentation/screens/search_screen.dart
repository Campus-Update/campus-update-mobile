import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Search',
      child: EmptyState(
        message: 'Not built yet.',
        icon: Icons.construction_outlined,
      ),
    );
  }
}
