import 'dart:ui';
import 'package:flutter/material.dart';

class CongratulationsOverlay extends StatelessWidget {
  final String prize;
  final VoidCallback onContinue;

  const CongratulationsOverlay({
    super.key,
    required this.prize,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [

          /// Slight blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: .20),
              ),
            ),
          ),

          /// Bottom Card
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xff2C0A5A),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.amber,
                    width: 2,
                  ),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Image.asset(
                      "assets/images/kmr_logo.png",
                      height: 70,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "🎉 Congratulations!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "You Won",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      prize,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: onContinue,
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}