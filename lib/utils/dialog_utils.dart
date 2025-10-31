import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';
import '../utils/app_textstyles.dart';
import '../widgets/appsubmitbtn.dart';

class DialogUtils {
  /// Full screen dialogue
  static void showFullScreenDialog({
    required String title,
    required String message,
  }) {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: bg,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: bg,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  const Icon(
                    Icons.check_circle_outline,
                    color: success,
                    size: 48,
                  ),
                  // Title
                  Text(
                    title,
                    style: AppTextStyle.boldTextstyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Message
                  Text(
                    message,
                    style: AppTextStyle.regularTextstyle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // OK Button
                  GlobalAppSubmitBtn(
                    title: 'OK',
                    onTap: () {
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Success Dialog
  static void showSuccessDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onTap,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: AppTextStyle.semiBoldTextstyle.copyWith(
        fontSize: 18,
        color: Colors.green,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.regularTextstyle,
          ),
        ],
      ),
      radius: 10,
      confirm: GlobalAppSubmitBtn(
        title: buttonText,
        onTap: () {
          Get.back();
          if (onTap != null) onTap();
        },
      ),
    );
  }

  /// Error Dialog
  static void showErrorDialog({
    required String title,
    required String message,
    String buttonText = 'Close',
    VoidCallback? onTap,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: AppTextStyle.semiBoldTextstyle.copyWith(
        fontSize: 18,
        color: Colors.red,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.regularTextstyle,
          ),
        ],
      ),
      radius: 10,
      confirm: GlobalAppSubmitBtn(
        title: buttonText,
        onTap: () {
          Get.back();
          if (onTap != null) onTap();
        },
      ),
    );
  }

  /// Warning / Failure Dialog
  static void showWarningDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onTap,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: AppTextStyle.semiBoldTextstyle.copyWith(
        fontSize: 18,
        color: Colors.orange,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: Column(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.regularTextstyle,
          ),
        ],
      ),
      radius: 10,
      confirm: GlobalAppSubmitBtn(
        title: buttonText,
        onTap: () {
          Get.back();
          if (onTap != null) onTap();
        },
      ),
    );
  }

  /// Delete Confirmation Dialog
  static void showDeleteConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmLabel,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyle.regularTextstyle,
      ),
      radius: 10,
      confirm: GlobalAppSubmitBtn(
        title: confirmLabel ?? 'Delete',
        onTap: () {
          Get.back();
          onConfirm();
        },
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text(
          'Cancel',
          style: AppTextStyle.regularTextstyle.copyWith(color: grey),
        ),
      ),
    );
  }
}
