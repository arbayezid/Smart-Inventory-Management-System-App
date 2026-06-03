// lib/screens/super_admin/widgets/shop_list_tile.dart
//
// Reusable mobile-friendly shop card used in both Dashboard and All Shops.

import 'package:flutter/material.dart';
import '../../../models/shop.dart';

class ShopListTile extends StatelessWidget {
  final Shop shop;
  final ValueChanged<Shop> onStatusChanged;

  /// Null means this tile is in "read-only recent" mode (no delete action).
  final ValueChanged<Shop>? onDeleted;

  const ShopListTile({
    super.key,
    required this.shop,
    required this.onStatusChanged,
    required this.onDeleted,
  });

  // ── Status badge helper ───────────────────────────────────────────────────

  static (Color bg, Color text, String label, IconData icon) _statusStyle(
      ShopStatus s) {
    return switch (s) {
      ShopStatus.active => (
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
          'Active',
          Icons.check_circle_rounded
        ),
      ShopStatus.pending => (
          const Color(0xFFFFF8E1),
          const Color(0xFFE65100),
          'Pending',
          Icons.pending_rounded
        ),
      ShopStatus.rejected => (
          const Color(0xFFFFEBEE),
          const Color(0xFFC62828),
          'Restricted',
          Icons.block_rounded
        ),
    };
  }

  // ── Avatar colour by first letter ────────────────────────────────────────

  static Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF6A1B9A),
      const Color(0xFF00695C),
      const Color(0xFFE65100),
      const Color(0xFF283593),
      const Color(0xFF880E4F),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label, icon) = _statusStyle(shop.status);
    final avatarBg = _avatarColor(shop.name);
    final initial =
        shop.name.trim().isNotEmpty ? shop.name.trim()[0].toUpperCase() : '?';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────────────────
            CircleAvatar(
              radius: 22,
              backgroundColor: avatarBg,
              child: Text(initial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            const SizedBox(width: 12),

            // ── Shop info ────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 2),
                  Text(shop.ownerEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.5, color: Colors.grey[500])),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 11, color: fg),
                            const SizedBox(width: 3),
                            Text(label,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: fg,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Plan chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(shop.plan,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600])),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Action menu ──────────────────────────────────────────────
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[500]),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              itemBuilder: (_) => [
                if (shop.status != ShopStatus.active)
                  _menuItem('approve', Icons.check_circle_outline,
                      const Color(0xFF2E7D32), 'Approve', Colors.black87),
                if (shop.status != ShopStatus.rejected)
                  _menuItem('restrict', Icons.block_rounded, Colors.red,
                      'Restrict', Colors.red),
                if (onDeleted != null) ...[
                  const PopupMenuDivider(),
                  _menuItem('delete', Icons.delete_outline, Colors.red,
                      'Delete', Colors.red),
                ],
              ],
              onSelected: (value) => _onAction(value, context),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      String value, IconData icon, Color iconColor, String label,
      Color textColor) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: textColor)),
      ]),
    );
  }

  void _onAction(String value, BuildContext context) {
    switch (value) {
      case 'approve':
        shop.status = ShopStatus.active;
        onStatusChanged(shop);
      case 'restrict':
        shop.status = ShopStatus.rejected;
        onStatusChanged(shop);
      case 'delete':
        onDeleted?.call(shop);
    }
  }
}
