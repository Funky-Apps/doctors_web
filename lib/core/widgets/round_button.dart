import 'package:flutter/material.dart';

import '../constants/app_colors.dart';


class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.color = AppColors.lightBlueColor,
    this.labelColor = AppColors.whiteColor,
    this.height = 50,
    this.width = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
  });

  final VoidCallback? onPressed;
  final String label;
  final Color color;
  final Color labelColor;
  final double height;
  final double width;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:padding,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: height,
          width: width == 0 ? double.infinity : width,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.darkBlueColor,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 16,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
      ),
    );
  }
}
