import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/core/theme/colors.dart';
import 'package:gotruck_customer/screens/home/tabs/history_tab.dart';
import 'package:gotruck_customer/screens/home/tabs/home_tab.dart';
import 'package:gotruck_customer/screens/home/tabs/map_tab.dart';
import 'package:gotruck_customer/screens/home/tabs/notifications_tab.dart';
import 'package:gotruck_customer/screens/home/tabs/profile_tab.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  const HomeShellScreen({super.key});

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  int _currentIndex = 0;

  final _tabs = const <_TabData>[
    _TabData(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    _TabData(
      label: 'Map',
      icon: Icons.location_on_outlined,
      selectedIcon: Icons.location_on,
    ),
    _TabData(
      label: 'History',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
    ),
    _TabData(
      label: 'Notifications',
      icon: Icons.notifications_none,
      selectedIcon: Icons.notifications,
    ),
    _TabData(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    debugPrint(authState.profileData?.displayName);
    final userName = authState.profileData?.displayName?.isNotEmpty == true
        ? authState.profileData?.displayName ?? ''
        : 'ronald richards';
    final userEmail = authState.userData?.data.email.isNotEmpty == true
        ? authState.userData?.data.email ?? ''
        : 'ronaldrichards@gmail.com';
    Future<void> handleLogout() async {
      await ref.read(authProvider.notifier).logout();
      if (!mounted) return;
      context.go('/login');
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _buildCurrentTab(
          userName: userName,
          userEmail: userEmail,
          onLogout: handleLogout,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: cardColor,
        indicatorColor: primaryColor.withValues(alpha: 0.14),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon, color: greyFont),
                selectedIcon: Icon(tab.selectedIcon, color: primaryColor),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCurrentTab({
    required String userName,
    required String userEmail,
    required Future<void> Function() onLogout,
  }) {
    switch (_currentIndex) {
      case 0:
        return HomeTab(userName: userName, onLogout: onLogout);
      case 1:
        return const MapTab();
      case 2:
        return const HistoryTab();
      case 3:
        return const NotificationsTab(hasNotifications: true);
      case 4:
        return ProfileTab(name: userName, email: userEmail, onLogout: onLogout);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TabData {
  const _TabData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
