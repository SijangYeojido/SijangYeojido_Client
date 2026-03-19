import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/sds_widgets.dart';
import 'home/home_screen.dart';
import 'home/nearby_map_screen.dart';
import 'reservation/reservation_list_screen.dart';
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
        const ReservationListScreen(), // Reuse for merchant orders
        const ProfileScreen(),
      ];
    }
    return [
      const HomeScreen(),
      const NearbyMapScreen(),
      const ReservationListScreen(),
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
          icon: Icons.shopping_bag_outlined,
          activeIcon: Icons.shopping_bag_rounded,
          label: '주문 관리',
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
        icon: Icons.home_rounded,
        activeIcon: Icons.home_rounded,
        label: '홈',
      ),
      SDSFloatingTabItem(
        icon: Icons.location_on_outlined,
        activeIcon: Icons.location_on_rounded,
        label: '지도로 찾기',
      ),
      SDSFloatingTabItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: '주문 내역',
      ),
      SDSFloatingTabItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: '내 정보',
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
