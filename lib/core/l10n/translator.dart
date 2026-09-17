import 'package:campus_update/main.dart';
import 'package:campus_update/core/l10n/app_localizations.dart';

String translate(String key, {Map<String, String>? args}) {
  String translated = AppLocalizations.of(Get.context!)!.translate(key);
  if (args != null) {
    args.forEach((placeholder, value) {
      translated = translated.replaceAll('{$placeholder}', value);
    });
  }
  return translated;
}