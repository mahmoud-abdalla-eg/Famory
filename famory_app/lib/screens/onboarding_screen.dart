import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/custom_button.dart';

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentSlide = 0;
  final PageController _pageController = PageController();

  final List<OnboardingSlide> slides = [
    OnboardingSlide(
      icon: Icons.home_rounded,
      title: 'Welcome to One Famory',
      description: 'Your family\'s home base for staying connected and organized',
      color: AppColors.primaryBlue,
    ),
    OnboardingSlide(
      icon: Icons.chat_bubble_rounded,
      title: 'Stay Connected',
      description: 'Chat, share moments, and keep everyone in the loop',
      color: AppColors.accentOrange,
    ),
    OnboardingSlide(
      icon: Icons.calendar_today_rounded,
      title: 'Organize Together',
      description: 'Shared calendars and tasks that work for the whole family',
      color: AppColors.successGreen,
    ),
    OnboardingSlide(
      icon: Icons.photo_rounded,
      title: 'Cherish Memories',
      description: 'Your family photo album, always with you',
      color: AppColors.primaryBlue,
    ),
  ];

  void nextSlide() {
    if (currentSlide < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.softBlueBg, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentSlide = index;
                      });
                    },
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween<double>(begin: 0.8, end: 1.0),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    color: slide.color,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        color: slide.color.withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    slide.icon,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 48),
                          Text(
                            slide.title,
                            style: Theme.of(context).textTheme.displayLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            slide.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentSlide == index ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentSlide == index
                                ? slides[currentSlide].color
                                : AppColors.borderGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: currentSlide < slides.length - 1
                            ? 'Continue'
                            : 'Get Started',
                        onPressed: nextSlide,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
