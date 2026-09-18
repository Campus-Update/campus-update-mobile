import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Event',
      child: EmptyState(
        message: 'Not built yet.',
        icon: Icons.construction_outlined,
      ),
    );
  }
}
