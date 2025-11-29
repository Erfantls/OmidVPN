import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:omidvpn/ui/home/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: Omid()));
}

class Omid extends ConsumerWidget {
  const Omid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: lang.homeTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: const HomePage(),
    );
  }
}