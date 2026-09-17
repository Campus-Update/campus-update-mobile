import 'package:timeago/timeago.dart' as timeago;

class FrMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => "il y a";
  @override
  String prefixFromNow() => "dans";
  @override
  String suffixAgo() => "";
  @override
  String suffixFromNow() => "";
  @override
  String lessThanOneMinute(int seconds) => "quelques secondes";
  @override
  String aboutAMinute(int minutes) => "une minute";
  @override
  String minutes(int minutes) => "$minutes minutes";
  @override
  String aboutAnHour(int minutes) => "une heure";
  @override
  String hours(int hours) => "$hours heures";
  @override
  String aDay(int hours) => "un jour";
  @override
  String days(int days) => "$days jours";
  @override
  String aboutAMonth(int days) => "un mois";
  @override
  String months(int months) => "$months mois";
  @override
  String aboutAYear(int year) => "un an";
  @override
  String years(int years) => "$years ans";
  @override
  String wordSeparator() => " ";
}

class ArMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => "منذ";
  @override
  String prefixFromNow() => "في";
  @override
  String suffixAgo() => "";
  @override
  String suffixFromNow() => "";
  @override
  String lessThanOneMinute(int seconds) => "ثوانٍ";
  @override
  String aboutAMinute(int minutes) => "دقيقة";
  @override
  String minutes(int minutes) => "$minutes دقائق";
  @override
  String aboutAnHour(int minutes) => "ساعة";
  @override
  String hours(int hours) => "$hours ساعات";
  @override
  String aDay(int hours) => "يوم";
  @override
  String days(int days) => "$days أيام";
  @override
  String aboutAMonth(int days) => "شهر";
  @override
  String months(int months) => "$months أشهر";
  @override
  String aboutAYear(int year) => "سنة";
  @override
  String years(int years) => "$years سنوات";
  @override
  String wordSeparator() => " ";
}