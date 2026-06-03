// lib/screens/super_admin/super_admin_shell.dart
//
// Mobile-first Super Admin shell.
// Navigation pattern: BottomNavigationBar (primary) + Drawer (full menu).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shop.dart';
import '../../providers/auth_provider.dart';
import 'sa_dashboard_screen.dart';
import 'sa_all_shops_screen.dart';

class SuperAdminShell extends ConsumerStatefulWidget {
  const SuperAdminShell({super.key});

  @override
  ConsumerState<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends ConsumerState<SuperAdminShell> {
  int _navIndex = 0;

  /// Shared mutable shop list — owned here, passed down.
  late final List<Shop> _shops;

  @override
  void initState() {
    super.initState();
    _shops = List<Shop>.from(mockShops);
  }

  void _onShopChanged(Shop _) => setState(() {});

  void _onShopDeleted(Shop shop) {
    setState(() => _shops.remove(shop));
  }

  static const List<_NavItem> _navItems = [
    _NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard'),
    _NavItem(
        icon: Icons.store_outlined,
        activeIcon: Icons.store,
        label: 'All Shops'),
    _NavItem(
        icon: Icons.trending_up_outlined,
        activeIcon: Icons.trending_up,
        label: 'Revenue'),
    _NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings'),
  ];

  Widget _buildPage() {
    switch (_navIndex) {
      case 0:
        return SADashboardScreen(
          shops: _shops,
          onStatusChanged: _onShopChanged,
        );
      case 1:
        return SAAllShopsScreen(
          shops: _shops,
          onStatusChanged: _onShopChanged,
          onShopDeleted: _onShopDeleted,
        );
      case 2:
        return _PlaceholderScreen(
          icon: Icons.trending_up,
          title: 'Revenue Reports',
          subtitle: 'Platform-wide revenue analytics\ncoming soon.',
          color: Colors.purple,
        );
      case 3:
        return _PlaceholderScreen(
          icon: Icons.settings,
          title: 'Global Settings',
          subtitle: 'Platform configuration\ncoming soon.',
          color: Colors.teal,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            const Text('Are you sure you want to log out of the admin panel?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final userName = auth.user?.name ?? 'Admin';
    final userEmail = auth.user?.email ?? '';
    final initials =
        userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _buildAppBar(initials, userName),
      drawer: _buildDrawer(initials, userName, userEmail),
      body: _buildPage(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  AppBar _buildAppBar(String initials, String userName) {
    return AppBar(
      backgroundColor: const Color(0xFF1565C0),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Super Admin',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
          const Text('My Shop Platform',
              style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
      actions: [
        // Notification
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white),
              onPressed: () {},
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Navigation Drawer ──────────────────────────────────────────────────────
  Drawer _buildDrawer(
      String initials, String userName, String userEmail) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
                top: 56, bottom: 24, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(userName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(userEmail,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Super Admin',
                      style:
                          TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerTile(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  isSelected: _navIndex == 0,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _navIndex = 0);
                  },
                ),
                _DrawerTile(
                  icon: Icons.store_outlined,
                  label: 'All Shops',
                  isSelected: _navIndex == 1,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _navIndex = 1);
                  },
                ),
                _DrawerTile(
                  icon: Icons.computer_outlined,
                  label: 'Subscriptions',
                  isSelected: false,
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerTile(
                  icon: Icons.trending_up_outlined,
                  label: 'Revenue Reports',
                  isSelected: _navIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _navIndex = 2);
                  },
                ),
                _DrawerTile(
                  icon: Icons.settings_outlined,
                  label: 'Global Settings',
                  isSelected: _navIndex == 3,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _navIndex = 3);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          _DrawerTile(
            icon: Icons.logout,
            label: 'Logout',
            isSelected: false,
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
  NavigationBar _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _navIndex,
      onDestinationSelected: (i) => setState(() => _navIndex = i),
      backgroundColor: Colors.white,
      elevation: 8,
      indicatorColor: const Color(0xFF1565C0).withValues(alpha: 0.12),
      destinations: _navItems
          .map((item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon:
                    Icon(item.activeIcon, color: const Color(0xFF1565C0)),
                label: item.label,
              ))
          .toList(),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label});
}

// ─── Drawer Tile ──────────────────────────────────────────────────────────────

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Colors.red
        : isSelected
            ? const Color(0xFF1565C0)
            : Colors.grey[700]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1565C0).withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 22),
        title: Text(label,
            style: TextStyle(
                color: color,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14.5)),
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─── Placeholder Screen ───────────────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _PlaceholderScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 52, color: color),
          ),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
