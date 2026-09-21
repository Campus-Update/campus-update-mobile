import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Campus Update mark.
///
/// Ships as SVG so it stays sharp at any size. It carries the brand indigo
/// itself; pass [color] only where the mark sits on a coloured ground and has
/// to be knocked out — the design provides white-on-indigo and black-on-indigo
/// lockups for that.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72, this.color});

  final double size;
  final Color? color;

  static const _asset = 'assets/images/logo.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _asset,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
      semanticsLabel: 'Campus Update',
    );
  }
}
