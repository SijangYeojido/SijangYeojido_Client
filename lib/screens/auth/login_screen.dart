import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/sijang_design_system.dart';
import '../../theme/app_colors.dart';
import '../../widgets/sds_widgets.dart';
import '../../widgets/shrinkable_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;
  UserRole _selectedRole = UserRole.customer;

  // Design Tokens for Absolute Consistency
  static const double _buttonHeight = 64.0;
  static const double _cardHeight = 110.0;
  static const double _horizontalPadding = 24.0;
  static const double _headerTopPadding = 56.0;

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [
          _buildStep(
            title: '전통의 가치를\n지도로 펼치다',
            subtitle: '시장여지도에서 내 주변 시장의\n모든 숨은 이야기들을 만나보세요.',
            content: _buildWelcomeContent(),
          ),
          _buildStep(
            title: '반가워요!\n어떻게 오셨나요?',
            subtitle: '상인과 사용자 중 본인에게 맞는\n최적화된 경험을 선택해 주세요.',
            content: _buildRoleContent(),
          ),
          _buildStep(
            title: '본격적으로\n시작해볼까요?',
            subtitle: '안전하고 간편하게 계정을 연결하고\n시장여지도의 모든 기능을 이용하세요.',
            content: _buildSocialContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionArea(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                    onPressed: _previousPage,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SDSStepBar(totalSteps: _totalSteps, currentStep: _currentStep),
          ],
        ),
      ),
    );
  }

  // Unified Step Structure
  Widget _buildStep({
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: _headerTopPadding),
          Text(
            title,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: SDS.fwBlack,
              color: AppColors.textPrimary,
              height: 1.25,
              letterSpacing: -1.8,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              height: 1.6,
              fontWeight: SDS.fwMedium,
              letterSpacing: -0.4,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Hero(
      tag: 'market_hero',
      child: Image.asset(
        'assets/images/market_hero.png',
        width: 340,
        height: 340,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildRoleContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _V15RoleCard(
          title: '일반 사용자예요',
          description: '시장의 맛집과 정보를 찾고 싶어요',
          icon: Icons.person_search_rounded,
          isSelected: _selectedRole == UserRole.customer,
          fixedHeight: _cardHeight,
          onTap: () => setState(() => _selectedRole = UserRole.customer),
        ),
        const SizedBox(height: 16),
        _V15RoleCard(
          title: '시장 상인이에요',
          description: '내 매장을 관리하고 상품을 등록할래요',
          icon: Icons.storefront_rounded,
          isSelected: _selectedRole == UserRole.merchant,
          fixedHeight: _cardHeight,
          onTap: () => setState(() => _selectedRole = UserRole.merchant),
        ),
      ],
    );
  }

  Widget _buildSocialContent() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(44),
      ),
      child: const Icon(
        Icons.lock_person_rounded,
        size: 80,
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildBottomActionArea() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_horizontalPadding, 16, _horizontalPadding, bottomPadding + 16),
      child: _currentStep == 2 
          ? _buildSocialButtons() 
          : _buildPrimaryButton(),
    );
  }

  Widget _buildPrimaryButton() {
    return ShrinkableButton(
      onTap: _nextPage,
      child: Container(
        height: _buttonHeight,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _currentStep == 0 ? '시작하기' : '다음으로',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: SDS.fwBlack,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSocialButton(
          label: '카카오 로그인',
          color: const Color(0xFFFEE500),
          textColor: const Color(0xFF3C1E1E),
          logo: const SDSKakaoLogo(size: 28),
          onTap: _handleFinalLogin,
          customRadius: 24,
          customHeight: 58,
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          label: '구글로 로그인',
          color: Colors.white,
          textColor: const Color(0xFF1F1F1F),
          logo: const SDSGoogleLogo(size: 28),
          hasBorder: true,
          customBorderColor: const Color(0xFFDBE0E5),
          customRadius: 24,
          customHeight: 58,
          onTap: _handleFinalLogin,
        ),
      ],
    );
  }

  void _handleFinalLogin() {
    context.read<AuthProvider>().login('user@example.com', '', _selectedRole);
  }

  Widget _buildSocialButton({
    required String label,
    required Color color,
    required Color textColor,
    required Widget logo,
    required VoidCallback onTap,
    bool hasBorder = false,
    Color? customBorderColor,
    double? customRadius,
    double? customHeight,
  }) {
    return ShrinkableButton(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: customHeight ?? _buttonHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(customRadius ?? 22),
          border: hasBorder ? Border.all(color: customBorderColor ?? const Color(0xFFE2E8F0), width: 1.2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logo,
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18.5,
                fontWeight: SDS.fwBlack,
                color: textColor,
                letterSpacing: -0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _V15RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final double fixedHeight;
  final VoidCallback onTap;

  const _V15RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.fixedHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ShrinkableButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        height: fixedHeight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: isSelected ? SDS.shadowAccent(AppColors.primary) : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: SDS.fwBlack,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      fontWeight: SDS.fwMedium,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 30),
          ],
        ),
      ),
    );
  }
}
