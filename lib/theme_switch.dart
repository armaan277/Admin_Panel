import 'package:flutter/material.dart';
import 'package:new_admin_panel/providers/products_provider.dart';
import 'package:provider/provider.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProviderWatch = context.watch<ProductsProvider>();
    return Switch(
      value: themeProviderWatch.isDarkMode,
      onChanged: (_) => themeProviderWatch.changeTheme(),
    );
  }
}
