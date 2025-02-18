import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/constants.dart';

class ButtonWithIcon extends StatelessWidget {
  const ButtonWithIcon({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.color = AppColors.buttonBrown,
    this.height = 45,
    this.iconColor = AppColors.whiteColor,
  });

  final VoidCallback? onPressed;
  final String label;
  final Color color;
  final double height;
  final Widget? icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: onPressed == null ? AppColors.buttonBrown : color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.buttonBrown,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.whiteColor, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: Constants.defaultGap),
              if (icon != null)
                IconTheme(
                  data: IconThemeData(color: iconColor), // Apply the icon color
                  child: icon!,
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
