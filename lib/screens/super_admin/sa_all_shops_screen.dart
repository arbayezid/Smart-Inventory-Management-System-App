// lib/screens/super_admin/sa_all_shops_screen.dart
//
// Mobile-first All Shops screen.
// Pattern: Search bar + Filter chips + ListView of ShopListTile cards.
// No DataTable — fully scrollable, touch-friendly.

import 'package:flutter/material.dart';
import '../../models/shop.dart';
import 'widgets/shop_list_tile.dart';

class SAAllShopsScreen extends StatefulWidget {
  final List<Shop> shops;
  final ValueChanged<Shop> onStatusChanged;
  final ValueChanged<Shop> onShopDeleted;

  const SAAllShopsScreen({
    super.key,
    required this.shops,
    required this.onStatusChanged,
    required this.onShopDeleted,
  });

  @override
  State<SAAllShopsScreen> createState() => _SAAllShopsScreenState();
}

class _SAAllShopsScreenState extends State<SAAllShopsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // null = All, otherwise filter by status
  ShopStatus? _activeFilter;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Derived filtered list ──────────────────────────────────────────────────

  List<Shop> get _filtered {
    var list = widget.shops;

    // Apply status filter
    if (_activeFilter != null) {
      list = list.where((s) => s.status == _activeFilter).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((s) =>
              s.name.toLowerCase().contains(_searchQuery) ||
              s.ownerEmail.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return list;
  }

  // ── Counts for filter chips ────────────────────────────────────────────────

  int get _pendingCount =>
      widget.shops.where((s) => s.status == ShopStatus.pending).length;
  int get _activeCount =>
      widget.shops.where((s) => s.status == ShopStatus.active).length;
  int get _rejectedCount =>
      widget.shops.where((s) => s.status == ShopStatus.rejected).length;

  // ── Add New Shop bottom sheet ──────────────────────────────────────────────

  void _showAddShopSheet() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Add New Shop',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameCtrl,
                  decoration: _inputDecor('Shop Name', Icons.store_outlined),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      _inputDecor('Owner Email', Icons.email_outlined),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Valid email required' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '"${nameCtrl.text}" added successfully'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    child: const Text('Add Shop',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddShopSheet,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Shop',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // ── Search + Filter header ────────────────────────────────────
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search shops or emails…',
                    hintStyle:
                        TextStyle(fontSize: 14, color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF1565C0), width: 1.5),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        count: widget.shops.length,
                        isSelected: _activeFilter == null,
                        onTap: () =>
                            setState(() => _activeFilter = null),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pending',
                        count: _pendingCount,
                        isSelected: _activeFilter == ShopStatus.pending,
                        color: const Color(0xFFE65100),
                        onTap: () => setState(
                            () => _activeFilter = ShopStatus.pending),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Active',
                        count: _activeCount,
                        isSelected: _activeFilter == ShopStatus.active,
                        color: const Color(0xFF2E7D32),
                        onTap: () => setState(
                            () => _activeFilter = ShopStatus.active),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Restricted',
                        count: _rejectedCount,
                        isSelected: _activeFilter == ShopStatus.rejected,
                        color: const Color(0xFFC62828),
                        onTap: () => setState(
                            () => _activeFilter = ShopStatus.rejected),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Result count bar ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${filtered.length} shop${filtered.length == 1 ? '' : 's'} found',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500),
            ),
          ),

          // ── Shop list ─────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(query: _searchQuery)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (context, i2) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final shop = filtered[i];
                      return ShopListTile(
                        key: ValueKey(shop.id),
                        shop: shop,
                        onStatusChanged: (s) {
                          widget.onStatusChanged(s);
                          setState(() {});
                        },
                        onDeleted: (s) {
                          widget.onShopDeleted(s);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('"${s.name}" removed'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red[700],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.color = const Color(0xFF1565C0),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              query.isNotEmpty ? Icons.search_off : Icons.store_outlined,
              size: 48,
              color: Colors.grey[350],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            query.isNotEmpty ? 'No results for "$query"' : 'No shops found',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500]),
          ),
          const SizedBox(height: 6),
          Text(
            query.isNotEmpty
                ? 'Try a different name or email'
                : 'Tap + Add Shop to get started',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
