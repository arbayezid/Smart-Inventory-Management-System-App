// lib/screens/super_admin/sa_dashboard_screen.dart
//
// Mobile-first Super Admin Dashboard screen.
// Uses Cards + 2-col grid KPIs + shop list tiles — NO DataTable.

import 'package:flutter/material.dart';
import '../../models/shop.dart';
import 'widgets/shop_list_tile.dart';

class SADashboardScreen extends StatelessWidget {
  final List<Shop> shops;
  final ValueChanged<Shop> onStatusChanged;

  const SADashboardScreen({
    super.key,
    required this.shops,
    required this.onStatusChanged,
  });

  int get _activeCount =>
      shops.where((s) => s.status == ShopStatus.active).length;
  int get _pendingCount =>
      shops.where((s) => s.status == ShopStatus.pending).length;

  List<Shop> get _recentShops => shops.take(5).toList();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ── Header Banner ──────────────────────────────────────────────
          _HeaderBanner(
            totalShops: shops.length,
            pendingCount: _pendingCount,
          ),
          const SizedBox(height: 20),

          // ── KPI Cards ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Platform Overview',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 12),
                _KpiGrid(
                  totalShops: shops.length,
                  activeSubscriptions: _activeCount,
                  pendingApprovals: _pendingCount,
                ),
                const SizedBox(height: 24),

                // ── Recent Shops ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recently Onboarded',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E))),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── Shop Tiles ─────────────────────────────────────────────────
          ..._recentShops.map((shop) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ShopListTile(
                  shop: shop,
                  onStatusChanged: onStatusChanged,
                  onDeleted: null,
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Header Banner ────────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  final int totalShops;
  final int pendingCount;

  const _HeaderBanner(
      {required this.totalShops, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF1A237E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome back,',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 2),
          const Text('Super Admin 👋',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _BannerStat(
                  label: 'Total Shops', value: '$totalShops'),
              const SizedBox(width: 16),
              _BannerStat(
                  label: 'Pending', value: '$pendingCount', isAlert: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlert;
  const _BannerStat(
      {required this.label, required this.value, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isAlert
            ? Colors.orange.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: isAlert
            ? Border.all(color: Colors.orange.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── KPI Grid ─────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final int totalShops;
  final int activeSubscriptions;
  final int pendingApprovals;

  const _KpiGrid({
    required this.totalShops,
    required this.activeSubscriptions,
    required this.pendingApprovals,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _KpiCard(
          title: 'Total Shops',
          value: '$totalShops',
          icon: Icons.store_rounded,
          iconColor: const Color(0xFF1565C0),
          iconBg: const Color(0xFFE3F2FD),
        ),
        _KpiCard(
          title: 'Active',
          value: '$activeSubscriptions',
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF2E7D32),
          iconBg: const Color(0xFFE8F5E9),
        ),
        _KpiCard(
          title: 'MRR',
          value: '\$60',
          icon: Icons.account_balance_wallet_rounded,
          iconColor: const Color(0xFF6A1B9A),
          iconBg: const Color(0xFFF3E5F5),
        ),
        _KpiCard(
          title: 'Pending',
          value: '$pendingApprovals',
          icon: Icons.pending_actions_rounded,
          iconColor: const Color(0xFFE65100),
          iconBg: const Color(0xFFFFF3E0),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              Text(title,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }
}
