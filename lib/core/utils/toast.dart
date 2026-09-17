import 'package:animate_do/animate_do.dart';
import 'package:campus_update/core/utils/screen_dimension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';

class ToastHelper {
  static void showToast(
    BuildContext context,
    String message,
    Color textColor, {
    Alignment? alignment,
    ToastPosition? toastStartPosition,
  }) {
    FocusScope.of(context).unfocus();
    InteractiveToast.slide(
      context : context,
      title: Text(message,
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(color: textColor, fontWeight: FontWeight.w300)),
      toastSetting: SlidingToastSetting(
        maxWidth: ScreenDimension.width * 0.95,
        animationDuration: Duration(seconds: 1),
        displayDuration: Duration(seconds: 2),
        toastStartPosition: toastStartPosition ?? ToastPosition.bottom,
        toastAlignment: alignment ?? Alignment.bottomCenter,
        progressBarHeight: 4,
      ),
      toastStyle: ToastStyle(
        glassBlur: 4,
        backgroundColorOpacity: .7,
      ),
    );
  }

  static void showCustomSnackbar({
    required BuildContext context,
    required String message,
    required int durationMs,
  }) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20.h,
        left: 0,
        right: 0,
        child: FadeIn(
          child: Material(
            elevation: 4,
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
              ),
              child: Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.black87),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    Future.delayed(Duration(milliseconds: durationMs), () {
      overlayEntry.remove();
    });
  }
}