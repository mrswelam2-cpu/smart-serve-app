import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/business_card.dart';
import '../../widgets/bottom_nav.dart';

class BusinessesScreen extends StatefulWidget {
  const BusinessesScreen({super.key});

  @override
  State<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends State<BusinessesScreen> {
  final _searchCtrl = TextEditingController();
  List _businesses = [];
  bool _loading = true;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
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
    if (reset) { _page = 1; _businesses = []; _hasMore = true; }
    setState(() => _loading = reset ? true : _loading);
    try {
      final res = await ApiService.getBusinesses(
        search: _searchCtrl.text.isNotEmpty ? _searchCtrl.text : null,
        page: _page,
      );
      final data = res['data'] as List;
      setState(() {
        _businesses = reset ? data : [..._businesses, ...data];
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
        title: const Text('الأعمال التجارية'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'ابحث...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        onPressed: () { _searchCtrl.clear(); _load(reset: true); },
                        icon: const Icon(Icons.clear))
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _load(reset: true),
              onChanged: (v) { if (v.isEmpty) _load(reset: true); },
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _businesses.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('لا توجد نتائج', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ))
              : ListView.separated(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: _businesses.length + (_loadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    if (i == _businesses.length) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    return BusinessCard(business: _businesses[i]);
                  },
                ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
