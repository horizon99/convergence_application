import 'package:convergence_application/screens/database_open_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
   // Initialisation obligatoire pour Desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const ConvergenceApp());
}

class ConvergenceApp extends StatelessWidget {
  const ConvergenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convergence',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'CH'),
        Locale('fr'),
        Locale('en'),
      ],
      locale: const Locale('fr', 'CH'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DatabaseOpenScreen(),
    );
  }
}
