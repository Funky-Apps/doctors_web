import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class RoundTextField extends StatelessWidget {
  const RoundTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.textInputAction,
    this.isPassword = false,
    this.maxLength,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final int? maxLength;
  final Widget? icon;
  final String hintText;
  final String labelText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
      child: TextFormField(
        maxLength: maxLength,
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.black,fontSize: 16),
          // prefixIcon: icon != null ? Icon(icon) : null,
          hintStyle: const TextStyle(color: AppColors.hintGray),
          hintText: hintText,
          suffixIcon: icon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.greyColor), // Adjust the border color if needed
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.anotherBlueColor),
          ),
          filled: true,
          fillColor: Colors.white, // Set to white for better visibility
          isDense: true,
          contentPadding: const EdgeInsets.all(16),
        ),
        obscureText: isPassword,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
      ),
    );
  }
}