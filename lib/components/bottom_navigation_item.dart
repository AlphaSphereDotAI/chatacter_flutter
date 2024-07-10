import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:chatacter/pages/main_page.dart'; // Ensure this import is here

class BottomNavigationItem extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final BottomNavigationPages current;
  final BottomNavigationPages pageName;

  const BottomNavigationItem({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.current,
    required this.pageName,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        icon,
        colorFilter: ColorFilter.mode(
            current == pageName
                ? AppColors.black
                : AppColors.black.withOpacity(0.3),
            BlendMode.srcIn),
      ),
    );
  }
}
