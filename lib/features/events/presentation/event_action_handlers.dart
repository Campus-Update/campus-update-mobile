import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/event_actions.dart';
import '../domain/event_item.dart';

/// Opens [event]'s sign-up page, saying so when it cannot. An event that
/// takes no sign-ups goes into the calendar instead, as the button's calendar
/// icon suggests.
Future<void> registerForEvent(
  BuildContext context,
  WidgetRef ref,
  EventItem event,
) async {
  if (event.registrationUrl == null) {
    addEventToCalendar(context, ref, event);
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  final opened = await ref.read(eventActionsProvider).openRegistration(event);
  if (opened) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text("Couldn't open the registration page."),
        duration: Duration(seconds: 2),
      ),
    );
}

/// Opens the phone's calendar with [event] filled in.
void addEventToCalendar(BuildContext context, WidgetRef ref, EventItem event) {
  if (ref.read(eventActionsProvider).addToCalendar(event)) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('This event has no date yet.'),
        duration: Duration(seconds: 2),
      ),
    );
}
