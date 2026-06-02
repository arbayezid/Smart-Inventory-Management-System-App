import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _supplierController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final payload = {
        "name": _nameController.text,
        "category": _categoryController.text,
        "sku": _skuController.text,
        "price": double.parse(_priceController.text),
        "quantity": int.parse(_quantityController.text),
        "supplier": _supplierController.text,
        "description": _descriptionController.text,
      };

      await ref.read(apiClientProvider).post('/products', data: payload);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!'), backgroundColor: Colors.green),
        );
        _formKey.currentState!.reset();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Product Name', _nameController, Icons.inventory_2_outlined, true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Category', _categoryController, Icons.category_outlined, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('SKU (Barcode)', _skuController, Icons.qr_code_scanner, true)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Selling Price', _priceController, Icons.attach_money, true, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Initial Stock', _quantityController, Icons.layers_outlined, true, isNumber: true)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField('Supplier (Optional)', _supplierController, Icons.local_shipping_outlined, false),
              const SizedBox(height: 16),
              _buildTextField('Description (Optional)', _descriptionController, Icons.description_outlined, false, maxLines: 3),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save_outlined),
                label: Text(_isLoading ? 'Saving...' : 'Save Product'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _submitProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool required, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
      validator: required ? (value) {
        if (value == null || value.isEmpty) return 'Required';
        return null;
      } : null,
    );
  }
}
