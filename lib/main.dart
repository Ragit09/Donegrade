import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/pages/home_page.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize Firebase and Local Database here
  // await Firebase.initializeApp();
  
  runApp(const DonegradeApp());
}

class DonegradeApp extends StatelessWidget {
  const DonegradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Donegrade',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: const HomePage(),
        );
      }
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E3A8A),
        brightness: brightness,
        primary: const Color(0xFF10B981),
        background: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1E3A8A)),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E3A8A),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
