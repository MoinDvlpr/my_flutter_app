// confirm_price_dialog.dart
// GetX-based delayed confirmation dialog for auto price changes (without constants file)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_textstyles.dart';

class ConfirmPriceController extends GetxController {
  final RxBool _isDialogShown = false.obs;

  void startDelayedConfirm({
    Duration delay = const Duration(seconds: 2),
    required VoidCallback onAccept,
    VoidCallback? onCancel,
  }) {
    if (_isDialogShown.value) return;

    _isDialogShown.value = true;

    Timer(delay, () {
      if (Get.isDialogOpen ?? false) return; // prevent multiple dialogs

      Get.dialog(
        ConfirmPriceDialog(
          onAccept: () {
            _isDialogShown.value = false;
            Get.back();
            onAccept();
          },
          onCancel: () {
            _isDialogShown.value = false;
            Get.back();
            if (onCancel != null) onCancel();
          },
        ),
        barrierDismissible: false,
      );
    });
  }
}

class ConfirmPriceDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  const ConfirmPriceDialog({
    Key? key,
    required this.onAccept,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Confirm automatic price change',
                    style: AppTextStyle.semiBoldTextstyle,
                  ),
                ),
                IconButton(onPressed: onCancel, icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'We have automatically adjusted the selling price based on current market conditions and stock levels.\n\n'
                  'Would you like to apply new selling price now?\n\n'
                  'If you accept, the updated price will be used for future sales,\n\n'
                  'you can change prices manually after accept.',
              style: AppTextStyle.regularTextstyle.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onAccept,
                    child: Text(
                      'Apply',
                      style: AppTextStyle.lableStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: onCancel,
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.lableStyle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== USAGE EXAMPLE ====================
/*
final confirmController = Get.put(ConfirmPriceController());

confirmController.startDelayedConfirm(
  delay: Duration(seconds: 3), // optional, default = 2
  onAccept: () {
    Get.snackbar('Price updated', 'Selling price accepted and saved');
  },
  onCancel: () {
    Get.snackbar('No change', 'Selling price left unchanged');
  },
);
*/
