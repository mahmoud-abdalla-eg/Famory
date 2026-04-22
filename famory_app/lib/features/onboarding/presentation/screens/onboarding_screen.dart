import 'package:flutter/material.dart';

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
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<_SlideData> _slides = const [
    _SlideData(
      icon: Icons.home_rounded,
      title: 'Welcome to One Famory',
      description:
          'One family home base for staying connected\nand keeping memories',
      iconColor: Colors.white,
      iconBgColor: Color(0xFF41A9E8),
    ),
    _SlideData(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Stay Connected',
      description: 'Chat, share moments, and keep everyone in\nthe loop',
      iconColor: Colors.white,
      iconBgColor: Color(0xFFF7933F),
    ),
    _SlideData(
      icon: Icons.calendar_today_rounded,
      title: 'Organize Together',
      description: 'Shared calendars and tasks that work for\nthe whole family',
      iconColor: Colors.white,
      iconBgColor: Color(0xFF58B894),
    ),
    _SlideData(
      icon: Icons.photo_library_rounded,
      title: 'Cherish Memories',
      description: 'Your family photo album, always with you',
      iconColor: Colors.white,
      iconBgColor: Color(0xFF41A9E8),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: _slides.length,
          itemBuilder: (context, index) {
            final slide = _slides[index];
            return _buildSlide(slide, index);
          },
        ),
      ),
    );
  }

  Widget _buildSlide(_SlideData slide, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Icon Container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.iconBgColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              slide.icon,
              size: 60,
              color: slide.iconColor,
            ),
          ),
          const SizedBox(height: 24), // Reduced from Spacer to fixed space
          // Title - BOLD
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Araboto',
              fontSize: 26,
              fontWeight: FontWeight.w700, // Use bold keyword
              color: Color(0xFF111111),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Description - Regular
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Araboto',
              fontSize: 15,
              fontWeight: FontWeight.w500, // Use normal keyword
              color: Color(0xFF777777),
              height: 1.5,
            ),
          ),
          const Spacer(flex: 2),
          // Dot Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == index
                      ? const Color(0xFF41A9E8)
                      : const Color(0xFFD9D9D9),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          // Buttons
          if (index == 0) ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF41A9E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Araboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _skip,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF7933F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: 'Araboto',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF41A9E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Araboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color iconBgColor;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.iconBgColor,
  });
}
