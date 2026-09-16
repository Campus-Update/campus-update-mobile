import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'News',
      child: EmptyState(
        message: 'Not built yet.',
        icon: Icons.construction_outlined,
      ),
    );
  }
}
