import 'dart:async';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import '../data/wheel_data.dart';
import '../services/reward_service.dart';
import '../widgets/result_dialog.dart';

// ===========================
// SPIN WHEEL PAGE WIDGET
// ===========================

class SpinWheelPage extends StatefulWidget {
  const SpinWheelPage({super.key});

  @override
  State<SpinWheelPage> createState() => _SpinWheelPageState();
}

// ===========================
// PAGE STATE
// ===========================

class _SpinWheelPageState extends State<SpinWheelPage>
    with SingleTickerProviderStateMixin {

  // ===========================
  // VARIABLES
  // ===========================
  int countdown = 0;
  int spinCount = 0;
  String result = "";

  int? winningIndex;

  bool isSpinning = false;
  bool showHighlight = false;


  final StreamController<int> controller =
  StreamController<int>();

  late AnimationController _controller;
  late Animation<double> _swingAnimation;

  late ConfettiController _confettiController;

  final AudioPlayer _spinSoundPlayer =
  AudioPlayer();

  // ===========================
  // INIT STATE
  // ===========================

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _swingAnimation = Tween<double>(
      begin: -0.08,
      end: 0.08,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  // ===========================
  // OTHER METHODS
  // ===========================

  Future<void> spinWheel() async {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
      showHighlight = false;
      result = "";
    });

    spinCount++;
    int selected;


    try {
      final rewardFuture = RewardService.getRewardIndexFromSheet(
        segmentTexts,
        getRewardIndex,
      );

      final countdownFuture = startCountdown();

      await Future.wait([
        rewardFuture,
        countdownFuture,
      ]);
      selected = await rewardFuture;
    } catch (e) {
      debugPrint("API FAILED: $e");
      selected = getRewardIndex();
    }

    // Safety check
    if (selected < 0 || selected >= segmentTexts.length) {
      debugPrint("Invalid index received: $selected");
      selected = getRewardIndex();
    }

    debugPrint(
        "FINAL REWARD = ${segmentTexts[selected]}");
    debugPrint(
        "FINAL INDEX = $selected");

    setState(() {
      winningIndex = selected;
    });

    debugPrint(
        "Wheel Will Stop At = ${segmentTexts[selected]}");

    // Start wheel FIRST
    controller.add(selected);

    // Start sound together with wheel
    _spinSoundPlayer.stop();
    _spinSoundPlayer.play(
      AssetSource('audio/western_spin.mp3'),
    );

    await Future.delayed(
      const Duration(seconds: 5),
    );

    if (!mounted) return;

    await _spinSoundPlayer.stop();

    final prize = segmentTexts[selected];

    setState(() {
      result = prize;
      showHighlight = true;
    });

    _confettiController.play();

    if (!mounted) return;

    await ResultDialog.show(
      context,
      prize,
          () {
        Navigator.pop(context);

        _confettiController.stop();

        setState(() {
          result = "";
          isSpinning = false;
          showHighlight = false;
        });
      },
    );
  }

  int getRewardIndex() {
    int random = Fortune.randomInt(1, 101);

    if (random <= 3) {
      return 0; // 🎉 50%
    } else if (random <= 8) {
      return 7; // 🎫 Card
    } else if (random <= 18) {
      return 8; // 🔥 30%
    } else if (random <= 30) {
      return 6; // 🎁 20%
    } else if (random <= 42) {
      return 5; // 💸 ₹300
    } else if (random <= 55) {
      return 4; // 😍 15%
    } else if (random <= 68) {
      return 3; // 💰 ₹200
    } else if (random <= 80) {
      return 2; // 🎊 10%
    } else if (random <= 90) {
      return 1; // 💵 ₹100
    } else if (random <= 95) {
      return 9; // 🔄 Retry
    } else {
      return 1; // 💵 ₹100 (or another reward)
    }

  }

  Future<void> startCountdown() async {
    for (int i = 4; i >= 1; i--) {
      if (!mounted) return;

      setState(() {
        countdown = i;
      });

      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;

    setState(() {
      countdown = 0;
    });
  }



  // ===========================
  // DISPOSE
  // ===========================

  @override
  void dispose() {
    controller.close();

    _controller.dispose();
    _confettiController.dispose();
    _spinSoundPlayer.dispose();

    super.dispose();
  }

  // ===========================
  // BUILD UI
  // ===========================

  @override
  Widget build(BuildContext context) {
    return Scaffold( ///Main page structure. Screen Layout Material design behavior
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF14003D),
              Color(0xFF22005B),
              Color(0xFF070021),
            ],
          ),
        ),
        child: SafeArea(
          child: Column( ///Places widgets vertically. Logo , Wheel, Result, Button
            children: [

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      AnimatedBuilder(
                        animation: _swingAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _swingAnimation.value,
                            alignment: Alignment.topCenter,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'assets/images/kmr_logo.png',
                          height: 80,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

// ===========================
// ANNIVERSARY CRAWLER HERE
// ===========================
              Container(
                height: 60,
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/anniversary_banner.png',
                    height: 60,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Stack( ///Places widgets on top of each other.,  Glow, Border, Wheel, Center, Button
                  alignment: Alignment.center,
                  children: [

                    // Gold outer glow
                    Container(
                      width: 360,
                      height: 360,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(.8),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    // Gold border ring
                    Container(
                      width: 330,
                      height: 330,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all( /// Border Ring [Golden outer ring.]
                          color: Colors.amber,
                          width: 12,
                        ),
                      ),
                    ),

                    FortuneWheel( ///Main spinning wheel. Listens to: controller.add(index)
                      selected: controller.stream,
                      animateFirst: false,
                      /// Arrow pointer. Shows winning position.
                      indicators: [
                        FortuneIndicator(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFF176),
                                  Color(0xFFFFD700),
                                  Color(0xFFFFA000),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF7B1FA2),
                              size: 40,
                            ),
                          ),
                        ),
                      ],

                      items: [
                        for (int index = 0; index < segmentTexts.length; index++)
                              () {
                            final bool isWinner = showHighlight && index == winningIndex;
                            final bool shouldDim = showHighlight && !isWinner;

                            final Color baseColor = index.isEven
                                ? const Color(0xFFFF8C00) // Dark Orange
                                : const Color(0xFF5B0FB8); // Purple

                            final Color segmentColor = shouldDim ? _dimColor(baseColor) : baseColor;

                            return FortuneItem(
                              style: FortuneItemStyle(
                                color: segmentColor,
                                borderColor: isWinner ? Colors.white : Colors.black,
                                borderWidth: isWinner ? 5 : 1,
                              ),
                              child: Opacity(
                                opacity: shouldDim ? 0.45 : 1.0, // dim text+emoji too
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 50),
                                    Text(
                                      segmentTexts[index],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isWinner ? Colors.yellowAccent : Colors.white,
                                      ),
                                    ),
                                    Text(
                                      segmentEmojis[index],
                                      style: TextStyle(fontSize: isWinner ? 36 : 30),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }(),
                      ],
                    ),

                    /// Center SPIN button Placed in center of wheel. Acts as decorative center cap.
                    Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amber,
                            width: 4,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.amber,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: countdown > 0
                            ? Center(
                          child: Text(
                            "$countdown",
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                            : ClipOval(
                          child: Image.asset(
                            'assets/images/kmr_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Confetti overlay — rendered last so it's on top
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirection: math.pi / 2,
                        maxBlastForce: 20,
                        minBlastForce: 8,
                        emissionFrequency: 0.05,
                        numberOfParticles: 30,
                        gravity: 0.3,
                        shouldLoop: false,
                        colors: const [
                          Colors.orange,
                          Colors.purple,
                          Colors.amber,
                          Colors.green,
                          Colors.pink,
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isSpinning ? null : spinWheel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSpinning ? Colors.grey : Colors.orange, // button background
                  foregroundColor: Colors.purple, // text color
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  isSpinning ? "SPINNING..." : "SPIN NOW",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple, // explicit, in case foregroundColor gets overridden by theme
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Color _dimColor(Color color) {
    return Color.alphaBlend(
      Colors.black.withOpacity(0.55),
      color,
    );
  }
}