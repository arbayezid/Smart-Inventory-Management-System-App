import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int qty;
  final int stock;
  double get total => price * qty;

  CartItem({required this.id, required this.name, required this.price, required this.qty, required this.stock});
}

class SellProductScreen extends ConsumerStatefulWidget {
  const SellProductScreen({super.key});

  @override
  ConsumerState<SellProductScreen> createState() => _SellProductScreenState();
}

class _SellProductScreenState extends ConsumerState<SellProductScreen> {
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '0');
  
  List<dynamic> _products = [];
  dynamic _selectedProduct;
  int _quantity = 1;
  final List<CartItem> _cart = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final res = await ref.read(apiClientProvider).get('/products');
      setState(() => _products = res.data);
    } catch (e) {
      debugPrint('Failed to load products: $e');
    }
  }

  void _addToCart() {
    if (_selectedProduct == null) return;
    if (_quantity > _selectedProduct['quantity']) {
      _showErrorSnackBar('Not enough stock available!');
      return;
    }

    final existingIndex = _cart.indexWhere((item) => item.id == _selectedProduct['_id']);
    if (existingIndex >= 0) {
      final newQty = _cart[existingIndex].qty + _quantity;
      if (newQty > _selectedProduct['quantity']) {
        _showErrorSnackBar('Exceeds available stock limit!');
        return;
      }
      setState(() => _cart[existingIndex].qty = newQty);
    } else {
      setState(() {
        _cart.add(CartItem(
          id: _selectedProduct['_id'],
          name: _selectedProduct['name'],
          price: (_selectedProduct['price'] as num).toDouble(),
          qty: _quantity,
          stock: _selectedProduct['quantity'],
        ));
      });
    }
    setState(() {
      _selectedProduct = null;
      _quantity = 1;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )
    );
  }

  double get _subtotal => _cart.fold(0, (sum, item) => sum + item.total);
  double get _discountAmt => _subtotal * ((double.tryParse(_discountCtrl.text) ?? 0) / 100);
  double get _grandTotal => _subtotal - _discountAmt;

  Future<void> _handleCheckout() async {
    if (_cart.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(apiClientProvider).post('/orders/checkout', data: {
        'customerName': _customerNameCtrl.text.isEmpty ? 'Walk-in Customer' : _customerNameCtrl.text,
        'customerPhone': _customerPhoneCtrl.text,
        'cart': _cart.map((e) => {
          'id': e.id, 'name': e.name, 'price': e.price, 'qty': e.qty, 'stock': e.stock, 'total': e.total
        }).toList(),
        'totalAmount': _grandTotal,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Sale Completed Successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )
        );
        setState(() {
          _cart.clear();
          _customerNameCtrl.clear();
          _customerPhoneCtrl.clear();
        });
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Checkout failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('New Sale', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle('Customer Details'),
                        const SizedBox(height: 12),
                        _buildCustomerCard(),
                        
                        const SizedBox(height: 24),
                        _buildSectionTitle('Add Product'),
                        const SizedBox(height: 12),
                        _buildAddProductCard(),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle('Shopping Cart'),
                            if (_cart.isNotEmpty)
                              Text('${_cart.length} items', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_cart.isEmpty)
                          _buildEmptyCartState()
                        else
                          _buildCartList(),
                        
                        const SizedBox(height: 40), // Padding before bottom sheet
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Billing Area
          _buildBottomBillingArea(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildTextField(_customerNameCtrl, 'Customer Name (Optional)', Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(_customerPhoneCtrl, 'Phone Number (Optional)', Icons.phone_outlined, isPhone: true),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade300),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildAddProductCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField(
            value: _selectedProduct,
            decoration: InputDecoration(
              labelText: 'Select Product',
              prefixIcon: Icon(Icons.inventory_2_outlined, color: Colors.blue.shade400),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            isExpanded: true,
            items: _products.map((p) => DropdownMenuItem(
              value: p, 
              child: Text('${p['name']} - \$${p['price']}', overflow: TextOverflow.ellipsis)
            )).toList(),
            onChanged: (val) => setState(() { _selectedProduct = val; _quantity = 1; }),
          ),
          
          if (_selectedProduct != null) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Stock', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${_selectedProduct['quantity']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    ),
                  ],
                ),
                
                // Quantity Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        color: Colors.black87,
                        onPressed: () => setState(() => _quantity > 1 ? _quantity-- : null)
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        color: Colors.black87,
                        onPressed: () => setState(() => _quantity++)
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_shopping_cart, size: 20),
                  SizedBox(width: 8),
                  Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildEmptyCartState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Add products above to start selling', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return Column(
      children: _cart.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.inventory_2, color: Colors.blue.shade400),
          ),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('\$${item.price} x ${item.qty}', style: TextStyle(color: Colors.grey.shade600)),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => setState(() => _cart.remove(item)),
                child: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildBottomBillingArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_cart.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  Text('\$${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Due', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('\$${_grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF4CAF50))),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _cart.isEmpty || _isLoading ? null : _handleCheckout,
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment),
                        SizedBox(width: 8),
                        Text('Complete Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
