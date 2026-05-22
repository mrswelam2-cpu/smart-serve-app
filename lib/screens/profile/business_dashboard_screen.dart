import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getBusinessDashboard();
      setState(() { _data = res['data']; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم العمل'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBusinessCard(),
                    const SizedBox(height: 16),
                    _buildStats(),
                    const SizedBox(height: 20),
                    _buildMenuItems(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBusinessCard() {
    final b = _data?['business'] ?? {};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b['name'] ?? '', style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              Text(b['domain'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Cairo')),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final s = _data?['stats'] ?? {};
    return Row(
      children: [
        _StatCard(icon: Icons.star, label: 'متوسط التقييم',
            value: '${s['avg_ratings'] ?? 0}', color: AppColors.starColor),
        const SizedBox(width: 12),
        _StatCard(icon: Icons.reviews_outlined, label: 'التقييمات',
            value: '${s['total_reviews'] ?? 0}', color: AppColors.primary),
        const SizedBox(width: 12),
        _StatCard(icon: Icons.visibility_outlined, label: 'المشاهدات',
            value: '${s['total_views'] ?? 0}', color: AppColors.secondary),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _MenuItem(icon: Icons.rate_review_outlined, title: 'التقييمات',
            onTap: () => context.push('/business/reviews')),
        _MenuItem(icon: Icons.notifications_outlined, title: 'الإشعارات',
            onTap: () => context.push('/business/notifications')),
        _MenuItem(icon: Icons.people_outline, title: 'الموظفون',
            onTap: () => context.push('/business/employees')),
        _MenuItem(icon: Icons.settings_outlined, title: 'الإعدادات',
            onTap: () => context.push('/business/settings')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      tileColor: Colors.white,
    ),
  );
}
