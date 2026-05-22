import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class SelectTypeScreen extends StatelessWidget {
  const SelectTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر نوع الحساب')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('سجّل دخولك كـ', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text('اختر نوع حسابك للمتابعة', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 40),

            _TypeCard(
              icon: Icons.person_outline,
              title: 'طالب خدمة',
              subtitle: 'ابحث وقيّم الشركات والحرفيين',
              color: const Color(0xFF6366F1),
              onTap: () => context.push('/auth/login/user'),
            ),
            const SizedBox(height: 16),

            _TypeCard(
              icon: Icons.handyman_outlined,
              title: 'حرفي',
              subtitle: 'اعرض خدماتك واستقبل تقييمات',
              color: AppColors.primary,
              onTap: () => context.push('/auth/login/craftsman'),
            ),
            const SizedBox(height: 16),

            _TypeCard(
              icon: Icons.business_outlined,
              title: 'صاحب عمل',
              subtitle: 'أدر نشاطك التجاري وردّ على التقييمات',
              color: const Color(0xFF10B981),
              onTap: () => context.push('/auth/login/business'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
