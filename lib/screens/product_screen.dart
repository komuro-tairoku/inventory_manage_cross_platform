import 'dart:math';
import 'package:flutter/material.dart';
import 'package:inventory_manage/models/category.dart';
import 'package:inventory_manage/models/products.dart';
import 'package:inventory_manage/repository/category_repository.dart';
import 'package:inventory_manage/repository/product_repository.dart';
import 'package:inventory_manage/repository/sale_repository.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final productRepo = ProductRepository();
  final categoryRepo = CategoryRepository();

  bool isLoading = false;

  final nameCtrl = TextEditingController();
  final costCtrl = TextEditingController();
  final sellCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  List<Category> category = [];
  List<Products> product = [];

  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadCategory();
  }

  void loadProducts() async {
    final data = await productRepo.getAll();
    setState(() => product = data);
  }

  void loadCategory() async {
    final data = await categoryRepo.getAll();
    setState(() => category = data);
  }

  void openForm({Products? product}) {
    if (product != null) {
      nameCtrl.text = product.name;
      costCtrl.text = product.costPrice.toString();
      sellCtrl.text = product.sellPrice.toString();
      companyCtrl.text = product.companyName ?? "";
      quantityCtrl.text = product.quantity.toString();
      imageCtrl.text = product.image ?? "";
      selectedCategoryId = product.categoryId;
    } else {
      nameCtrl.clear();
      costCtrl.clear();
      sellCtrl.clear();
      companyCtrl.clear();
      imageCtrl.clear();
      quantityCtrl.clear();
      selectedCategoryId = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(product == null ? "Thêm sản phẩm" : "Sửa sản phẩm"),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Tên sản phẩm"),
              ),
              TextField(
                controller: companyCtrl,
                decoration: const InputDecoration(labelText: "Tên công ty"),
              ),
              DropdownButtonFormField<int>(
                initialValue: selectedCategoryId,
                hint: const Text("Chọn danh mục"),
                items: category.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    selectedCategoryId = v;
                  });
                },
              ),
              TextField(
                controller: costCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Giá nhập"),
              ),
              TextField(
                controller: sellCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Giá bán"),
              ),
              TextField(
                controller: quantityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Số lượng"),
              ),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(labelText: "Ảnh"),
              ),
              const SizedBox(height: 16),

              // Bọc nút trong Padding để chỉnh vị trí
              // Khoảng cách với ô nhập liệu phía trên
              const SizedBox(height: 16),

              Padding(
                // Đẩy nút lên cao để tránh thanh điều hướng (Home Indicator)
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Center(
                  // Căn giữa nút thay vì kéo dài
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ), // Chỉnh độ to nhỏ của nút
                    ),
                    onPressed: () async {
                      final p = Products(
                        id: product?.id,
                        name: nameCtrl.text,
                        companyName: companyCtrl.text,
                        categoryId: selectedCategoryId,
                        costPrice: double.tryParse(costCtrl.text) ?? 0,
                        sellPrice: double.tryParse(sellCtrl.text) ?? 0,
                        quantity: int.tryParse(quantityCtrl.text) ?? 0,
                        image: imageCtrl.text,
                      );
                      if (product == null) {
                        await productRepo.insert(p);
                      } else {
                        await productRepo.update(p);
                      }
                      loadProducts();
                      Navigator.pop(context);
                    },
                    child: Text(product == null ? "Thêm" : "Cập nhật"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteProduct(int id) async {
    await productRepo.delete(id);
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.widgets,
              color: Colors.white,
              size: 30,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(width: 5),
            Text(
              'Sản phẩm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: product.isEmpty
          ? const Center(child: Text("Không có sản phẩm nào"))
          : ListView.builder(
              itemCount: product.length,
              itemBuilder: (context, index) {
                final p = product[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Giá bán: ${p.sellPrice} | Số lượng: ${p.quantity}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => openForm(product: p),
                          icon: const Icon(Icons.edit, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () => deleteProduct(p.id!),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        backgroundColor: Colors.green,
        child: Icon(
          Icons.add,
          size: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
