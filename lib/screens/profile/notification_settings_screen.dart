import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();
    final preferences = service.preferences ?? const <String, dynamic>{};
    final firebaseStatus = service.firebaseAvailable
        ? service.permissionGranted
              ? '푸시 알림 수신 중'
              : '알림 권한이 필요해요'
        : 'Firebase 설정 대기 중';

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
          '알림 설정',
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
          Text(
            firebaseStatus,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: SDS.fwBold,
            ),
          ),
          const SizedBox(height: 24),
          _NotificationSwitch(
            title: '즐겨찾기 특가 알림',
            subtitle: '관심 시장의 특가 소식을 받아요',
            value: preferences['dealAlerts'] != false,
            onChanged: (value) =>
                service.updatePreferences({'dealAlerts': value}),
          ),
          _NotificationSwitch(
            title: '예약/픽업 알림',
            subtitle: '예약 확정과 픽업 안내를 받아요',
            value: preferences['reservationAlerts'] != false,
            onChanged: (value) =>
                service.updatePreferences({'reservationAlerts': value}),
          ),
          _NotificationSwitch(
            title: '마케팅 알림',
            subtitle: '이벤트와 혜택 소식을 받아요',
            value: preferences['marketingAlerts'] == true,
            onChanged: (value) =>
                service.updatePreferences({'marketingAlerts': value}),
          ),
        ],
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: SDS.fwMedium,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
