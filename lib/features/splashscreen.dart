import 'package:animate_do/animate_do.dart';
import 'package:campus_update/core/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/utils/navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(
  //     Duration(milliseconds: 2500),
  //     () {
  //       navigateWithoutAnimation(
  //           screen: NavBar(
  //         refreshUserData: true,
  //       ));
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.seed,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FadeIn(
              //   duration: Duration(milliseconds: 1000),
              //   child: SvgPicture.asset(
              //     AppIcons.logo_boon,
              //     colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              //     height: 50.h,
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}