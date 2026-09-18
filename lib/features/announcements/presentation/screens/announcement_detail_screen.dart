import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Announcement',
      child: EmptyState(
        message: 'Not built yet.',
        icon: Icons.construction_outlined,
      ),
    );
  }
}
