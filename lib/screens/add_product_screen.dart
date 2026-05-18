import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import '../repository/product_repository.dart';

class AddProductScreen extends StatefulWidget {
  final String barcode;
  final Product? productToEdit;

  const AddProductScreen({
    super.key,
    required this.barcode,
    this.productToEdit,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController companyCtrl;
  late TextEditingController specificationsCtrl;
  late TextEditingController expiryCtrl;
  late TextEditingController manufacturingCtrl;
  final picker = ImagePicker();

  File? _imageFile;
  final List<File> _galleryImages = [];
  final repo = ProductRepository();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.productToEdit?.name ?? '');
    companyCtrl = TextEditingController(
      text: widget.productToEdit?.companyName ?? '',
    );
    specificationsCtrl = TextEditingController(
      text: widget.productToEdit?.specifications ?? '',
    );
    expiryCtrl = TextEditingController(
      text: widget.productToEdit?.expiryDate ?? '',
    );
    manufacturingCtrl = TextEditingController(
      text: widget.productToEdit?.manufacturingDate ?? '',
    );

    if (widget.productToEdit != null &&
        widget.productToEdit!.image.isNotEmpty) {
      _imageFile = File(widget.productToEdit!.image);
    }
    if (widget.productToEdit != null) {
      for (final path in widget.productToEdit!.galleryImages) {
        if (path.isNotEmpty) {
          _galleryImages.add(File(path));
        }
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    companyCtrl.dispose();
    specificationsCtrl.dispose();
    expiryCtrl.dispose();
    manufacturingCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAdditionalImages() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Thêm ảnh phụ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF6B43FF)),
              title: const Text('Chụp ảnh phụ'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (pickedFile != null) {
                  setState(() {
                    _galleryImages.add(File(pickedFile.path));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF6B43FF),
              ),
              title: const Text('Chọn nhiều ảnh từ thư viện'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFiles = await picker.pickMultiImage();
                if (pickedFiles.isNotEmpty) {
                  setState(() {
                    _galleryImages.addAll(
                      pickedFiles.map((picked) => File(picked.path)),
                    );
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        ),
      ),
    );
  }

  void _openImageViewer(File imageFile, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _ImageViewerScreen(imagePath: imageFile.path, title: title),
      ),
    );
  }

  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn ảnh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF6B43FF)),
              title: const Text('Chụp ảnh'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (pickedFile != null) {
                  setState(() {
                    _imageFile = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Color(0xFF6B43FF)),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  setState(() {
                    _imageFile = File(pickedFile.path);
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickManufacturingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        manufacturingCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        expiryCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> save() async {
    if (nameCtrl.text.isEmpty ||
        companyCtrl.text.isEmpty ||
        expiryCtrl.text.isEmpty ||
        manufacturingCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final product = Product(
        id: widget.productToEdit?.id,
        barcode: widget.productToEdit?.barcode ?? widget.barcode,
        name: nameCtrl.text,
        companyName: companyCtrl.text,
        specifications: specificationsCtrl.text.trim().isEmpty
            ? null
            : specificationsCtrl.text.trim(),
        image: _imageFile?.path ?? widget.productToEdit?.image ?? '',
        galleryImages: _galleryImages.map((file) => file.path).toList(),
        expiryDate: expiryCtrl.text,
        manufacturingDate: manufacturingCtrl.text,
        quantity: widget.productToEdit?.quantity ?? 0,
        costPrice: widget.productToEdit?.costPrice,
        sellPrice: widget.productToEdit?.sellPrice,
        categoryId: widget.productToEdit?.categoryId,
        createAt: widget.productToEdit?.createAt,
      );

      if (widget.productToEdit != null) {
        await repo.update(product);
      } else {
        await repo.insert(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.productToEdit != null
                ? 'Sản phẩm đã cập nhật'
                : 'Sản phẩm đã lưu',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B43FF),
        foregroundColor: Colors.white,
        title: Text(
          widget.productToEdit != null ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Mã vạch: ${widget.productToEdit?.barcode ?? widget.barcode}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: pickImage,
                child: _imageFile == null
                    ? Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: const Icon(Icons.add_a_photo, size: 50),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Chọn ảnh',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên sản phẩm *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.shopping_bag),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: companyCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên công ty *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: specificationsCtrl,
                decoration: InputDecoration(
                  labelText: 'Quy cách',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.confirmation_number_sharp),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ảnh phụ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickAdditionalImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Thêm ảnh phụ'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_galleryImages.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Chưa có ảnh phụ',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _galleryImages.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final file = _galleryImages[index];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _openImageViewer(file, 'Ảnh phụ ${index + 1}'),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                file,
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _galleryImages.removeAt(index);
                                });
                              },
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 20,
                              ),
                              tooltip: 'Xóa ảnh',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: pickManufacturingDate,
                child: TextField(
                  controller: manufacturingCtrl,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Ngày sản xuất *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    hintText: 'DD/MM/YYYY',
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: pickExpiryDate,
                child: TextField(
                  controller: expiryCtrl,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Hạn sử dụng *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    hintText: 'DD/MM/YYYY',
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 19, 236, 16),
                  ),
                  onPressed: isLoading ? null : save,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 25),
                  label: Text(
                    widget.productToEdit != null ? 'Cập nhật' : 'Lưu sản phẩm',
                    style: const TextStyle(color: Colors.white, fontSize: 27),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageViewerScreen extends StatelessWidget {
  final String imagePath;
  final String title;

  const _ImageViewerScreen({required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF6B43FF),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }
}
