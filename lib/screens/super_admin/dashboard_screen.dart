// lib/screens/super_admin/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../models/shop.dart';
import 'widgets/kpi_card.dart';
import 'widgets/status_badge.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  final List<Shop> shops;
  final ValueChanged<Shop> onStatusChanged;

  const SuperAdminDashboardScreen({
    super.key,
    required this.shops,
    required this.onStatusChanged,
  });

  // Show only the 6 most recent shops
  List<Shop> get _recentShops => shops.take(6).toList();

  int get _activeCount =>
      shops.where((s) => s.status == ShopStatus.active).length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          const Text(
            'Platform Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),

          // KPI Cards Grid
          _KpiGrid(
            totalShops: shops.length,
            activeSubscriptions: _activeCount,
          ),
          const SizedBox(height: 28),

          // Recent Onboarded Shops Card
          _RecentShopsCard(
            shops: _recentShops,
            onStatusChanged: onStatusChanged,
          ),
        ],
      ),
    );
  }
}

// ─── KPI Grid ────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final int totalShops;
  final int activeSubscriptions;

  const _KpiGrid({
    required this.totalShops,
    required this.activeSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossCount,
          childAspectRatio: 2.8,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          children: [
            KpiCard(
              title: 'Total Shops Registered',
              value: '$totalShops',
              icon: Icons.store_outlined,
              iconBg: const Color(0xFFDEEFFD),
              iconColor: const Color(0xFF1E88E5),
            ),
            KpiCard(
              title: 'Active Subscriptions',
              value: '$activeSubscriptions',
              icon: Icons.check_circle_outline,
              iconBg: const Color(0xFFD6F5E3),
              iconColor: const Color(0xFF27AE60),
            ),
            KpiCard(
              title: 'Monthly Recurring Revenue (MRR)',
              value: '\$60',
              icon: Icons.account_balance_wallet_outlined,
              iconBg: const Color(0xFFEDE7F6),
              iconColor: const Color(0xFF7B1FA2),
            ),
            KpiCard(
              title: 'New Shops (This Month)',
              value: '+2',
              icon: Icons.person_add_outlined,
              iconBg: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFE65100),
            ),
          ],
        );
      },
    );
  }
}

// ─── Recent Shops Card ────────────────────────────────────────────────────────

class _RecentShopsCard extends StatelessWidget {
  final List<Shop> shops;
  final ValueChanged<Shop> onStatusChanged;

  const _RecentShopsCard({
    required this.shops,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Onboarded Shops',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  onPressed: () {},
                  child: const Text('View All',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Table
            _ShopsTable(shops: shops, onStatusChanged: onStatusChanged),
          ],
        ),
      ),
    );
  }
}

// ─── Shops Table ─────────────────────────────────────────────────────────────

class _ShopsTable extends StatelessWidget {
  final List<Shop> shops;
  final ValueChanged<Shop> onStatusChanged;

  const _ShopsTable({required this.shops, required this.onStatusChanged});

  static const _headerStyle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: Color(0xFF8A8A9A),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 52,
        columnSpacing: 24,
        dividerThickness: 1,
        columns: const [
          DataColumn(label: Text('Shop Name', style: _headerStyle)),
          DataColumn(label: Text('Owner Email', style: _headerStyle)),
          DataColumn(label: Text('Plan', style: _headerStyle)),
          DataColumn(label: Text('Status', style: _headerStyle)),
          DataColumn(label: Text('Joined Date', style: _headerStyle)),
          DataColumn(label: Text('Action', style: _headerStyle)),
        ],
        rows: shops.map((shop) => _buildRow(shop)).toList(),
      ),
    );
  }

  DataRow _buildRow(Shop shop) {
    return DataRow(cells: [
      DataCell(Text(shop.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
      DataCell(Text(shop.ownerEmail,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
      DataCell(Text(shop.plan,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
      DataCell(StatusBadge(status: shop.status)),
      DataCell(Text(shop.joinedDate,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
      DataCell(_ActionMenu(shop: shop, onStatusChanged: onStatusChanged)),
    ]);
  }
}

// ─── Action Popup Menu ────────────────────────────────────────────────────────

class _ActionMenu extends StatelessWidget {
  final Shop shop;
  final ValueChanged<Shop> onStatusChanged;

  const _ActionMenu({required this.shop, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'approve',
          child: Row(children: [
            Icon(Icons.check_circle_outline,
                color: Color(0xFF27AE60), size: 18),
            SizedBox(width: 10),
            Text('Approve'),
          ]),
        ),
        const PopupMenuItem(
          value: 'restrict',
          child: Row(children: [
            Icon(Icons.block, color: Colors.red, size: 18),
            SizedBox(width: 10),
            Text('Restrict'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 18),
            SizedBox(width: 10),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'approve':
            shop.status = ShopStatus.active;
            break;
          case 'restrict':
            shop.status = ShopStatus.rejected;
            break;
          case 'delete':
            shop.status = ShopStatus.rejected;
            break;
        }
        onStatusChanged(shop);
      },
    );
  }
}
