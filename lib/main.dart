import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

///Entry point of the Flutter application and Flutter starts execution from main(). runApp() loads the root widget. [MyApp]
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget { ///Stateful Widget because UI changes happens when User spins wheel and result window show
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpinWheelPage(), ///First screen shown to user.
    );
  }
}

class SpinWheelPage extends StatefulWidget {
  const SpinWheelPage({super.key});

  @override
  State<SpinWheelPage> createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage> ///Wheel logic, Animations, Reward logic, UI updates
    with SingleTickerProviderStateMixin {
  final StreamController<int> controller = StreamController<int>();  ///Controls the wheel spinning.

  late AnimationController _controller; ///Controls logo swinging.
  late Animation<double> _swingAnimation; ///Creates motion: Left → Right → Left

  final List<String> segmentTexts = [
    "50%",
    "₹100",
    "10%",
    "₹200",
    "15%",
    "₹300",
    "20%",
    "COUPON",
    "30%",
    "25%",
  ];

  final List<String> segmentEmojis = [
    "🎉",
    "💰",
    "🎊",
    "💰",
    "🤩",
    "💰",
    "🎁",
    "💰",
    "🔥",
    "🥳",
  ];
  int spinCount = 0;
  String result = "";
  int? winningIndex;
  bool isSpinning = false;
  bool showHighlight = false;
  late ConfettiController _confettiController;
  final AudioPlayer _spinSoundPlayer = AudioPlayer();


  Color _dimColor(Color color) {
    // blends the segment color 55% toward black to visually "dim" it
    return Color.alphaBlend(Colors.black.withOpacity(0.55), color);
  }

  @override
  void initState() { ///Runs once when screen loads.
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5), // how long particles keep emitting
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); ///Left ↔ Right continuous movement.

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
  // int getRewardIndex() {
  //   int random = Fortune.randomInt(1, 101);
  //
  //   if (random <= 3) {
  //     return items.indexOf("Get 50%");
  //   } else if (random <= 8) {
  //     return items.indexOf("Gift Card");
  //   } else if (random <= 18) {
  //     return items.indexOf("Get 30%");
  //   } else if (random <= 30) {
  //     return items.indexOf("Get 20%");
  //   } else if (random <= 42) {
  //     return items.indexOf("Flat ₹300");
  //   } else if (random <= 55) {
  //     return items.indexOf("Get 15%");
  //   } else if (random <= 68) {
  //     return items.indexOf("Flat ₹200");
  //   } else if (random <= 80) {
  //     return items.indexOf("Get 10%");
  //   } else if (random <= 90) {
  //     return items.indexOf("Flat ₹100");
  //   } else if (random <= 95) {
  //     return items.indexOf("Try Again");
  //   } else {
  //     return items.indexOf("Get 5%");
  //   }
  // }

  void spinWheel() {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
      showHighlight = false; // make sure previous highlight is cleared
    });

    spinCount++;
    final selected = getRewardIndex();
    setState(() {
      winningIndex = selected;
    });
    controller.add(selected);

    debugPrint("Spin #$spinCount");
    debugPrint("Selected Index: $selected");
    debugPrint("Reward: ${segmentTexts[selected]}");

    log("Reward: ${segmentTexts[selected]}", name: "KMR_SPIN");
    _spinSoundPlayer.play(AssetSource('audio/western_spin.mp3'));

    Future.delayed(const Duration(seconds: 4), () {
      final prize = segmentTexts[selected];
      _spinSoundPlayer.stop();
      setState(() {
        winningIndex = selected;
        result = prize;
        showHighlight = true;
      });

      _confettiController.play(); // NEW — start crackers animation

      Future.delayed(const Duration(seconds: 2), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => PopScope(
            canPop: false,
            child: AlertDialog(
              backgroundColor: Colors.lightGreen,
              title: const Text(
                "Congratulations 🎉",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              content: Text(
                "You won $prize",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confettiController.stop(); // NEW — stop crackers when OK tapped
                    setState(() {
                      result = "";
                      isSpinning = false;
                      showHighlight = false;
                    });
                  },
                  child: const Text("OK"),
                )
              ],
            ),
          ),
        );
      });
    });
  }

  @override
  void dispose() { ///Cleanup. to prevent memory leaks.
    _controller.dispose();
    _confettiController.dispose();
    _spinSoundPlayer.dispose(); // NEW
    super.dispose();

  }

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
                  AnimatedBuilder(
                    animation: _swingAnimation,
                    builder: (context, child) {
                      return Transform.rotate( ///Rotates logo. Creates swinging effect.
                        angle: _swingAnimation.value,
                        alignment: Alignment.topCenter,
                        child: child,
                      );
                    },
                  ),

                  const SizedBox(width: 12),

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

                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),

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
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFF176),
                            Color(0xFFFFD700),
                            Color(0xFFFFA000),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.brown,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(.6),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "SPIN",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
}

/*
App Opens
     ↓
Logo Swinging
     ↓
User clicks SPIN NOW
     ↓
Random reward selected
     ↓
controller.add(index)
     ↓
Wheel rotates
     ↓
4 sec wait
     ↓
Result stored
     ↓
Dialog shown
     ↓
User clicks OK
     ↓
Ready for next spin
 */