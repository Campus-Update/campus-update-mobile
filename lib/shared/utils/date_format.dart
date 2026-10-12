import 'package:intl/intl.dart';

abstract final class AppDateFormat {
  static final _day = DateFormat('d MMM yyyy');
  static final _dayTime = DateFormat('d MMM yyyy, HH:mm');
  static final _weekdayDay = DateFormat('EEE d MMMM');
  static final _dayMonth = DateFormat('d MMMM');
  static final _eventDate = DateFormat('MMM d, yyyy');
  static final _time = DateFormat('h:mm a');

  static String day(DateTime value) => _day.format(value.toLocal());
  static String dayTime(DateTime value) => _dayTime.format(value.toLocal());

  /// An article's date — '16 September'.
  static String dayMonth(DateTime value) => _dayMonth.format(value.toLocal());

  /// An event's date on the Events tab — 'OCT 12, 2024'.
  static String eventDate(DateTime value) =>
      _eventDate.format(value.toLocal()).toUpperCase();

  /// A time of day — '9:00 AM'.
  static String time(DateTime value) => _time.format(value.toLocal());

  /// An event's day — 'Mon 21 September'.
  static String weekdayDay(DateTime value) =>
      _weekdayDay.format(value.toLocal());

  /// Feed timestamps: recent items read better as a relative age.
  static String relative(DateTime value) {
    final diff = DateTime.now().difference(value.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return day(value);
  }
}
