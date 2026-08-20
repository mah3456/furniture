import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stores/Domain/entities/product_entity.dart';

import '../../providers/product_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {

  final Product? product;

  const AddProductScreen({super.key,  this.product});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();


  // قائمة أنواع المنتجات
  final List<String> _productTypes = ['إلكترونيات', 'ملابس', 'طعام', 'أثاث', 'أخرى'];
  String _selectedType = 'إلكترونيات';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.product != null) {
      _nameController.text = widget.product!.name ?? 'none';
      _typeController.text = widget.product!.type ?? 'none';
      _priceController.text = widget.product!.price.toString() ?? 'none';
      _descriptionController.text = widget.product!.description ?? 'none';
      _selectedType = widget.product!.type ?? 'none';
    }

  }


  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'تحديث بيانات المنتج' : 'إضافة منتج جديد'),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عرض رسالة الخطأ
                if (productState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            productState.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                // اسم المنتج
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج',
                    hintText: 'أدخل اسم المنتج',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم المنتج';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 25),

                // نوع المنتج
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'نوع المنتج',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _productTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 25),

                // سعر المنتج
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'السعر',
                    hintText: 'أدخل سعر المنتج',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'ريال',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال السعر';
                    }
                    if (double.tryParse(value) == null) {
                      return 'يرجى إدخال رقم صحيح';
                    }
                    if (double.parse(value) <= 0) {
                      return 'السعر يجب أن يكون أكبر من صفر';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 25),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    hintText: 'أدخل الوصف',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال  الوصف';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),




                // زر الإضافة
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: productState.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {

                              if(widget.product == null){
                                ref.read(productProvider.notifier).addProduct(
                                    name: _nameController.text.trim(),
                                    type: _selectedType,
                                    price: double.parse(_priceController.text.trim()),
                                    description: _descriptionController.text.trim()

                                );

                              } {

                                ref.read(productProvider.notifier).addProduct(
                                    name: _nameController.text.trim(),
                                    type: _selectedType,
                                    price: double.parse(_priceController.text.trim()),
                                    description: _descriptionController.text.trim()

                                );

                              }
                              
                              // عرض رسالة نجاح
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إضافة المنتج بنجاح'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              
                              // العودة للشاشة السابقة
                              Navigator.pop(context);
                            }
                          },
                    icon: productState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : widget.product != null ? SizedBox() :const Icon(Icons.add) ,
                    label: Text(
                      productState.isLoading ? 'جاري الإضافة...' : widget.product != null ? 'تحديث البيانات' : 'إضافة منتج جديد',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}