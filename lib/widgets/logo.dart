import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/theme.dart';

class TimeWiseLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const TimeWiseLogo({
    super.key,
    this.size = 40,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'TimeWise',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: size * 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
} 