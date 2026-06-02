import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ShrinkableButton(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: const Text(
          '개인정보 관리',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: SDS.fwBlack,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _InfoCard(
            title: '계정 정보',
            children: [
              _InfoRow(label: '이름', value: auth.userName ?? '-'),
              _InfoRow(label: '역할', value: _roleLabel(auth.role)),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: '개인정보 처리',
            children: const [
              _InfoRow(
                label: '수집 항목',
                value: '이메일, 닉네임, 예약/리뷰 기록',
              ),
              _InfoRow(
                label: '이용 목적',
                value: '서비스 제공, 예약/알림, 고객 지원',
              ),
              _InfoRow(
                label: '보관 기간',
                value: '회원 탈퇴 시까지',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: '데이터 관리',
            children: [
              ShrinkableButton(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('데이터 내보내기 요청이 접수되었습니다.'),
                    ),
                  );
                },
                child: const _ActionRow(
                  icon: Icons.download_rounded,
                  label: '내 데이터 내보내기 요청',
                ),
              ),
              ShrinkableButton(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('로그아웃'),
                      content: const Text('현재 기기에서 로그아웃할까요?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('로그아웃'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const _ActionRow(
                  icon: Icons.logout_rounded,
                  label: '로그아웃',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole role) {
    return switch (role) {
      UserRole.customer => '일반 사용자',
      UserRole.merchant => '시장 상인',
      UserRole.admin => '운영자',
    };
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: SDS.fwBlack,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: SDS.fwBold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: SDS.fwMedium,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: SDS.fwBold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
