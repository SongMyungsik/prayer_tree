import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../data/prayer_store.dart';
import '../widgets/app_preferences_view.dart';
import '../widgets/usage_guide_view.dart';
import 'category_manage_screen.dart';

class SettingsScreen extends StatefulWidget {
  final PrayerStore store;
  final AppSettings settings;

  const SettingsScreen({super.key, required this.store, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey[600],
              tabs: const [
                Tab(text: '사용방법'),
                Tab(text: '카테고리 관리'),
                Tab(text: '설정'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const UsageGuideView(),
                  CategoryManageScreen(store: widget.store),
                  AppPreferencesView(settings: widget.settings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
