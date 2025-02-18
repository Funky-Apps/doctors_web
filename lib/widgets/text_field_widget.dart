import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';


class TextFieldWidget extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isRequired;
  final bool isPhone;
  final Widget? suffixIcon;
  final Function(String)? onChanged;

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isRequired = false,
    this.suffixIcon,
    this.isPhone = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGray),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10,),
          child: TextField(
            style: const TextStyle(fontSize: 12),
            textInputAction: TextInputAction.next,
            controller: controller,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              prefixText: isPhone ? '+94 ' : null,
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.hintGray),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
            onChanged: isPhone
                ? (value) {
              if (value.isNotEmpty && value[0] == '0') {
                controller.text = value.substring(1); // Remove the first character
                controller.selection = TextSelection.fromPosition(
                  TextPosition(
                    offset: controller.text.length, // Reset cursor position
                  ),
                );
              }
            }
                : onChanged,
          ),
        ),
        // The label displayed on top of the border
        Positioned(
          left: 10,
          top: -2, // Move label a bit above for better readability
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  backgroundColor: Colors.white, // Ensure label is readable
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    backgroundColor: Colors.white, // Match background
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}


