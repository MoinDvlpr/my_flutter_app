import 'package:flutter/material.dart';

import '../utils/app_textstyles.dart';

class ImagePickerOptions extends StatelessWidget {
  const ImagePickerOptions({super.key, this.onTap});
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return _ImagePickCard(
      icon: Icons.photo_library,
      label: 'Gallery',
      onTap: onTap,
    );
  }
}

class _ImagePickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function()? onTap;
  const _ImagePickCard({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyle.semiBoldTextstyle.copyWith(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
