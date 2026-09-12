import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/prayer_store.dart';
import 'screens/category_manage_screen.dart';
import 'screens/date_view_screen.dart';
import 'screens/item_list_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  runApp(const PrayerTreeApp());
}

class PrayerTreeApp extends StatelessWidget {
  const PrayerTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '기도 나무',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final PrayerStore _store = PrayerStore();
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        if (!_store.loaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final screens = [
          ItemListScreen(store: _store),
          DateViewScreen(store: _store),
          CategoryManageScreen(store: _store),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('🌳 기도 나무'),
          ),
          body: IndexedStack(index: _tabIndex, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tabIndex,
            onDestinationSelected: (i) => setState(() => _tabIndex = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.list_alt), label: '목록'),
              NavigationDestination(icon: Icon(Icons.calendar_month), label: '날짜별'),
              NavigationDestination(icon: Icon(Icons.category), label: '카테고리'),
            ],
          ),
        );
      },
    );
  }
}
