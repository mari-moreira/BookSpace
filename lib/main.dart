import 'dart:ui';

import 'package:book_space/core/app_colors.dart';
import 'package:book_space/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const BookSpaceApp());

class BookSpaceApp extends StatelessWidget {
  const BookSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSpace',
      debugShowCheckedModeBanner: false,
      // Permite rolar arrastando com o mouse (no Chrome) além do toque
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.primary,
        // Fonte Poppins em todo o app
        textTheme: applyPoppins(
          ThemeData(brightness: Brightness.light, useMaterial3: true).textTheme,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// Aplica a fonte Poppins em cada estilo de texto do tema.
/// Feito "na mão" porque GoogleFonts.poppinsTextTheme() gera conflito de tipos
/// (TextTheme) nesta versão do Flutter.
TextTheme applyPoppins(TextTheme base) {
  TextStyle? poppins(TextStyle? style) =>
      style == null ? null : GoogleFonts.poppins(textStyle: style);

  return base.copyWith(
    displayLarge: poppins(base.displayLarge),
    displayMedium: poppins(base.displayMedium),
    displaySmall: poppins(base.displaySmall),
    headlineLarge: poppins(base.headlineLarge),
    headlineMedium: poppins(base.headlineMedium),
    headlineSmall: poppins(base.headlineSmall),
    titleLarge: poppins(base.titleLarge),
    titleMedium: poppins(base.titleMedium),
    titleSmall: poppins(base.titleSmall),
    bodyLarge: poppins(base.bodyLarge),
    bodyMedium: poppins(base.bodyMedium),
    bodySmall: poppins(base.bodySmall),
    labelLarge: poppins(base.labelLarge),
    labelMedium: poppins(base.labelMedium),
    labelSmall: poppins(base.labelSmall),
  );
}
