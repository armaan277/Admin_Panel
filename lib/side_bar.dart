import 'package:flutter/material.dart';
import 'package:new_admin_panel/providers/products_provider.dart';
import 'package:new_admin_panel/screens/orders_analytics.dart';
import 'package:new_admin_panel/screens/orders_screen.dart';
import 'package:new_admin_panel/screens/reviews_screen.dart';
import 'package:new_admin_panel/theme_switch.dart';
import 'package:provider/provider.dart';
import 'screens/products_screen.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int selectedSideBar = 1;
  // bool isNightOrLightMode = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          Container(
            width: 270,
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Logo
                const Row(
                  children: [
                    SizedBox(width: 22),
                    Text(
                      'AM Admin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 0.2),
                _buildMenuItem(
                    isSelected: selectedSideBar == 1,
                    title: 'Products',
                    icon: Icons.inventory_2_outlined,
                    onTap: () {
                      selectedSideBar = 1;
                      setState(() {});
                    }),
                _buildMenuItem(
                    isSelected: selectedSideBar == 2,
                    title: 'Orders',
                    icon: Icons.shopping_cart_outlined,
                    onTap: () {
                      selectedSideBar = 2;
                      setState(() {});
                    }),
                _buildMenuItem(
                    isSelected: selectedSideBar == 3,
                    title: 'Reviews',
                    icon: Icons.reviews_outlined,
                    onTap: () {
                      selectedSideBar = 3;
                      setState(() {});
                    }),
                _buildMenuItem(
                    isSelected: selectedSideBar == 4,
                    title: 'Analytics',
                    icon: Icons.analytics_outlined,
                    onTap: () {
                      selectedSideBar = 4;
                      setState(() {});
                    }),
                const Divider(thickness: 0.2),
                _buildMenuItem(
                  isSelected: false,
                  title: context.watch<ProductsProvider>().isDarkMode
                      ? 'Dark Mode'
                      : 'Light Mode',
                  icon: context.read<ProductsProvider>().isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  onTap: () {
                    context.read<ProductsProvider>().changeTheme();
                  },
                  switchNightOrLightMode: ThemeSwitch(),
                ),
              ],
            ),
          ),
          if (selectedSideBar == 1)
            Expanded(
              child: ProductsScreen(),
            ),
          if (selectedSideBar == 2)
            Expanded(
              child: OrdersScreen(),
            ),
          if (selectedSideBar == 3)
            Expanded(
              child: GroupCardsScreen(),
            ),
          if (selectedSideBar == 4)
            Expanded(
              child: OrdersAnalytics(),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
    Widget? switchNightOrLightMode,
  }) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffdb3022).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            icon,
            color: isSelected ? const Color(0xffdb3022) : Colors.grey[600],
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xffdb3022) : Colors.grey[600],
            ),
          ),
          selected: isSelected,
          trailing: switchNightOrLightMode,
        ),
      ),
    );
  }
}
