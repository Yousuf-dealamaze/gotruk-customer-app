import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotruck_customer/screens/auth/auth_provider.dart';
import 'package:gotruck_customer/core/theme/colors.dart';

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
    final userName = authState.profileData?.displayName?.isNotEmpty == true
        ? authState.profileData?.displayName ?? ''
        : 'GoTruck User';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        surfaceTintColor: cardColor,
        title: Text(
          _tabs[_currentIndex].label,
          style: TextStyle(color: fontBlack, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: Icon(Icons.logout, color: primaryColor),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello, $userName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: fontBlack,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You are on ${_tabs[_currentIndex].label}.',
                style: TextStyle(color: greyFont),
              ),
            ],
          ),
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
