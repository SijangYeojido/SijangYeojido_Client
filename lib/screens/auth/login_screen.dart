import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegisterMode = false;
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 36),
                _buildModeSwitch(),
                const SizedBox(height: 24),
                if (_isRegisterMode) ...[
                  _buildInput(
                    controller: _nameController,
                    label: '이름',
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if ((value ?? '').trim().length < 2) {
                        return '이름은 2자 이상 입력해 주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                ],
                _buildInput(
                  controller: _emailController,
                  label: '이메일',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final email = (value ?? '').trim();
                    if (!email.contains('@') || !email.contains('.')) {
                      return '올바른 이메일을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildInput(
                  controller: _passwordController,
                  label: '비밀번호',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if ((value ?? '').length < 8) {
                      return '비밀번호는 8자 이상 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                if (_isRegisterMode) ...[
                  const SizedBox(height: 22),
                  _buildRoleSelector(),
                ],
                const SizedBox(height: 28),
                _buildSubmitButton(auth),
                if (auth.sessionRestoreMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoBanner(auth.sessionRestoreMessage!),
                ],
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    auth.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: SDS.fwSemiBold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: SDS.shadowAccent(AppColors.primary),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '시장여지도',
          style: TextStyle(
            fontSize: 34,
            fontWeight: SDS.fwBlack,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '이메일 계정으로 로그인하고 전통시장 특가와 예약 기능을 이용하세요.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
            fontWeight: SDS.fwMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _buildModeButton('로그인', !_isRegisterMode),
          _buildModeButton('회원가입', _isRegisterMode),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool selected) {
    return Expanded(
      child: ShrinkableButton(
        onTap: () => setState(() => _isRegisterMode = label == '회원가입'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected ? SDS.shadowSoft : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: SDS.fwBlack,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: !obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        _buildRoleCard(
          label: '일반 사용자',
          icon: Icons.person_search_rounded,
          role: UserRole.customer,
        ),
        const SizedBox(width: 12),
        _buildRoleCard(
          label: '시장 상인',
          icon: Icons.storefront_rounded,
          role: UserRole.merchant,
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String label,
    required IconData icon,
    required UserRole role,
  }) {
    final selected = _selectedRole == role;
    return Expanded(
      child: ShrinkableButton(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: SDS.fwBlack,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AuthProvider auth) {
    return ShrinkableButton(
      onTap: auth.isLoading ? () {} : _submit,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: auth.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _isRegisterMode ? '회원가입' : '로그인',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: SDS.fwBlack,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFD97706),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: SDS.fwBold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearSessionRestoreMessage();
    final success = _isRegisterMode
        ? await auth.registerWithEmail(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            role: _selectedRole,
          )
        : await auth.loginWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
    if (!mounted) return;
    if (success) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? '인증에 실패했습니다.')));
  }
}
