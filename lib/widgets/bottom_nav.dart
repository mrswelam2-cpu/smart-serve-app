// bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withValues(alpha: 0.1),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) {
        switch (i) {
          case 0: context.go('/');
          case 1: context.go('/businesses');
          case 2: context.go('/craftsmen');
          case 3: context.go('/categories');
          case 4: context.go('/profile');
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
        NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: 'الأعمال'),
        NavigationDestination(icon: Icon(Icons.handyman_outlined), selectedIcon: Icon(Icons.handyman), label: 'الحرفيون'),
        NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'الفئات'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
      ],
    );
  }
}
