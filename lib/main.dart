import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/app_settings.dart';
import 'data/prayer_store.dart';
import 'screens/date_view_screen.dart';
import 'screens/item_list_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stats_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  runApp(const PrayerTreeApp());
}

class PrayerTreeApp extends StatefulWidget {
  const PrayerTreeApp({super.key});

  @override
  State<PrayerTreeApp> createState() => _PrayerTreeAppState();
}

class _PrayerTreeAppState extends State<PrayerTreeApp> {
  final AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _settings.load();
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settings,
      builder: (context, _) {
        return MaterialApp(
          title: '기도 나무',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(seedColor: _settings.seedColor),
          darkTheme: buildDarkTheme(seedColor: _settings.seedColor),
          themeMode: _settings.themeMode,
          locale: const Locale('ko', 'KR'),
          supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Theme(
            data: buildLightTheme(seedColor: _settings.seedColor),
            child: SplashScreen(settings: _settings),
          ),
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  final AppSettings settings;

  const HomeShell({super.key, required this.settings});

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
          SearchScreen(store: _store),
          StatsScreen(store: _store),
          SettingsScreen(store: _store, settings: widget.settings),
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
              NavigationDestination(icon: Icon(Icons.search), label: '검색'),
              NavigationDestination(icon: Icon(Icons.bar_chart), label: '통계'),
              NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
            ],
          ),
        );
      },
    );
  }
}
