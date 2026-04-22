import 'package:flutter/material.dart';
import '../../../../widgets/bottom_nav.dart';
import 'empty_dashboard_screen.dart';
import 'family_dashboard_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import '../../../chat/presentation/screens/chat_home_screen.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';
import '../../../memories/presentation/screens/memories_screen.dart';
import '../../../family/data/services/family_service.dart';

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
  String currentScreen = 'home';

  void navigateTo(String screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  Widget renderScreen() {
    switch (currentScreen) {
      case 'home':
        return FamilyService().hasFamily
            ? FamilyDashboardScreen(onNavigate: navigateTo)
            : const EmptyDashboardScreen();
      case 'chat':
        return const ChatHomeScreen();
      case 'tasks':
        return const TasksScreen();
      case 'calendar':
        return const CalendarScreen();
      case 'photos':
        return const MemoriesScreen();
      default:
        return FamilyService().hasFamily
            ? FamilyDashboardScreen(onNavigate: navigateTo)
            : const EmptyDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
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
