import 'package:campus_update/features/calendar/data/official_calendar.dart';

/// Stands in for `GET /calendar`: no calendar published, as on dev.
final fakeCalendarOverride = officialCalendarProvider.overrideWith(
  (ref) async => null,
);
