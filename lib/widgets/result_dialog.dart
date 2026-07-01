import 'package:flutter/material.dart';
import '../widgets/congratulation_overlay.dart';

class ResultDialog {
  static Future<void> show(
      BuildContext context,
      String prize,
      VoidCallback onOk,
      ) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),

      pageBuilder: (_, __, ___) {
        return CongratulationsOverlay(
          prize: prize,
          onContinue: onOk,
        );
      },

      transitionBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}