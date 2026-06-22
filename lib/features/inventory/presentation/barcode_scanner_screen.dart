import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/database/app_database.dart';
import '../data/barcode_api_service.dart';
import '../providers/inventory_provider.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final BarcodeApiService _apiService = BarcodeApiService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetScanner() {
    setState(() => _isProcessing = false);
    _controller.start();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    final barcode = barcodes.first.rawValue!;
    setState(() => _isProcessing = true);
    _controller.stop();

    // Check for duplicate
    final existing =
        await ref.read(inventoryRepositoryProvider).findByBarcode(barcode);
    if (!mounted) return;

    if (existing != null) {
      _showDuplicateDialog(existing, barcode);
      return;
    }

    // Look up product
    final product = await _apiService.lookupBarcode(barcode);
    if (!mounted) return;

    if (product != null) {
      _showProductFound(product);
    } else {
      _showProductNotFound(barcode);
    }
  }

  void _showDuplicateDialog(InventoryItem existing, String barcode) {
    int addAmount = 1;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Item Already Exists'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('"${existing.name}" is already in your inventory with a quantity of ${existing.quantity}.'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: addAmount > 1
                        ? () => setDialogState(() => addAmount--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text('$addAmount',
                        textAlign: TextAlign.center,
                        style: Theme.of(ctx).textTheme.titleLarge),
                  ),
                  IconButton(
                    onPressed: () => setDialogState(() => addAmount++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _resetScanner();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push('/inventory/detail/${existing.id}');
              },
              child: const Text('View Item'),
            ),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(inventoryRepositoryProvider)
                    .updateQuantity(existing.id, existing.quantity + addAmount);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${existing.name} quantity updated to ${existing.quantity + addAmount}')),
                  );
                  _resetScanner();
                }
              },
              child: Text('Add +$addAmount'),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) _resetScanner();
    });
  }

  void _showProductFound(BarcodeProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (product.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                if (product.imageUrl != null) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: Theme.of(ctx).textTheme.titleLarge),
                      if (product.brand != null)
                        Text(product.brand!,
                            style: TextStyle(color: Colors.grey[600])),
                      Text('Barcode: ${product.barcode}',
                          style: Theme.of(ctx).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            if (product.description != null) ...[
              const SizedBox(height: 12),
              Text(product.description!),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push('/inventory/add', extra: {
                    'barcode': product.barcode,
                    'name': product.name,
                    'brand': product.brand,
                    'imageUrl': product.imageUrl,
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add to Inventory'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _resetScanner();
                },
                child: const Text('Scan Another'),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) _resetScanner();
    });
  }

  void _showProductNotFound(String barcode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Text(
            'No product info found for barcode $barcode. Would you like to add it manually?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetScanner();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/inventory/add', extra: {
                'barcode': barcode,
              });
            },
            child: const Text('Add Manually'),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) _resetScanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),
          // Scan overlay
          Center(
            child: Container(
              width: 280,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? Colors.orange : Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Status indicator
          if (_isProcessing)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Text('Looking up product...',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          if (!_isProcessing)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text('Point camera at a barcode',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
