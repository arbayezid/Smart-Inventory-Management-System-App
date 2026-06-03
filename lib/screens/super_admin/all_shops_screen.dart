// lib/screens/super_admin/all_shops_screen.dart

import 'package:flutter/material.dart';
import '../../models/shop.dart';
import 'widgets/status_badge.dart';

class AllShopsScreen extends StatefulWidget {
  final List<Shop> shops;
  final ValueChanged<Shop> onStatusChanged;

  const AllShopsScreen({
    super.key,
    required this.shops,
    required this.onStatusChanged,
  });

  @override
  State<AllShopsScreen> createState() => _AllShopsScreenState();
}

class _AllShopsScreenState extends State<AllShopsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Shop> get _pendingShops =>
      widget.shops.where((s) => s.status == ShopStatus.pending).toList();

  List<Shop> get _activeShops =>
      widget.shops.where((s) => s.status == ShopStatus.active).toList();

  List<Shop> get _rejectedShops =>
      widget.shops.where((s) => s.status == ShopStatus.rejected).toList();

  /// Applies search filter on a list of shops.
  List<Shop> _applySearch(List<Shop> source) {
    if (_searchQuery.isEmpty) return source;
    return source
        .where((s) =>
            s.name.toLowerCase().contains(_searchQuery) ||
            s.ownerEmail.toLowerCase().contains(_searchQuery))
        .toList();
  }

  int get _pendingCount =>
      widget.shops.where((s) => s.status == ShopStatus.pending).length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Shops',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New Shop',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Search + Filter Row ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search shops or emails...',
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey, size: 20),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      hintStyle: TextStyle(fontSize: 13.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.grey[700]),
                  tooltip: 'Filters',
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Tab Bar ──────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.blue[600],
            labelColor: Colors.blue[700],
            unselectedLabelColor: Colors.grey[500],
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: [
              const Tab(text: 'ALL SHOPS'),
              Tab(text: 'PENDING ($_pendingCount)'),
              const Tab(text: 'ACTIVE'),
              const Tab(text: 'REJECTED / RESTRICTED'),
            ],
          ),
          const SizedBox(height: 12),

          // ── Tab Views ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ShopsTableView(
                  shops: _applySearch(widget.shops),
                  onStatusChanged: widget.onStatusChanged,
                  showMrr: true,
                ),
                _ShopsTableView(
                  shops: _applySearch(_pendingShops),
                  onStatusChanged: widget.onStatusChanged,
                  showMrr: true,
                ),
                _ShopsTableView(
                  shops: _applySearch(_activeShops),
                  onStatusChanged: widget.onStatusChanged,
                  showMrr: true,
                ),
                _ShopsTableView(
                  shops: _applySearch(_rejectedShops),
                  onStatusChanged: widget.onStatusChanged,
                  showMrr: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shops Table View ─────────────────────────────────────────────────────────

class _ShopsTableView extends StatelessWidget {
  final List<Shop> shops;
  final ValueChanged<Shop> onStatusChanged;
  final bool showMrr;

  const _ShopsTableView({
    required this.shops,
    required this.onStatusChanged,
    this.showMrr = false,
  });

  static const _headerStyle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: Color(0xFF8A8A9A),
  );

  @override
  Widget build(BuildContext context) {
    if (shops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No shops found',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 44,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 52,
            columnSpacing: 24,
            dividerThickness: 1,
            columns: [
              const DataColumn(label: Text('Shop Name', style: _headerStyle)),
              const DataColumn(label: Text('Owner Email', style: _headerStyle)),
              const DataColumn(label: Text('Plan', style: _headerStyle)),
              if (showMrr)
                const DataColumn(label: Text('MRR', style: _headerStyle)),
              const DataColumn(label: Text('Status', style: _headerStyle)),
              const DataColumn(
                  label: Text('Joined Date', style: _headerStyle)),
              const DataColumn(label: Text('Action', style: _headerStyle)),
            ],
            rows: shops.map((shop) => _buildRow(shop)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(Shop shop) {
    return DataRow(cells: [
      DataCell(Text(shop.name,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13.5))),
      DataCell(Text(shop.ownerEmail,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
      DataCell(Text(shop.plan,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
      if (showMrr)
        DataCell(Text(shop.mrr,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        const PopupMenuDivider(),
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
