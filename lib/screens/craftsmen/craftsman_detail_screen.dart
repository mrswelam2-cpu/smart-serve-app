import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class CraftsmanDetailScreen extends StatefulWidget {
  final String username;
  const CraftsmanDetailScreen({super.key, required this.username});

  @override
  State<CraftsmanDetailScreen> createState() => _CraftsmanDetailScreenState();
}

class _CraftsmanDetailScreenState extends State<CraftsmanDetailScreen> {
  Map<String, dynamic>? _craftsman;
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
      final res = await ApiService.getCraftsman(widget.username);
      setState(() { _craftsman = res['data']; _loading = false; });
      _loadReviews();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final res = await ApiService.getCraftsmanReviews(widget.username);
      setState(() { _reviews = res['data']; _loadingReviews = false; });
    } catch (_) {
      setState(() => _loadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    final c = _craftsman!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white24,
                        backgroundImage: c['avatar'] != null ? NetworkImage(c['avatar']) : null,
                        child: c['avatar'] == null ? Text(
                          (c['name'] ?? 'C').substring(0, 1),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
                        ) : null,
                      ),
                      const SizedBox(height: 12),
                      Text(c['name'] ?? '', style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                      const SizedBox(height: 4),
                      Text(c['profession'] ?? '', style: const TextStyle(
                          color: Colors.white70, fontSize: 14, fontFamily: 'Cairo')),
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
                  // Rating
                  Row(children: [
                    RatingBarIndicator(
                      rating: (c['avg_ratings'] ?? 0.0).toDouble(),
                      itemSize: 20,
                      itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starColor),
                    ),
                    const SizedBox(width: 8),
                    Text('${c['avg_ratings']} (${c['total_reviews']} تقييم)',
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 16),

                  // Actions
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
                    if (c['phone'] != null) ...[
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => launchUrl(Uri.parse('tel:${c['phone']}')),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(44, 44), padding: EdgeInsets.zero),
                        child: const Icon(Icons.phone_outlined),
                      ),
                    ],
                    if (c['website'] != null) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => launchUrl(Uri.parse(c['website'])),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(44, 44), padding: EdgeInsets.zero),
                        child: const Icon(Icons.language_outlined),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 20),

                  // Info
                  if (c['short_description'] != null) ...[
                    Text('نبذة عن الحرفي', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(c['short_description'], style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                  ],

                  if (c['city'] != null) _InfoRow(icon: Icons.location_on_outlined, value: c['city']),
                  if (c['phone'] != null) _InfoRow(icon: Icons.phone_outlined, value: c['phone']),

                  // Social Links
                  if (c['social_links'] != null) ...[
                    const SizedBox(height: 16),
                    Text('السوشيال ميديا', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _SocialLinks(links: c['social_links']),
                  ],

                  const SizedBox(height: 20),

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
      builder: (_) => _ReviewSheet(username: widget.username, onSubmit: _loadReviews),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
    ]),
  );
}

class _SocialLinks extends StatelessWidget {
  final dynamic links;
  const _SocialLinks({required this.links});

  @override
  Widget build(BuildContext context) {
    if (links == null) return const SizedBox();
    final map = links is Map ? links : {};
    return Wrap(spacing: 8, children: [
      if (map['facebook'] != null)
        _SocialBtn(icon: Icons.facebook, label: 'Facebook',
            url: 'https://facebook.com/${map['facebook']}', color: const Color(0xFF1877F2)),
      if (map['instagram'] != null)
        _SocialBtn(icon: Icons.camera_alt_outlined, label: 'Instagram',
            url: 'https://instagram.com/${map['instagram']}', color: const Color(0xFFE1306C)),
      if (map['youtube'] != null)
        _SocialBtn(icon: Icons.play_circle_outline, label: 'YouTube',
            url: 'https://youtube.com/@${map['youtube']}', color: const Color(0xFFFF0000)),
    ]);
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;
  const _SocialBtn({required this.icon, required this.label, required this.url, required this.color});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => launchUrl(Uri.parse(url)),
    icon: Icon(icon, color: color, size: 18),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    ),
  );
}

class _ReviewItem extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) => Container(
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
          radius: 18,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text((review['reviewer']?['name'] ?? 'U').substring(0, 1),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(review['reviewer']?['name'] ?? 'مجهول',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(review['created_at'] ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ])),
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
            const Text('رد الحرفي', style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 4),
            Text(review['reply']['body'], style: const TextStyle(fontSize: 13)),
          ]),
        ),
      ],
    ]),
  );
}

class _ReviewSheet extends StatefulWidget {
  final String username;
  final VoidCallback onSubmit;
  const _ReviewSheet({required this.username, required this.onSubmit});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  final _bodyCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  double _stars = 5;
  bool _loading = false;

  Future<void> _submit() async {
    if (_bodyCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ApiService.submitCraftsmanReview(
          widget.username, _stars.toInt(), _bodyCtrl.text,
          title: _titleCtrl.text.isNotEmpty ? _titleCtrl.text : null);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSubmit();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم إرسال تقييمك!'), backgroundColor: AppColors.success));
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('اكتب تقييم', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        Center(child: RatingBar.builder(
          initialRating: _stars, minRating: 1,
          itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.starColor),
          onRatingUpdate: (r) => setState(() => _stars = r),
        )),
        const SizedBox(height: 16),
        TextField(controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'عنوان التقييم (اختياري)')),
        const SizedBox(height: 12),
        TextField(controller: _bodyCtrl, maxLines: 4,
            decoration: const InputDecoration(labelText: 'اكتب تقييمك...', alignLabelWithHint: true)),
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
