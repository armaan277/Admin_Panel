import 'package:flutter/material.dart';
import 'package:new_admin_panel/providers/products_provider.dart';
import 'package:new_admin_panel/screens/dashboard_login_screen.dart';
import 'package:provider/provider.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ProductsProvider>();

    return MaterialApp(
      home: const DashboardLoginScreen(),
      theme: themeProvider.isDarkMode
          ? ThemeData.dark().copyWith(
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: Colors.white, // Light mode: Red color
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.black
                      : Colors.white,
                ),
                trackColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.grey[800]!,
                ),
              ),
              scaffoldBackgroundColor: Colors.black, // Dark background
              colorScheme: ColorScheme.dark(
                primary: const Color(0xffffffff), // Keep red accent
                surface: Colors.grey[850]!, // Card backgrounds
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                titleTextStyle:
                    const TextStyle(color: Colors.white, fontSize: 20),
              ),
              cardColor: Colors.grey[850], // Cards in dark mode
              textTheme: const TextTheme(
                titleLarge: TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.white),
                titleSmall: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Colors.grey[850]), // Dark background
                  foregroundColor:
                      const WidgetStatePropertyAll(Colors.white), // White text
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color(0xffffffff)
                            .withOpacity(0.2); // Click effect
                      }
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.white.withOpacity(0.2); // Hover effect
                      }
                      return null; // Default color
                    },
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                fillColor: Colors.grey[800], // Dark input fields
                filled: true,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintStyle: const TextStyle(color: Colors.white70),
              ),
              bottomSheetTheme: BottomSheetThemeData(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  side: BorderSide(
                    color: Colors.grey.shade300, // Light mode border color
                    width: 1,
                  ),
                ),
              ),
              snackBarTheme: const SnackBarThemeData(
                backgroundColor: Colors.black,
                contentTextStyle: TextStyle(color: Colors.white),
              ),
            )
          : ThemeData.light().copyWith(
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: Color(0xffdb3022), // Light mode: Red color
              ),
              switchTheme: SwitchThemeData(
                trackOutlineColor: const WidgetStatePropertyAll(
                  Color(0xffdb3022),
                ),
                trackColor: const WidgetStatePropertyAll(Colors.white),
                thumbColor: const WidgetStatePropertyAll(
                  Color(0xffdb3022),
                ),
              ),
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
              elevatedButtonTheme: const ElevatedButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xffdb3022)),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                fillColor: Colors.white, // Light input fields
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                hintStyle: TextStyle(color: Colors.black45),
              ),
              bottomSheetTheme: BottomSheetThemeData(
                backgroundColor: const Color(0xffdb3022),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  side: BorderSide(
                    color: Colors.grey.shade300, // Light mode border color
                    width: 1,
                  ),
                ),
              ),
              snackBarTheme: const SnackBarThemeData(
                backgroundColor: Color(0xffdb3022),
                contentTextStyle: TextStyle(color: Colors.white),
              ),
            ),
      debugShowCheckedModeBanner: false,
    );
  }
}
