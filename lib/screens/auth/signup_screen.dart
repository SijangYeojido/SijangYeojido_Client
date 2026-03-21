import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/sijang_design_system.dart';
import '../../theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: SDS.fwBlack,
                  color: AppColors.textPrimary,
                  letterSpacing: SDS.lsTight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '시장여지도와 함께하는 스마트한 시작',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: SDS.fwMedium,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Role Selection Header
              Text(
                '회원 유형을 선택해주세요',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: SDS.fwSemiBold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildRoleCard(
                    '일반 사용자',
                    '시장을 즐겨보세요',
                    Icons.person_rounded,
                    UserRole.customer,
                  ),
                  const SizedBox(width: 12),
                  _buildRoleCard(
                    '매장 사장님',
                    '매장을 관리하세요',
                    Icons.store_rounded,
                    UserRole.merchant,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Inputs
              _buildInput(
                controller: _nameController,
                hint: '이름',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _emailController,
                hint: '이메일 주소',
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _passwordController,
                hint: '비밀번호',
                icon: Icons.lock_open_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 48),

              // Signup Button
              SDS.button(
                label: '가입완료',
                onTap: () {
                  context.read<AuthProvider>().signup(
                    _emailController.text,
                    _passwordController.text,
                    _nameController.text,
                    _selectedRole,
                  );
                  Navigator.pop(context);
                },
                color: AppColors.primary,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String title, String subtitle, IconData icon, UserRole role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(SDS.radiusM),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isSelected ? SDS.shadowSoft : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                size: 28,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: SDS.fwBold,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: SDS.fwMedium,
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.7) : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(SDS.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textTertiary),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}
