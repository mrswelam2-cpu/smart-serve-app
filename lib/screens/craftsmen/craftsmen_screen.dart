import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/craftsman_card.dart';
import '../../widgets/bottom_nav.dart';

class CraftsmenScreen extends StatefulWidget {
  const CraftsmenScreen({super.key});

  @override
  State<CraftsmenScreen> createState() => _CraftsmenScreenState();
}

class _CraftsmenScreenState extends State<CraftsmenScreen> {
  final _searchCtrl = TextEditingController();
  List _craftsmen = [];
  bool _loading = true;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  String _sort = 'latest';
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        if (_hasMore && !_loadingMore) _loadMore();
      }
    });
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) { _page = 1; _craftsmen = []; _hasMore = true; }
    setState(() => _loading = reset ? true : _loading);
    try {
      final res = await ApiService.getCraftsmen(
        search: _searchCtrl.text.isNotEmpty ? _searchCtrl.text : null,
        sort: _sort == 'rating' ? 'rating' : null,
        page: _page,
      );
      final data = res['data'] as List;
      setState(() {
        _craftsmen = reset ? data : [..._craftsmen, ...data];
        _hasMore = res['meta']['current_page'] < res['meta']['last_page'];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() { _loadingMore = true; _page++; });
    await _load();
    setState(() => _loadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحرفيون'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) { _sort = v; _load(reset: true); },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'latest', child: Text('الأحدث')),
              const PopupMenuItem(value: 'rating', child: Text('الأعلى تقييماً')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ابحث عن حرفي أو مهنة...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        onPressed: () { _searchCtrl.clear(); _load(reset: true); },
                        icon: const Icon(Icons.clear))
                    : null,
              ),
              onSubmitted: (_) => _load(reset: true),
              onChanged: (v) { if (v.isEmpty) _load(reset: true); },
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _craftsmen.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.handyman_outlined, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('لا يوجد حرفيون', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ))
              : ListView.separated(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: _craftsmen.length + (_loadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    if (i == _craftsmen.length) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    return CraftsmanCard(craftsman: _craftsmen[i]);
                  },
                ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
