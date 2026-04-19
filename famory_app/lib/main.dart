import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme.dart';
import 'app_localizations.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/family_dashboard_screen.dart';
import 'features/chat/presentation/screens/chat_screen_enhanced.dart';
import 'features/tasks/presentation/screens/tasks_screen_enhanced.dart';
import 'features/calendar/presentation/screens/calendar_screen_enhanced.dart';
import 'features/memories/presentation/screens/photos_screen.dart';
import 'features/settings/settings_screen.dart';
import 'widgets/bottom_nav.dart';
import 'features/calendar/data/services/event_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const OneFamoryApp());
}

class OneFamoryApp extends StatefulWidget {
  const OneFamoryApp({super.key});

  @override
  State<OneFamoryApp> createState() => _OneFamoryAppState();
}

class _OneFamoryAppState extends State<OneFamoryApp> {
  Locale _locale = const Locale('en');

  void changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Famory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('cn'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final isArabic = _locale.languageCode == 'ar';
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: AppContainer(
        onChangeLanguage: changeLanguage,
        currentLocale: _locale,
      ),
    );
  }
}

class AppContainer extends StatefulWidget {
  final void Function(String languageCode) onChangeLanguage;
  final Locale currentLocale;

  const AppContainer({
    super.key,
    required this.onChangeLanguage,
    required this.currentLocale,
  });

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  bool hasOnboarded = false;
  String currentScreen = 'home';

  @override
  void initState() {
    super.initState();
    EventService().initializeSampleEvents();
  }

  void completeOnboarding() {
    setState(() {
      hasOnboarded = true;
    });
  }

  void navigateTo(String screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  void navigateBack() {
    setState(() {
      currentScreen = 'home';
    });
  }

  Widget renderScreen() {
    switch (currentScreen) {
      case 'home':
        return DashboardScreen(onNavigate: navigateTo);

      case 'chat':
        return ChatScreenEnhanced(onBack: navigateBack);

      case 'tasks':
        return TasksScreenEnhanced(onBack: navigateBack);

      case 'calendar':
        return CalendarScreenEnhanced(onBack: navigateBack);

      case 'photos':
        return PhotosScreen(onBack: navigateBack);

      case 'settings':
        return SettingsScreen(
          onBack: navigateBack,
          onChangeLanguage: widget.onChangeLanguage,
          currentLocale: widget.currentLocale,
        );

      default:
        return DashboardScreen(onNavigate: navigateTo);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasOnboarded) {
      return OnboardingScreen(
        onComplete: completeOnboarding,
        onChangeLanguage: widget.onChangeLanguage,
        currentLocale: widget.currentLocale,
      );
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: KeyedSubtree(
          key:
              ValueKey('${currentScreen}_${widget.currentLocale.languageCode}'),
          child: renderScreen(),
        ),
      ),
      bottomNavigationBar: BottomNav(
        activeTab: currentScreen,
        onTabChange: navigateTo,
      ),
    );
  }
}
