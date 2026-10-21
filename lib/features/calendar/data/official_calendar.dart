import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/network_providers.dart';

/// The school's published academic calendar, from `GET /calendar`.
///
/// One picture of the official calendar for the session, not dated entries:
/// the month grid still has nothing from the API to draw from.
class OfficialCalendar {
  const OfficialCalendar({
    required this.title,
    required this.academicSession,
    required this.imageUrl,
  });

  factory OfficialCalendar.fromJson(Map<String, dynamic> json) =>
      OfficialCalendar(
        title: json['title'] as String? ?? 'Academic calendar',
        academicSession: json['academicSession'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
      );

  final String title;

  /// e.g. 2025/2026.
  final String academicSession;

  /// A PNG, JPEG or WebP. Uploaded ones are signed links that stop working
  /// after 15 minutes, so the calendar is fetched again before it is opened.
  final String imageUrl;
}

/// The signed-in user's school calendar, or null when the school has not
/// published one (the API's 404).
final officialCalendarProvider = FutureProvider.autoDispose<OfficialCalendar?>((
  ref,
) async {
  try {
    final res = await ref
        .watch(dioProvider)
        .get<Map<String, dynamic>>('/api/v1/calendar');
    return OfficialCalendar.fromJson(res.data ?? const {});
  } on DioException catch (e) {
    final error = ApiException.from(e);
    if (error.isNotFound) return null;
    throw error;
  }
});
