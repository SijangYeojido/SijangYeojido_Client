import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/sds_widgets.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'home/nearby_map_screen.dart';
import 'profile/profile_screen.dart';
import 'merchant/merchant_dashboard.dart';
import 'merchant/product_management_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  List<Widget> _getScreens(UserRole role) {
    if (role == UserRole.admin) {
      return const [
        AdminDashboardScreen(),
        HomeScreen(),
        NearbyMapScreen(),
        ProfileScreen(),
      ];
    }
    if (role == UserRole.merchant) {
      return [
        const MerchantDashboard(),
        const ProductManagementScreen(),
        const ProfileScreen(),
      ];
    }
    return [const HomeScreen(), const NearbyMapScreen(), const ProfileScreen()];
  }

  List<SDSFloatingTabItem> _getTabItems(UserRole role) {
    if (role == UserRole.admin) {
      return const [
        SDSFloatingTabItem(
          icon: Icons.admin_panel_settings_outlined,
          activeIcon: Icons.admin_panel_settings_rounded,
          label: '운영',
        ),
        SDSFloatingTabItem(
          icon: Icons.home_rounded,
          activeIcon: Icons.home_rounded,
          label: '홈',
        ),
        SDSFloatingTabItem(
          icon: Icons.location_on_outlined,
          activeIcon: Icons.location_on_rounded,
          label: '지도',
        ),
        SDSFloatingTabItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: '내 정보',
        ),
      ];
    }
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
    final currentIndex = _currentIndex >= screens.length ? 0 : _currentIndex;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: screens
                .map(
                  (screen) => Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: screen,
                  ),
                )
                .toList(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: SDSFloatingTabbar(
              currentIndex: currentIndex,
              onTap: (index) => _handleTabTap(context, auth, index),
              items: items,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTabTap(BuildContext context, AuthProvider auth, int index) {
    if (!auth.isLoggedIn && _requiresLogin(auth.role, index)) {
      _showLoginRequired(context);
      return;
    }
    setState(() => _currentIndex = index);
  }

  bool _requiresLogin(UserRole role, int index) {
    if (role == UserRole.admin || role == UserRole.merchant) return true;
    return index == 2;
  }

  void _showLoginRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('예약, 쿠폰, 내 정보 기능은 로그인 후 이용할 수 있습니다.')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
