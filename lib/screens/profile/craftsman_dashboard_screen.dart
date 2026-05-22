import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class CraftsmanDashboardScreen extends StatefulWidget {
  const CraftsmanDashboardScreen({super.key});

  @override
  State<CraftsmanDashboardScreen> createState() => _CraftsmanDashboardScreenState();
}

class _CraftsmanDashboardScreenState extends State<CraftsmanDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getCraftsmanDashboard();
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
        title: const Text('لوحة تحكم الحرفي'),
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
                    _buildProfileCard(),
                    const SizedBox(height: 16),
                    _buildStats(),
                    const SizedBox(height: 20),
                    _buildLatestReviews(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    final c = _data?['craftsman'] ?? {};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            backgroundImage: c['avatar'] != null ? NetworkImage(c['avatar']) : null,
            child: c['avatar'] == null ? Text(
              (c['name'] ?? 'C').substring(0, 1),
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
            ) : null,
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c['name'] ?? '', style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              Text(c['profession'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Cairo')),
              if (c['city'] != null)
                Row(children: [
                  const Icon(Icons.location_on, color: Colors.white54, size: 12),
                  const SizedBox(width: 4),
                  Text(c['city'], style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Cairo')),
                ]),
            ],
          )),
          IconButton(
            onPressed: () => context.push('/craftsman/settings'),
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
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
        _StatCard(icon: Icons.reviews_outlined, label: 'إجمالي التقييمات',
            value: '${s['total_reviews'] ?? 0}', color: AppColors.primary),
        const SizedBox(width: 12),
        _StatCard(icon: Icons.pending_outlined, label: 'قيد الانتظار',
            value: '${s['pending_reviews'] ?? 0}', color: AppColors.warning),
      ],
    );
  }

  Widget _buildLatestReviews() {
    final reviews = (_data?['latest_reviews'] as List?) ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('أحدث التقييمات', style: Theme.of(context).textTheme.headlineMedium),
            TextButton(
              onPressed: () => context.push('/craftsman/reviews'),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (reviews.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(children: [
              const Icon(Icons.reviews_outlined, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('لا توجد تقييمات بعد', style: Theme.of(context).textTheme.bodyMedium),
            ]),
          ))
        else
          ...reviews.map((r) => _DashReviewItem(review: r, onReply: _load)),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _DashReviewItem extends StatelessWidget {
  final Map<String, dynamic> review;
  final VoidCallback onReply;
  const _DashReviewItem({required this.review, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text((review['reviewer']?['name'] ?? 'U').substring(0, 1),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(review['reviewer']?['name'] ?? 'مجهول',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          RatingBarIndicator(
            rating: (review['stars'] ?? 0).toDouble(),
            itemSize: 12,
            itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starColor),
          ),
        ]),
        const SizedBox(height: 8),
        Text(review['body'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        if (review['reply'] == null)
          TextButton.icon(
            onPressed: () => _showReplyDialog(context, review['id']),
            icon: const Icon(Icons.reply, size: 16),
            label: const Text('ردّ على التقييم', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('ردّك: ${review['reply']['body']}',
                style: const TextStyle(fontSize: 12, color: AppColors.primaryDark)),
          ),
      ]),
    );
  }

  void _showReplyDialog(BuildContext context, int reviewId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ردّ على التقييم'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'اكتب ردّك هنا...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              await ApiService.replyCraftsmanReview(reviewId, ctrl.text);
              if (!context.mounted) return;
              Navigator.pop(context);
              onReply();
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}
