import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/onboarding/announcements_illustration.dart';
import '../widgets/onboarding/events_illustration.dart';
import '../widgets/onboarding/news_illustration.dart';
import '../widgets/onboarding/onboarding_backdrop.dart';
import '../widgets/onboarding/onboarding_style.dart';
import '../widgets/onboarding/slide_to_next_button.dart';

/// First run only: three animated pages introducing news, announcements and
/// the calendar.
///
/// It opens on exactly what the splash screen shows — the mark on the indigo
/// surface — and dissolves from there into the first page, so the hand-over
/// from splash is seamless. Each page then builds itself in: artwork first,
/// then the pill, title and body. Moving on slides the page away to the left;
/// the lavender ground behind stays put.
///
/// Built from the motion export alone — there is no Figma for these screens
/// yet — so the measurements in the onboarding widgets are readings off video
/// frames. See onboarding_style.dart.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  static final _pages = [
    _Page(
      label: 'Official News',
      icon: Icons.article_outlined,
      title: 'Stay Informed With\nOfficial News',
      body:
          'Read verified news from your school,\nsorted for your faculty '
          'and level.',
      fill: 0.48,
      art: (enter, idle) => NewsIllustration(enter: enter, idle: idle),
    ),
    _Page(
      label: 'Announcements',
      icon: Icons.notifications_none_rounded,
      title: 'Never Miss What\nMatters Most',
      body: 'Clear priority labels show you what\nneeds your attention first.',
      fill: 0.71,
      art: (enter, idle) => AnnouncementsIllustration(enter: enter, idle: idle),
    ),
    _Page(
      label: 'Events & Calendar',
      icon: Icons.calendar_month_outlined,
      title: 'Events and Dates,\nAll in One Place',
      body:
          'Find campus events and keep track of\nexams, registration and '
          'holidays.',
      fill: 1,
      art: (enter, idle) => EventsIllustration(enter: enter, idle: idle),
    ),
  ];

  /// The dissolve from the splash into the first page.
  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  /// One page building itself in. Restarted for every page.
  late final _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  /// The current page sliding away.
  late final _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  /// Loops for as long as the screen is up: tags bob, the dial creeps, the
  /// chevrons shimmer.
  late final _idle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  /// How far into the dissolve the first page starts to build.
  static const _firstPageAt = 0.3;

  int _page = 0;

  /// 1 when moving forward, -1 when going back, so pages leave the right way.
  int _direction = 1;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _intro.addListener(_startFirstPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _intro.value = 1;
      _enter.value = 1;
      _idle.stop();
    } else if (!_intro.isAnimating && _intro.value == 0) {
      _intro.forward();
      _idle.repeat();
    }
  }

  void _startFirstPage() {
    if (_intro.value >= _firstPageAt && _enter.value == 0) {
      _intro.removeListener(_startFirstPage);
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _enter.dispose();
    _exit.dispose();
    _idle.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _pages.length - 1;

  Future<void> _goTo(int page) async {
    if (page < 0 || page >= _pages.length || page == _page) return;
    if (_exit.isAnimating) return;
    _direction = page > _page ? 1 : -1;
    if (!_reduceMotion) await _exit.forward(from: 0);
    if (!mounted) return;
    setState(() => _page = page);
    _exit.value = 0;
    if (_reduceMotion) {
      _enter.value = 1;
    } else {
      _enter.forward(from: 0);
    }
  }

  /// Recorded on the way out, so onboarding is shown once and never again.
  Future<void> _leaveTo(String route) async {
    await ref.read(prefsStorageProvider).setOnboardingSeen(true);
    if (mounted) context.go(route);
  }

  /// A swipe across the page turns it, as well as the button.
  void _swipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) _goTo(_page + 1);
    if (velocity > 300) _goTo(_page - 1);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_page];
    final width = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(_page - 1);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: _swipe,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  width: width,
                  height:
                      width * OnboardingCanvas.height / OnboardingCanvas.width,
                  child: FittedBox(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: OnboardingCanvas.width,
                      height: OnboardingCanvas.height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const OnboardingBackdrop(),
                          Positioned.fill(
                            child: ExcludeSemantics(
                              child: _Leaving(
                                exit: _exit,
                                direction: _direction,
                                child: _FadeOut(
                                  child: KeyedSubtree(
                                    key: ValueKey(_page),
                                    child: page.art(_enter, _idle),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(25, 0, 25, bottomInset + 21),
                    child: Column(
                      children: [
                        const Spacer(),
                        _Leaving(
                          exit: _exit,
                          direction: _direction,
                          child: _PageText(page: page, enter: _enter),
                        ),
                        const SizedBox(height: 45),
                        FadeTransition(
                          opacity: stage(_intro, 0.75, 1),
                          child: SlideToNextButton(
                            fill: page.fill,
                            last: _isLast,
                            idle: _idle,
                            onNext: () => _goTo(_page + 1),
                            onFinish: () => _leaveTo(Routes.register),
                          ),
                        ),
                        const SizedBox(height: 21),
                        _Leaving(
                          exit: _exit,
                          direction: 0,
                          child: Visibility.maintain(
                            visible: _isLast,
                            child: FadeTransition(
                              opacity: stage(_enter, 0.85, 1),
                              child: _LoginPrompt(
                                onLogin: () => _leaveTo(Routes.login),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(child: _SplashHandOver(intro: _intro)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Page {
  const _Page({
    required this.label,
    required this.icon,
    required this.title,
    required this.body,
    required this.fill,
    required this.art,
  });

  final String label;
  final IconData icon;
  final String title;
  final String body;

  /// How much of the button's track the pill covers on this page.
  final double fill;

  final Widget Function(Animation<double> enter, Animation<double> idle) art;
}

/// Slides and fades its child away as the page leaves. A [direction] of 0
/// fades in place.
class _Leaving extends StatelessWidget {
  const _Leaving({
    required this.exit,
    required this.direction,
    required this.child,
  });

  final Animation<double> exit;
  final int direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: exit,
      builder: (context, child) {
        final t = Curves.easeInCubic.transform(exit.value);
        return Opacity(
          opacity: 1 - t,
          child: Transform.translate(
            offset: Offset(-direction * 60 * t, 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Fades the foot of the artwork into the white page, as the ground behind
/// it does.
class _FadeOut extends StatelessWidget {
  const _FadeOut({required this.child});

  final Widget child;

  static const _from = 365 / OnboardingCanvas.height;
  static const _to = 428 / OnboardingCanvas.height;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0, _from, _to],
      ).createShader(rect),
      child: child,
    );
  }
}

/// The pill, title and body under the artwork, each arriving in turn.
class _PageText extends StatelessWidget {
  const _PageText({required this.page, required this.enter});

  final _Page page;
  final Animation<double> enter;

  static const _title = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 38,
    height: 44 / 38,
    fontWeight: AppFonts.medium,
    letterSpacing: -0.76,
    color: AppColors.graphite,
  );

  static const _body = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: AppFonts.regular,
    letterSpacing: -0.32,
    color: AppColors.fieldLabel,
  );

  Widget _rise(Animation<double> t, Widget child) => AnimatedBuilder(
    animation: t,
    builder: (context, child) => Opacity(
      opacity: t.value,
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - t.value)),
        child: child,
      ),
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _rise(
          stage(enter, 0.4, 0.6),
          _PagePill(label: page.label, icon: page.icon),
        ),
        const SizedBox(height: 17),
        _rise(
          stage(enter, 0.48, 0.75),
          Text(page.title, textAlign: TextAlign.center, style: _title),
        ),
        const SizedBox(height: 1),
        _rise(
          stage(enter, 0.62, 0.88),
          Text(page.body, textAlign: TextAlign.center, style: _body),
        ),
      ],
    );
  }
}

/// The small labelled pill naming what a page is about.
class _PagePill extends StatelessWidget {
  const _PagePill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: OnboardingColors.pill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingColors.pillBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.indigo),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.family,
              fontSize: 14,
              height: 20 / 14,
              fontWeight: AppFonts.medium,
              color: AppColors.graphite,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: AppFonts.family,
      fontSize: 13,
      height: 20 / 13,
      fontWeight: AppFonts.regular,
      color: AppColors.graphite,
    );
    // Wrap rather than Row: at a large text scale the line runs wider than
    // the screen, and Wrap drops "Login" to the next line instead of
    // overflowing.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('Already have an Account? ', style: style),
        GestureDetector(
          onTap: onLogin,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'Login',
            style: style.copyWith(
              color: AppColors.link,
              fontWeight: AppFonts.medium,
            ),
          ),
        ),
      ],
    );
  }
}

/// What the splash screen shows — the mark on the indigo surface — fading
/// and swelling away to reveal the first page.
class _SplashHandOver extends StatelessWidget {
  const _SplashHandOver({required this.intro});

  final Animation<double> intro;

  @override
  Widget build(BuildContext context) {
    final out = stage(intro, 0, 0.45, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: out,
      builder: (context, _) {
        if (out.value >= 1) return const SizedBox.shrink();
        return IgnorePointer(
          child: Opacity(
            opacity: 1 - out.value,
            child: ColoredBox(
              color: AppColors.indigoSurface,
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, 24 * out.value),
                  child: Transform.scale(
                    scale: 1 + 0.15 * out.value,
                    child: const AppLogo(size: 140),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
