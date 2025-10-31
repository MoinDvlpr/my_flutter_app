import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbars {
  static void success(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  static void error(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  static void warning(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(12),
      borderRadius: 8,
    );
  }
}
