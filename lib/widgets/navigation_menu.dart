import 'package:flutter/material.dart';
import 'package:vasvault/page/Home.dart';
import 'package:vasvault/page/Profile.dart';
import 'package:vasvault/page/Vault.dart';
import 'package:vasvault/theme/app_colors.dart';
import 'package:vasvault/page/Workspace.dart';
import 'package:vasvault/widgets/upload_bottom_sheet.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _pages = [
    const Home(),
    const Workspace(),
    const Vault(),
    const ProfilePage(),
  ];

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = index == _selectedIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? AppColors.primary
        : (isDark ? Colors.grey.shade600 : Colors.grey.shade500);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          UploadBottomSheet.show(context);
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.home, 'Home'),
            _buildNavItem(1, Icons.receipt_long, 'Workspace'),
            const SizedBox(width: 48),
            _buildNavItem(2, Icons.pie_chart, 'Vault'),
            _buildNavItem(3, Icons.settings, 'Setting'),
          ],
        ),
      ),
    );
  }
}
