import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:marquee/marquee.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  Future<int> getRewardIndexFromSheet() async {
    try {
      const apiUrl ='https://script.google.com/macros/s/AKfycbxK2bAGDPwGLFU4JJ2QApLdxp042Sqbq6yM1GI65B_5hgN-ZH-MWA6dmoyuF8P7uvtFrg/exec';
      print("Request URL: $apiUrl");
      final response = await http.get(Uri.parse(apiUrl));

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Final URL: ${response.request?.url}");
      debugPrint("Response Body: ${response.body}");


      final data = jsonDecode(response.body);


      debugPrint("================================");
      debugPrint("API RESPONSE = ${response.body}");
      debugPrint("API REWARD = ${data['reward']}");
      print("RAW TYPE = ${data['reward'].runtimeType}");
      debugPrint("================================");

      final reward = data['reward'];
      debugPrint("================================");
      debugPrint("RAW REWARD = $reward");
      debugPrint("RAW TYPE = ${reward.runtimeType}");
      debugPrint("================================");
      String rewardText;

      switch (reward.toString().trim()) {
        case "0.1":
        case "10":
        case "10%":
          rewardText = "10%";
          break;

        case "0.15":
        case "15":
        case "15%":
          rewardText = "15%";
          break;

        case "0.2":
        case "20":
        case "20%":
          rewardText = "20%";
          break;

        case "0.25":
        case "25":
        case "25%":
          rewardText = "25%";
          break;

        case "0.3":
        case "30":
        case "30%":
          rewardText = "30%";
          break;

        case "0.5":
        case "50":
        case "50%":
          rewardText = "50%";
          break;

        default:
          rewardText = reward.toString();
      }

      final index = segmentTexts.indexOf(rewardText);

      debugPrint("API Reward = $reward");
      debugPrint("Mapped Reward = $rewardText");
      debugPrint("Index = $index");

      debugPrint("Mapped Reward = $rewardText");
      debugPrint("Wheel Index = $index");

      if (index == -1) {
        debugPrint(
            "Reward not found on wheel. Falling back.");
        return getRewardIndex();
      }

      return index;
    } catch (e) {
      debugPrint("API ERROR: $e");

      return getRewardIndex(); // fallback to old logic
    }
  }
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
      selected = await getRewardIndexFromSheet();
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

    await _spinSoundPlayer.stop();

    final prize = segmentTexts[selected];

    setState(() {
      result = prize;
      showHighlight = true;
    });

    _confettiController.play();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.lightGreen,
        title: const Text("Congratulations 🎉"),
        content: Text("You won $prize"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              _confettiController.stop();

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
    );
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
                        child: ClipOval(
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
}

// class AnniversaryBanner extends StatefulWidget {
//   const AnniversaryBanner({super.key});
//
//   @override
//   State<AnniversaryBanner> createState() =>
//       _AnniversaryBannerState();


// class _AnniversaryBannerState
//     extends State<AnniversaryBanner>
//     with SingleTickerProviderStateMixin {
//   late AnimationController controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//     controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 12),
//     )..repeat();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 60,
//       child: AnimatedBuilder(
//         animation: controller,
//         builder: (context, child) {
//           return Transform.translate(
//             offset: Offset(
//               -1200 * controller.value,
//               0,
//             ),
//             child: Row(
//               children: [
//                 Image.asset(
//                   'assets/images/anniversary_banner.png',
//                   height: 60,
//                 ),
//                 const SizedBox(width: 30),
//                 Image.asset(
//                   'assets/images/anniversary_banner.png',
//                   height: 60,
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }

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