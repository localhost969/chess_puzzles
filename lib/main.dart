import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'screens/puzzle_list_screen.dart';
import 'services/puzzle_repository.dart';
import 'services/progress_service.dart';

void main() {
  // Ensure the binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Global uncaught Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // You can log the error to a service here if desired
  };

  // Catch any errors outside the Flutter framework
  runZonedGuarded(() {
    runApp(const ChessPuzzlesApp());
  }, (error, stack) {
    // Log error and stack. Avoid throwing to keep starters alive.
    if (kDebugMode) {
      print('Unhandled zone error: $error');
      print(stack);
    }
  });
}

class ChessPuzzlesApp extends StatelessWidget {
  const ChessPuzzlesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Chess Puzzles',
      theme: ThemeData(
        colorScheme: colorScheme,
        // Base font (Poppins) and Orbitron for display titles
        fontFamily: 'Poppins',
        fontFamilyFallback: ['Roboto', 'Helvetica', 'Arial'],
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          toolbarTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      home: PuzzleListScreen(
        repository: PuzzleRepository(),
        progressService: ProgressService(),
      ),
    );
  }
}
