import 'dart:developer';

import 'package:campus_update/main.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

void navigateWithoutAnimation({required Widget screen}) {
  Navigator.of(Get.context!).pushReplacement(PageRouteBuilder(
    transitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) => screen,
  ));
}

void navigateWithoutAnimationDisposingNavbar({required Widget screen}) {
  Navigator.of(Get.context!).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => screen),
    (route) => false,
  );
}

void navigateWithPersistentNavBar({
  required BuildContext context,
  required Widget screen,
  bool? withNavBar,
  PageTransitionAnimation pageTransitionAnimation =
      PageTransitionAnimation.cupertino,
}) {
  log("navbar :::: $withNavBar");
  PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
    context,
    settings: RouteSettings(),
    screen: screen,
    withNavBar: withNavBar ?? false,
    pageTransitionAnimation: pageTransitionAnimation,
  );
}

Future<T?> navigateWithPersistentNavBarr<T>({
  required BuildContext context,
  required Widget screen,
  bool? withNavBar,
  PageTransitionAnimation pageTransitionAnimation =
      PageTransitionAnimation.cupertino,
}) async {
  final result = await PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
    context,
    settings: const RouteSettings(),
    screen: screen,
    withNavBar: false,
    pageTransitionAnimation: pageTransitionAnimation,
  );

  return result as T?;
}