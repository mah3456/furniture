// lib/presentation/widgets/theme_toggle_with_feedback.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class ThemeToggleWithFeedback extends ConsumerWidget {
  final bool showSnackBar;

  const ThemeToggleWithFeedback({Key? key, this.showSnackBar = true}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return IconButton(
      onPressed: () {
        themeNotifier.toggleTheme();
        
        // if (showSnackBar) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Row(
        //         children: [
        //           Icon(
        //             isDarkMode ? Icons.light_mode : Icons.dark_mode,
        //             color: Colors.white,
        //           ),
        //           const SizedBox(width: 12),
        //           Text(
        //             isDarkMode ? 'تم التبديل إلى الوضع الفاتح' : 'تم التبديل إلى الوضع الداكن',
        //             style: const TextStyle(color: Colors.white),
        //           ),
        //         ],
        //       ),
        //       backgroundColor: isDarkMode ? Colors.grey[800] : Colors.blue.shade700,
        //       behavior: SnackBarBehavior.floating,
        //       duration: const Duration(seconds: 2),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //   );
        // }
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey<bool>(isDarkMode),
          color: isDarkMode ? Colors.amber.shade300 : Colors.blue.shade700,
          size: 28,
        ),
      ),
      tooltip: isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
    );
  }
}