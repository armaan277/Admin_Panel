import 'package:flutter/material.dart';
import 'package:new_admin_panel/providers/products_provider.dart';
import 'package:new_admin_panel/side_bar.dart';
import 'package:provider/provider.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ProductsProvider>();

    return MaterialApp(
      home: const SideBar(),
      theme: themeProvider.isDarkMode
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black, // Dark background
              colorScheme: ColorScheme.dark(
                primary: Color(0xffdb3022), // Keep red accent
                surface: Colors.grey[850]!, // Card backgrounds
              ),

              // appBarTheme: const AppBarTheme(
              //   backgroundColor: Color(0xffdb3022),
              //   titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
              // ),
              cardColor: Colors.grey[850], // Cards in dark mode
              textTheme: const TextTheme(
                titleLarge: TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.white),
                titleSmall: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(const Size(0, 44)),
                     
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[900]),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                fillColor: Colors.grey[800], // Dark input fields
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintStyle: TextStyle(color: Colors.white70),
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: Colors.grey.shade100, // Light background
              colorScheme: const ColorScheme.light(
                primary: Color(0xffdb3022), // Red accent
                surface: Colors.white, // Card backgrounds
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xffdb3022),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
              ),
              cardColor: Colors.white, // Cards in light mode
              textTheme: const TextTheme(
                titleLarge: TextStyle(color: Colors.black87),
                titleMedium: TextStyle(color: Colors.black87),
                titleSmall: TextStyle(color: Colors.black87),
                bodyMedium: TextStyle(color: Colors.black54),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xffdb3022)),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                fillColor: Colors.white, // Light input fields
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                hintStyle: TextStyle(color: Colors.black45),
              ),
            ),
      debugShowCheckedModeBanner: false,
    );
  }
}
