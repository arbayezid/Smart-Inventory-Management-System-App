// lib/screens/super_admin/widgets/admin_sidebar.dart

import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final String userEmail;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
    this.userEmail = '',
  });

  static const List<_SidebarItem> _topItems = [
    _SidebarItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _SidebarItem(icon: Icons.store_outlined, label: 'All Shops'),
    _SidebarItem(icon: Icons.computer_outlined, label: 'Subscriptions'),
    _SidebarItem(icon: Icons.trending_up, label: 'Revenue Reports'),
    _SidebarItem(icon: Icons.settings_outlined, label: 'Global Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[50],
      child: Column(
        children: [
          // Optional: show logged-in email at top of sidebar
          if (userEmail.isNotEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(
                    bottom: BorderSide(color: Colors.blue[100]!, width: 1)),
              ),
              child: Text(
                userEmail,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Main nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: _topItems.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return _SidebarTile(
                  icon: item.icon,
                  label: item.label,
                  isSelected: selectedIndex == i,
                  onTap: () => onItemSelected(i),
                );
              }).toList(),
            ),
          ),

          // Logout pinned at bottom
          const Divider(height: 1),
          _SidebarTile(
            icon: Icons.logout,
            label: 'Logout',
            isSelected: false,
            isLogout: true,
            onTap: onLogout,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Data class ──────────────────────────────────────────────────────────────

class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});
}

// ─── Individual Tile ─────────────────────────────────────────────────────────

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isLogout;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Colors.blue[700]!;
    final Color itemColor = isLogout
        ? Colors.red[600]!
        : (isSelected ? activeColor : Colors.grey[700]!);
    final Color bgColor =
        isSelected ? Colors.blue[50]! : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: itemColor, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: itemColor,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
