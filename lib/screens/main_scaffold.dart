import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/sds_widgets.dart';
import 'home/home_screen.dart';
import 'home/nearby_map_screen.dart';
import 'profile/profile_screen.dart';
import 'merchant/merchant_dashboard.dart';
import 'merchant/product_management_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  List<Widget> _getScreens(UserRole role) {
    if (role == UserRole.merchant) {
      return [
        const MerchantDashboard(),
        const ProductManagementScreen(),
        const ProfileScreen(),
      ];
    }
    return [
      const HomeScreen(),
      const NearbyMapScreen(),
      const ProfileScreen(),
    ];
  }

  List<SDSFloatingTabItem> _getTabItems(UserRole role) {
    if (role == UserRole.merchant) {
      return const [
        SDSFloatingTabItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: '대시보드',
        ),
        SDSFloatingTabItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded,
          label: '상품 관리',
        ),
        SDSFloatingTabItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: '내 정보',
        ),
      ];
    }
    return const [
      SDSFloatingTabItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: '홈',
      ),
      SDSFloatingTabItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: '탐색',
      ),
      SDSFloatingTabItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: '마이',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final screens = _getScreens(auth.role);
    final items = _getTabItems(auth.role);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens.map((screen) => Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: screen,
            )).toList(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: SDSFloatingTabbar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: items,
            ),
          ),
        ],
      ),
    );
  }
}
