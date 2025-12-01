import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:omidvpn/ui/home/home_screen.dart';
import 'package:omidvpn/ui/license/license_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'OmidVPN',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeMode,
      home: const LicenseWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LicenseWrapper extends ConsumerStatefulWidget {
  const LicenseWrapper({super.key});

  @override
  ConsumerState<LicenseWrapper> createState() => _LicenseWrapperState();
}

class _LicenseWrapperState extends ConsumerState<LicenseWrapper> {
  bool _licenseValidated = false;
  bool _checkingLicense = true;

  @override
  void initState() {
    super.initState();
    _checkLicense();
  }

  Future<void> _checkLicense() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLicense = prefs.getString('premium_license_key');
    final continueWithoutLicense = prefs.getBool('continue_without_license') ?? false;
    
    if (storedLicense != null && storedLicense.isNotEmpty) {
      // For now, we'll assume the stored license is valid
      // In a real app, you might want to validate it against your server
      setState(() {
        _licenseValidated = true;
        _checkingLicense = false;
      });
    } else if (continueWithoutLicense) {
      // User has chosen to continue without license
      setState(() {
        _licenseValidated = true;
        _checkingLicense = false;
      });
    } else {
      setState(() {
        _licenseValidated = false;
        _checkingLicense = false;
      });
    }
  }

  void _onLicenseValidated() {
    setState(() {
      _licenseValidated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLicense) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_licenseValidated) {
      return const HomePage();
    }

    return LicenseScreen(onLicenseValidated: _onLicenseValidated);
  }
}