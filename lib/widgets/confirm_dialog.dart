import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_textstyles.dart';
import 'appsubmitbtn.dart';

void showDeleteConfirmationDialog({
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
      onTap:
      onConfirm,
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
