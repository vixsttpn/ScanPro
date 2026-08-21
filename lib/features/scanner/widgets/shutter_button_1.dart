
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class ShutterButton extends StatelessWidget {
  final VoidCallback onTap;
  const ShutterButton({super.key, required this.onTap});
  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){ HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        width: 78, height: 78,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.text, border: Border.all(color: AppColors.bg, width: 4), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 20)]),
        child: Container(margin: const EdgeInsets.all(6), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.text)),
      ),
    );
  }
}
