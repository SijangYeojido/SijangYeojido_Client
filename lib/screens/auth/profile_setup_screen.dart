import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final currentName = context.read<AuthProvider>().userName ?? '';
    _nameController = TextEditingController(
      text: _isDefaultName(currentName) ? '' : currentName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                '어떻게 불러드릴까요?',
                style: TextStyle(
                  fontSize: 30,
                  height: 1.2,
                  fontWeight: SDS.fwBlack,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '시장여지도에서 사용할 프로필 이름을 설정해 주세요.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: SDS.fwMedium,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                autofocus: true,
                maxLength: 24,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '예: 준원님',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  auth.errorMessage!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: SDS.fwBold,
                  ),
                ),
              ],
              const Spacer(flex: 2),
              ShrinkableButton(
                onTap: auth.isLoading ? () {} : _submit,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      auth.isLoading ? '저장 중...' : '시작하기',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: SDS.fwBlack,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final success = await context.read<AuthProvider>().completeProfile(
      name: _nameController.text,
    );
    if (!mounted || success) return;
    FocusScope.of(context).requestFocus(FocusNode());
  }

  bool _isDefaultName(String name) {
    return {
      '카카오 사용자',
      'Google 사용자',
      '네이버 사용자',
      '사용자',
      '시장여지도 사용자',
    }.contains(name);
  }
}
