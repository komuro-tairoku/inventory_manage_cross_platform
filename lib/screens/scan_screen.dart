import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../repository/product_repository.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late MobileScannerController cameraController;
  final picker = ImagePicker();
  final repo = ProductRepository();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _goToAddProduct(String barcode) async {
    final existing = await repo.getByBarcode(barcode);
    if (!mounted) return;

    if (existing != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: existing),
        ),
      ).then((result) {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        if (result == true && mounted) Navigator.pop(context, true);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddProductScreen(barcode: barcode)),
      ).then((result) {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        if (result == true && mounted) Navigator.pop(context, true);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await cameraController.analyzeImage(pickedFile.path);

      if (!mounted) return;
      Navigator.pop(context);

      if (result != null && result.barcodes.isNotEmpty) {
        final barcode = result.barcodes.first.rawValue;
        if (barcode != null && !_isProcessing) {
          setState(() => _isProcessing = true);
          _goToAddProduct(barcode);
        }
      } else {
        _showManualInputDialog();
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showManualInputDialog();
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await cameraController.analyzeImage(pickedFile.path);

      if (!mounted) return;
      Navigator.pop(context);

      if (result != null && result.barcodes.isNotEmpty) {
        final barcode = result.barcodes.first.rawValue;
        if (barcode != null && !_isProcessing) {
          setState(() => _isProcessing = true);
          _goToAddProduct(barcode);
        }
      } else {
        _showManualInputDialog();
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showManualInputDialog();
    }
  }

  void _showManualInputDialog() {
    final barcodeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Không tìm thấy mã vạch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Không thể đọc mã vạch từ ảnh.\nNhập mã thủ công hoặc thử ảnh khác.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: barcodeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nhập mã vạch',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final barcode = barcodeCtrl.text.trim().isNotEmpty
                  ? barcodeCtrl.text.trim()
                  : 'MANUAL_${DateTime.now().millisecondsSinceEpoch}';
              Navigator.pop(context);
              if (!_isProcessing) {
                setState(() => _isProcessing = true);
                _goToAddProduct(barcode);
              }
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text(
          'Quét mã vạch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          /// CAMERA
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isProcessing) return;

              final barcodes = capture.barcodes;

              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first.rawValue;

                if (barcode != null) {
                  setState(() => _isProcessing = true);
                  _goToAddProduct(barcode);
                }
              }
            },
          ),

          /// OVERLAY
          Container(color: Colors.black.withOpacity(0.35)),

          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),

          /// TEXT
          Positioned(
            top: 140,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 70,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Đưa mã vạch vào khung',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hệ thống sẽ tự động nhận diện',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          /// BOTTOM ACTIONS
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Chụp ảnh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.lightBlueAccent,
                      elevation: 8,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo),
                    label: const Text('Thư viện'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? const BorderSide(color: Colors.white, width: 5)
                : BorderSide.none,
            bottom:
                alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: Colors.white, width: 5)
                : BorderSide.none,
            left:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? const BorderSide(color: Colors.white, width: 5)
                : BorderSide.none,
            right:
                alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: Colors.white, width: 5)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
