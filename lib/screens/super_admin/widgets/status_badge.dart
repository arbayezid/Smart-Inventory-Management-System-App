// lib/screens/super_admin/widgets/status_badge.dart

import 'package:flutter/material.dart';
import '../../../models/shop.dart';

class StatusBadge extends StatelessWidget {
  final ShopStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, String label) = switch (status) {
      ShopStatus.active   => (const Color(0xFF1B7E4B), 'Active'),
      ShopStatus.pending  => (const Color(0xFFD06614), 'Pending'),
      ShopStatus.rejected => (const Color(0xFFC0392B), 'Rejected'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
