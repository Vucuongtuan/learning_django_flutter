import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_flutter/theme/app_theme.dart';
import 'package:app_flutter/services/auth_service.dart';
import 'package:app_flutter/services/fcm_service.dart';
import 'package:app_flutter/screens/intro/intro_screen.dart';
import 'package:app_flutter/screens/auth/login_screen.dart';
import 'package:app_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:app_flutter/screens/room_list/room_list_screen.dart';
import 'package:app_flutter/screens/utility_entry/utility_entry_screen.dart';
import 'package:app_flutter/screens/invoice_detail/invoice_detail_screen.dart';

bool get _supportsFirebase =>
    kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_supportsFirebase) {
    await Firebase.initializeApp();
  }

  runApp(const SmartMeterApp());
}

class SmartMeterApp extends StatelessWidget {
  const SmartMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Ledger',
      theme: AppTheme.lightTheme,
      home: const SplashGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  final AuthService _authService = AuthService();

  bool? _hasSeenIntro;
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('has_seen_intro') ?? false;
    final loggedIn = await _authService.tryAutoLogin();

    setState(() {
      _hasSeenIntro = seen;
      _isLoggedIn = loggedIn;
    });

    if (loggedIn) {
      await FcmService.instance.initialize();
    }
  }

  Future<void> _completeIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_intro', true);
    setState(() => _hasSeenIntro = true);
  }

  void _onLoginSuccess() async {
    await FcmService.instance.initialize();
    setState(() => _isLoggedIn = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenIntro == null || _isLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasSeenIntro == false) {
      return IntroScreen(onComplete: _completeIntro);
    }

    if (_isLoggedIn == false) {
      return LoginScreen(onLoginSuccess: _onLoginSuccess);
    }

    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const RoomListScreen(),
    const UtilityEntryScreen(),
    const InvoiceDetailScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.bed_outlined),
            selectedIcon: Icon(Icons.bed),
            label: 'Phòng',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Chỉ số',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Hóa đơn',
          ),
        ],
      ),
    );
  }
}
