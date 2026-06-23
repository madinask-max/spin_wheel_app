import 'package:flutter/material.dart';

class ResultDialog {

  static Future<void> show(
      BuildContext context,
      String prize,
      VoidCallback onOk,
      ) {

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor:
          Colors.lightGreen,
          title: const Text(
            "Congratulations 🎉",
          ),
          content:
          Text("You won $prize"),
          actions: [
            ElevatedButton(
              onPressed: onOk,
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}