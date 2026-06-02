import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'inventory/add_product_screen.dart';
import 'inventory/sell_product_screen.dart';
import 'order/order_list_screen.dart';
import 'customer/customer_list_screen.dart';
import 'inventory/inventory_list_screen.dart';
import 'report/ai_analytics_screen.dart';
import 'profile_screen.dart'; // Added Profile Screen
import '../../core/api_client.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const SellProductScreen(),
    const AddProductScreen(),
    const OrderListScreen(),
    const CustomerListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(auth.user?.name ?? 'Shop Owner', style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(auth.user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(auth.user?.name?.substring(0, 1).toUpperCase() ?? 'S', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1976D2), Color(0xFF1565C0), Color(0xFF0D47A1)],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('All Products (Inventory)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryListScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: Colors.purple),
              title: const Text('AI Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AiAnalyticsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        elevation: 10,
        backgroundColor: Colors.white,
        indicatorColor: Colors.blue.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: Colors.blue), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale, color: Colors.blue), label: 'POS'),
          NavigationDestination(icon: Icon(Icons.add_box_outlined), selectedIcon: Icon(Icons.add_box, color: Colors.blue), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long, color: Colors.blue), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people, color: Colors.blue), label: 'Customers'),
        ],
      ),
    );
  }
}

// ----------------- HOME TAB -----------------

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  Map<String, dynamic> _stats = {
    'totalProducts': 0, 'todaySell': 0, 'yesterdaySell': 0, 'totalSell': 0, 'stockIssues': 0
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final productsRes = await ref.read(apiClientProvider).get('/products');
      final ordersRes = await ref.read(apiClientProvider).get('/orders');
      
      final products = productsRes.data as List;
      final orders = ordersRes.data as List;

      double totalSell = 0;
      double todaySell = 0;
      int stockIssues = products.where((p) => (p['quantity'] ?? 0) < 20).length;

      final now = DateTime.now();
      
      for (var order in orders) {
        final total = (order['totalAmount'] ?? 0).toDouble();
        totalSell += total;
        
        final date = DateTime.tryParse(order['createdAt'])?.toLocal();
        if (date != null && date.year == now.year && date.month == now.month && date.day == now.day) {
          todaySell += total;
        }
      }

      if (mounted) {
        setState(() {
          _stats = {
            'totalProducts': products.length,
            'todaySell': todaySell,
            'totalSell': totalSell,
            'stockIssues': stockIssues,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Smart Inventory', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(auth.user?.name ?? "User"),
              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ))
                    else
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _buildStatCard('Today\'s Sales', '\$${_stats['todaySell'].toStringAsFixed(2)}', Icons.trending_up, Colors.green),
                          _buildStatCard('Total Sales', '\$${_stats['totalSell'].toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.blue),
                          _buildStatCard('Total Products', '${_stats['totalProducts']}', Icons.inventory_2, Colors.orange),
                          _buildStatCard('Low Stock', '${_stats['stockIssues']}', Icons.warning_amber_rounded, Colors.red),
                        ],
                      ),
                    
                    const SizedBox(height: 32),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickAction(context, 'Make Sale', Icons.point_of_sale, Colors.blue, () {
                          // Change to POS tab
                          final state = context.findAncestorStateOfType<_DashboardScreenState>();
                          state?.setState(() => state._currentIndex = 1);
                        }),
                        _buildQuickAction(context, 'Add Item', Icons.add_box, Colors.indigo, () {
                          // Change to Add Product tab
                          final state = context.findAncestorStateOfType<_DashboardScreenState>();
                          state?.setState(() => state._currentIndex = 2);
                        }),
                        _buildQuickAction(context, 'Orders', Icons.receipt_long, Colors.purple, () {
                          // Change to Orders tab
                          final state = context.findAncestorStateOfType<_DashboardScreenState>();
                          state?.setState(() => state._currentIndex = 3);
                        }),
                        _buildQuickAction(context, 'Analytics', Icons.auto_awesome, Colors.teal, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AiAnalyticsScreen()));
                        }),
                      ],
                    ),

                    const SizedBox(height: 32),
                    if (_stats['stockIssues'] > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Attention Needed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                                  const SizedBox(height: 4),
                                  Text('You have ${_stats['stockIssues']} products running low on stock. Please restock soon.', style: TextStyle(color: Colors.red.shade800, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF1976D2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back,',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here is what\'s happening with your store today.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}
