import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  List<dynamic> _customers = [];
  List<dynamic> _allCustomers = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      final res = await ref.read(apiClientProvider).get('/orders');
      if (mounted) {
        final List<dynamic> orders = res.data;
        
        // Map orders to represent customer visits (same logic as React app)
        final formattedData = orders.where((order) {
          final name = order['customer']?['name'];
          final phone = order['customer']?['phone'];
          return (name != null && name.trim().toLowerCase() != 'unknown') ||
                 (phone != null && phone.trim().toLowerCase() != 'n/a');
        }).map((order) {
          return {
            'id': order['_id'],
            'name': order['customer']?['name'] ?? 'Unknown',
            'phone': order['customer']?['phone'] ?? 'N/A',
            'date': DateTime.parse(order['createdAt']),
            'totalAmount': order['totalAmount'] ?? 0,
          };
        }).toList();

        // Sort by date descending
        formattedData.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

        setState(() {
          _customers = formattedData;
          _allCustomers = formattedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Error fetching customers: $e');
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _customers = _allCustomers.where((c) {
          final cDate = c['date'] as DateTime;
          return cDate.year == date.year && cDate.month == date.month && cDate.day == date.day;
        }).toList();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
      _customers = _allCustomers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers List'),
        actions: [
          if (_selectedDate != null)
            IconButton(icon: const Icon(Icons.clear), onPressed: _clearDateFilter),
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickDate),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_selectedDate != null)
                  Container(
                    width: double.infinity,
                    color: Colors.blue.shade50,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      'Filtering by date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(
                  child: _customers.isEmpty
                      ? const Center(child: Text('No customers found for this date.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _customers.length,
                          itemBuilder: (context, index) {
                            final customer = _customers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple.shade100,
                                  child: Text(customer['name'][0].toUpperCase(), style: TextStyle(color: Colors.purple.shade900, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(customer['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Phone: ${customer['phone']}\nDate: ${(customer['date'] as DateTime).toLocal().toString().split(' ')[0]}'),
                                isThreeLine: true,
                                trailing: Text('\$${customer['totalAmount'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.green)),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
