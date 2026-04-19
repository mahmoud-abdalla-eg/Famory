import 'package:flutter/material.dart';
import '../../../../app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final void Function(String languageCode)? onChangeLanguage;
  final Locale? currentLocale;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.onChangeLanguage,
    this.currentLocale,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentSlide = 0;
  final PageController _pageController = PageController();

  final List<_OnboardingSlideData> _slides = const [
    _OnboardingSlideData(
      icon: Icons.home_rounded,
      titleKey: 'welcome1',
      descriptionKey: 'welcome1des',
      color: Color(0xFF41A9E8),
    ),
    _OnboardingSlideData(
      icon: Icons.forum_rounded,
      titleKey: 'welcome2',
      descriptionKey: 'welcome2des',
      color: Color(0xFFF7933F),
    ),
    _OnboardingSlideData(
      icon: Icons.calendar_today_rounded,
      titleKey: 'welcome3',
      descriptionKey: 'welcome3des',
      color: Color(0xFF58B894),
    ),
    _OnboardingSlideData(
      icon: Icons.image_rounded,
      titleKey: 'welcome4',
      descriptionKey: 'welcome4des',
      color: Color(0xFF41A9E8),
    ),
  ];

  void _nextSlide() {
    if (currentSlide < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _slides.length,
          onPageChanged: (index) {
            setState(() {
              currentSlide = index;
            });
          },
          itemBuilder: (context, index) {
            final slide = _slides[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: slide.color,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      slide.icon,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 56),
                  Text(
                    t.translate(slide.titleKey),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111111),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      t.translate(slide.descriptionKey),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8B8B8B),
                        height: 1.45,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  Row(
                    children: [
                      Expanded(
                        flex: index == 0 ? 3 : 1,
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _nextSlide,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF1677F2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              t.translate('continue'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (index == 0) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _skip,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFFB88A61),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                t.translate('skip'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _OnboardingSlideData {
  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final Color color;

  const _OnboardingSlideData({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.color,
  });
}
