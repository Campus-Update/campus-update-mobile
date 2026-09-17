import 'package:campus_update/core/config/app_theme.dart';
import 'package:campus_update/core/services/dependency_injection/dependency_injection.dart';
import 'package:campus_update/features/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/config/constant.dart';
import 'core/l10n/app_localizations.dart';
import 'core/services/secure_storage/user_data_read/user_data_notifier.dart';
import 'package:timeago/timeago.dart' as timeago;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  setupLocator();
  timeago.setLocaleMessages(
      'fr', timeago.FrMessages()); 
  timeago.setLocaleMessages('ar', timeago.ArMessages());

  runApp(ProviderScope(child: MyApp()));
  FlutterNativeSplash.remove();
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      ref.read(userDataReaderProvider.notifier).loadUserData();
      // final themeMode = ref.watch(themeStateNotifierProvider);
      return ScreenUtilInit(
          designSize: Size(393, 852),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return Builder(builder: (context) {
              return MaterialApp(
                builder: EasyLoading.init(),
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                title: AppConstant.appName,
                theme: AppTheme.light(),
                // localizationsDelegates: [
                //   AppLocalizations.delegate,
                //   GlobalMaterialLocalizations.delegate,
                //   GlobalWidgetsLocalizations.delegate,
                //   GlobalCupertinoLocalizations.delegate,
                // ],
                supportedLocales: [
                  const Locale('en', 'US'),
                  const Locale('fr', 'FR'),
                  const Locale('ar', 'TN')
                ],
                home: child,
              );
            });
          },
          child: SplashScreen());
    });
  }
}

class Get {
  static BuildContext? get context => navigatorKey.currentContext;
}