import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colors.dart';

class GlobalTextFormField extends StatelessWidget {
  const GlobalTextFormField({
    super.key,
    this.label,
    this.onTap,
    this.readOnly = false,
    this.controller,
    this.validator,
    this.maxlines,
    this.textInputType,
    this.inputFormatters,
    this.obscureText,
    this.focusNode,
    this.suffixBtn,
    this.onChanged,
  });
  final String? label;
  final bool? obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final int? maxlines;
  final void Function()? onTap;
  final bool readOnly;
  final Widget? suffixBtn;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? textInputType;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            spreadRadius: 2.0,
            blurRadius: 8.0,
            color: grey.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: TextFormField(
        readOnly: readOnly,
        focusNode: focusNode,
        controller: controller,
        keyboardType: textInputType,
        inputFormatters: inputFormatters,
        maxLines: maxlines ?? 1,
        validator: validator,
        obscureText: obscureText ?? false,
        onChanged: onChanged,
        onTap: onTap,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        decoration: InputDecoration(labelText: label, suffixIcon: suffixBtn),
      ),
    );
  }
}
