import 'package:intl/intl.dart';

abstract final class AppDateFormat {
  static final _day = DateFormat('d MMM yyyy');
  static final _dayTime = DateFormat('d MMM yyyy, HH:mm');

  static String day(DateTime value) => _day.format(value.toLocal());
  static String dayTime(DateTime value) => _dayTime.format(value.toLocal());

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
