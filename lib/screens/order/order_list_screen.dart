import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final res = await ref.read(apiClientProvider).get('/orders');
      if (mounted) {
        setState(() {
          _orders = res.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Error fetching orders: $e');
      }
    }
  }

  void _showOrderDetails(dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final cart = order['cart'] as List<dynamic>? ?? [];
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 48, height: 6, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Details', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (order['status'] ?? 'Completed') == 'Completed' ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order['status'] ?? 'Completed',
                        style: TextStyle(fontWeight: FontWeight.bold, color: (order['status'] ?? 'Completed') == 'Completed' ? Colors.green.shade800 : Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('ID: ${order['_id']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                Text('Date: ${DateTime.tryParse(order['createdAt'] ?? '')?.toLocal().toString().split('.')[0] ?? "N/A"}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text('Purchased Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: cart.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item['name'] ?? 'Unknown Item', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Qty: ${item['qty']} x \$${item['price']}'),
                        trailing: Text('\$${item['total']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      );
                    },
                  ),
                ),
                const Divider(thickness: 2),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('\$${order['totalAmount']}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Recent Orders', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: _orders.isEmpty
                  ? CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text('No orders found', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                const Text('Pull to refresh', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final customerName = order['customer']?['name'] ?? 'Walk-in Customer';
                        final customerPhone = order['customer']?['phone'] ?? 'N/A';
                        final status = order['status'] ?? 'Completed';
                        final date = DateTime.tryParse(order['createdAt'] ?? '')?.toLocal();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showOrderDetails(order),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.blue.shade50,
                                    child: Text(
                                      customerName[0].toUpperCase(),
                                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text('Phone: $customerPhone', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: status == 'Completed' ? Colors.green.shade50 : Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: status == 'Completed' ? Colors.green.shade200 : Colors.orange.shade200),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: status == 'Completed' ? Colors.green.shade700 : Colors.orange.shade700),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (date != null)
                                              Text(
                                                '${date.day}/${date.month}/${date.year}',
                                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${order['totalAmount']}',
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.green),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Text('Details', style: TextStyle(color: Colors.blue.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 4),
                                          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blue.shade600),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
