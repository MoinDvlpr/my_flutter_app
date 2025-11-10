// confirm_price_dialog.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_textstyles.dart';
import 'app_colors.dart';

/// Controller to handle delayed showing of confirm price dialog
class ConfirmPriceController extends GetxController {
  final RxBool _isDialogShown = false.obs;

  /// Starts a delayed confirmation dialog after a [delay]
  void startDelayedConfirm({
    Duration delay = const Duration(seconds: 2),
    required VoidCallback onAccept,
    VoidCallback? onCancel,
  }) {
    if (_isDialogShown.value) return; // prevent multiple dialogs
    _isDialogShown.value = true;

    Timer(delay, () async {
      if (Get.isDialogOpen ?? false) return;
      if (!Get.context!.mounted)
        return; // prevent showing when widget unmounted

      await showConfirmPriceDialog(
        onApply: () {
          _isDialogShown.value = false;
          onAccept();
        },
        onCancel: () {
          _isDialogShown.value = false;
          if (onCancel != null) onCancel();
        },
      );
    });
  }

  @override
  void onClose() {
    _isDialogShown.value = false;
    super.onClose();
  }
}

/// Modern confirm price dialog with custom UI
/// User must select an option - cannot dismiss by swiping or tapping outside
Future<void> showConfirmPriceDialog({
  required VoidCallback onApply,
  VoidCallback? onCancel,
}) async {
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false, // Prevent back button dismissal
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.price_change_rounded, color: primary, size: 48),
              const SizedBox(height: 16),
              Text(
                "Confirm Best Price",
                style: AppTextStyle.semiBoldTextstyle.copyWith(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "We've set the best possible price for you.\nDo you want to accept this price?",
                textAlign: TextAlign.center,
                style: AppTextStyle.lableStyle.copyWith(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        if (onCancel != null) onCancel();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Cancel",
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onApply();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Apply",
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false, // Prevent dismissal by tapping outside
  );
}
