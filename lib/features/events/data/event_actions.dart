import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart' as cal;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/event_item.dart';

/// What the Register and Add to calendar buttons do. The API keeps no record
/// of either: registering happens on the organiser's own page, and the event
/// goes into the phone's calendar.
class EventActions {
  const EventActions();

  /// Opens the event's sign-up page in the browser. False when it has none or
  /// the page could not be opened.
  Future<bool> openRegistration(EventItem event) async {
    final url = Uri.tryParse(event.registrationUrl ?? '');
    if (url == null || !url.hasScheme) return false;
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }

  /// Opens the phone's own new-event sheet filled in with [event], where the
  /// user saves or cancels. False when the event has no date yet.
  ///
  /// The sheet is not awaited: on iOS 17 and later the plugin never reports
  /// back, and on neither platform does it say whether the event was saved.
  bool addToCalendar(EventItem event) {
    final start = event.startsAt;
    if (start == null) return false;
    unawaited(
      cal.Add2Calendar.addEvent2Cal(
        cal.Event(
          title: event.title,
          description: event.description,
          location: event.location.isEmpty ? null : event.location,
          startDate: start.toLocal(),
          // With no end given, an hour is what calendars assume too.
          endDate: (event.endsAt ?? start.add(const Duration(hours: 1)))
              .toLocal(),
          iosParams: cal.IOSParams(url: event.registrationUrl),
        ),
      ),
    );
    return true;
  }
}

final eventActionsProvider = Provider<EventActions>(
  (ref) => const EventActions(),
);
