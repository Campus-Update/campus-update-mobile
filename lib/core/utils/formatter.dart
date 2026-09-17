import 'package:intl/intl.dart';

import '../models/staff.dart';
import '../models/student.dart';

dynamic parseUser(Map<String, dynamic> json) {
  if (json['role'] == 'agent') {
    return Staff.fromJson(json);
  } else {
    return Student.fromJson(json);
  }
}

String getEquipmentDisplayText(List<String> equipment) {
  if (equipment.length > 5) {
    return '${equipment.take(5).join(", ")}... +${equipment.length - 5} more';
  } else {
    return equipment.join(", ");
  }
}

String formatDate({required String inputDate, required String languageCode}) {
  DateTime dateTime = DateTime.parse(inputDate);
  String locale;
  switch (languageCode.toLowerCase()) {
    case 'fr':
      locale = 'fr_FR';
      break;
    case 'ar':
      locale = 'ar_EG';
      break;
    case 'en':
      locale = 'en_US';
      break;
    default:
      locale = 'en_US';
  }
  String dayOfWeek = DateFormat('EEEE', locale).format(dateTime);
  String day = dateTime.day.toString();
  String month = DateFormat('MMMM', locale).format(dateTime);
  String year = dateTime.year.toString();
  return "$dayOfWeek $day $month $year";
}