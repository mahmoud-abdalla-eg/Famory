import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_screen_enhanced.dart';
import 'screens/tasks_screen_enhanced.dart';
import 'screens/calendar_screen_enhanced.dart';
import 'screens/photos_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/bottom_nav.dart';
import 'services/event_service.dart';

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

class OneFamoryApp extends StatelessWidget {
  const OneFamoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Famory',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AppContainer(),
    );
  }
}

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

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
        return SettingsScreen(onBack: navigateBack);
      default:
        return DashboardScreen(onNavigate: navigateTo);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasOnboarded) {
      return OnboardingScreen(onComplete: completeOnboarding);
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: KeyedSubtree(
          key: ValueKey(currentScreen),
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
