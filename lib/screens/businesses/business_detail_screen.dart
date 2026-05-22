import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class BusinessDetailScreen extends StatefulWidget {
  final String domain;
  const BusinessDetailScreen({super.key, required this.domain});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  Map<String, dynamic>? _business;
  List _reviews = [];
  bool _loading = true;
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.getBusiness(widget.domain);
      setState(() { _business = res['data']; _loading = false; });
      _loadReviews();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final res = await ApiService.getBusinessReviews(widget.domain);
      setState(() { _reviews = res['data']; _loadingReviews = false; });
    } catch (_) {
      setState(() => _loadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    final b = _business!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: b['logo'] ?? '',
                          width: 80, height: 80, fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 80, height: 80,
                            color: Colors.white24,
                            child: const Icon(Icons.business, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(b['name'] ?? '', style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Row
                  Row(children: [
                    RatingBarIndicator(
                      rating: (b['avg_ratings'] ?? 0.0).toDouble(),
                      itemSize: 20,
                      itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starColor),
                    ),
                    const SizedBox(width: 8),
                    Text('${b['avg_ratings']} (${b['total_reviews']} تقييم)',
                        style: const TextStyle(color: AppColors.textSecondary)),
                    const Spacer(),
                    if (b['is_verified'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(children: [
                          Icon(Icons.verified, color: AppColors.success, size: 14),
                          SizedBox(width: 4),
                          Text('موثّق', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                  ]),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final token = await ApiService.getToken();
                          if (!context.mounted) return;
                          if (token == null) {
                            context.push('/auth/select');
                          } else {
                            _showReviewDialog(context);
                          }
                        },
                        icon: const Icon(Icons.star_outline, size: 18),
                        label: const Text('اكتب تقييم'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (b['website'] != null)
                      OutlinedButton(
                        onPressed: () => launchUrl(Uri.parse(b['website'])),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(44, 44), padding: EdgeInsets.zero),
                        child: const Icon(Icons.language_outlined),
                      ),
                  ]),
                  const SizedBox(height: 20),

                  // Details
                  if (b['short_description'] != null) ...[
                    Text('عن النشاط', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(b['short_description'], style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                  ],

                  // Contact Info
                  if (b['city'] != null || b['country'] != null) ...[
                    _InfoTile(icon: Icons.location_on_outlined, label: 'الموقع',
                        value: [b['city'], b['country']].where((e) => e != null).join('، ')),
                    const SizedBox(height: 8),
                  ],

                  // Category
                  if (b['category'] != null) ...[
                    _InfoTile(icon: Icons.category_outlined, label: 'الفئة', value: b['category']['name'] ?? ''),
                    const SizedBox(height: 20),
                  ],

                  // Reviews
                  Text('التقييمات', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),

                  if (_loadingReviews)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  else if (_reviews.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(children: [
                        const Icon(Icons.reviews_outlined, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text('لا توجد تقييمات بعد', style: Theme.of(context).textTheme.bodyMedium),
                      ]),
                    ))
                  else
                    ..._reviews.map((r) => _ReviewItem(review: r)),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ReviewBottomSheet(domain: widget.domain, onSubmit: _loadReviews),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      Expanded(child: Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14))),
    ]);
  }
}

class _ReviewItem extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewItem({required this.review});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: review['reviewer']?['avatar'] != null
                  ? NetworkImage(review['reviewer']['avatar']) : null,
              child: review['reviewer']?['avatar'] == null
                  ? Text((review['reviewer']?['name'] ?? 'U').substring(0, 1),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)) : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review['reviewer']?['name'] ?? 'مجهول',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(review['created_at'] ?? '',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            )),
            RatingBarIndicator(
              rating: (review['stars'] ?? 0).toDouble(),
              itemSize: 14,
              itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starColor),
            ),
          ]),
          if (review['title'] != null) ...[
            const SizedBox(height: 8),
            Text(review['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
          const SizedBox(height: 6),
          Text(review['body'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          if (review['reply'] != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('رد صاحب العمل', style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: 4),
                Text(review['reply']['body'], style: const TextStyle(fontSize: 13)),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewBottomSheet extends StatefulWidget {
  final String domain;
  final VoidCallback onSubmit;
  const _ReviewBottomSheet({required this.domain, required this.onSubmit});

  @override
  State<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  final _bodyCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  double _stars = 5;
  bool _loading = false;

  Future<void> _submit() async {
    if (_bodyCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ApiService.submitCraftsmanReview(
          widget.domain, _stars.toInt(), _bodyCtrl.text,
          title: _titleCtrl.text.isNotEmpty ? _titleCtrl.text : null);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSubmit();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم إرسال تقييمك بنجاح!'),
        backgroundColor: AppColors.success,
      ));
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('اكتب تقييم', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          Center(child: RatingBar.builder(
            initialRating: _stars,
            minRating: 1,
            itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starColor),
            onRatingUpdate: (r) => setState(() => _stars = r),
          )),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'عنوان التقييم (اختياري)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'اكتب تقييمك...', alignLabelWithHint: true),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('إرسال التقييم'),
          ),
        ]),
      ),
    );
  }
}
