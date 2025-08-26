import 'package:flutter/material.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class StrengthIndicator extends StatelessWidget {
  final String password;

  const StrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    int strength = _calculateStrength();
    final bool isStrong = strength >= 5;
    final bool isMedium = strength >= 3 && strength < 5;

    final Color color = isStrong
        ? Colors.green
        : isMedium
        ? Colors.amber
        : Colors.red;

    final IconData icon = isStrong
        ? LucideIcons.shieldCheck
        : isMedium
        ? LucideIcons.shieldPlus
        : LucideIcons.shieldAlert;

    final String label = isStrong
        ? 'Strong password'
        : isMedium
        ? 'Medium password'
        : 'Weak password';

    final tooltip = isStrong
        ? "Your password is hard to crack!"
        : isMedium
        ? "Your password strength could be improved!"
        : "Your password is too weak. Consider changing it!";

    // Normalize progress between 0 and 1; maximum possible score is 6
    final double progress = (strength / 6).clamp(0.0, 1.0);

    return ShadTooltip(
      builder: (context) => Text(tooltip),
      child: Row(
        children: [
          Icon(icon, color: color, size: sizeL),
          const SizedBox(width: sizeXS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: ShadTheme.of(context).radius,
                  child: ShadProgress(
                    value: progress,
                    minHeight: sizeXS,
                    color: color,
                    backgroundColor: color.withAlpha((0.2 * 255).round()),
                  ),
                ),
                const SizedBox(height: sizeXS),
                Text(label, style: ShadTheme.of(context).textTheme.small.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStrength() {
    // Ignore whitespace characters from the calculation
    final pw = password.replaceAll(RegExp(r'\s+'), '');

    int score = 0;

    // Length checks (strictly longer than)
    if (pw.length > 8) score++;
    if (pw.length > 14) score++;

    // Character class checks
    if (RegExp(r'\d').hasMatch(pw)) score++; // has numbers
    if (RegExp(r'[a-z]').hasMatch(pw)) score++; // has lower case
    if (RegExp(r'[A-Z]').hasMatch(pw)) score++; // has upper case

    // Special character: anything that's not a letter or number
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) score++;

    return score;
  }
}
