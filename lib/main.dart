import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpinWheelPage(),
    );
  }
}

class SpinWheelPage extends StatefulWidget {
  const SpinWheelPage({super.key});

  @override
  State<SpinWheelPage> createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage>
    with SingleTickerProviderStateMixin {
  final StreamController<int> controller = StreamController<int>();

  late AnimationController _controller;
  late Animation<double> _swingAnimation;

  final List<String> items = [
    "Get 5%",
    "Flat ₹100",
    "Get 10%",
    "Flat ₹200",
    "Get 15%",
    "Flat ₹300",
    "Get 20%",
    "Gift Card",
    "Get 30%",
    "Try Again",
    "Get 50%",
  ];
  int spinCount = 0;
  String result = "";

  @override
  void initState() {
    super.initState();

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

  int getRewardIndex() {
    int random = Fortune.randomInt(1, 101);

    if (random <= 3) {
      return items.indexOf("Get 50%");
    } else if (random <= 8) {
      return items.indexOf("Gift Card");
    } else if (random <= 18) {
      return items.indexOf("Get 30%");
    } else if (random <= 30) {
      return items.indexOf("Get 20%");
    } else if (random <= 42) {
      return items.indexOf("Flat ₹300");
    } else if (random <= 55) {
      return items.indexOf("Get 15%");
    } else if (random <= 68) {
      return items.indexOf("Flat ₹200");
    } else if (random <= 80) {
      return items.indexOf("Get 10%");
    } else if (random <= 90) {
      return items.indexOf("Flat ₹100");
    } else if (random <= 95) {
      return items.indexOf("Try Again");
    } else {
      return items.indexOf("Get 5%");
    }
  }

  void spinWheel() {

    spinCount++;
    final selected = getRewardIndex();
    controller.add(selected);

    // debugPrint("Spin #$spinCount");
    // debugPrint("Selected Index: $selected");
    // debugPrint("Reward: ${items[selected]}");
    debugPrint("Spin #$spinCount - Reward: ${items[selected]}");

    print("+++++++++++++++++++++++++");
    print("SPIN STARTED");
    log(
      "Reward: ${items[selected]}",
      name: "KMR_SPIN",
    );
    Future.delayed(const Duration(seconds: 4), () {

      final prize = items[selected];

      setState(() {
        result = prize;
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Congratulations 🎉"),
          content: Text("You won $prize"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  result = "";
                });
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff1E3A8A),
              Color(0xff111827),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    // child: Column(
                    //   children: [
                    //     Container(
                    //       width: 2,
                    //       height: 20,
                    //       color: Colors.white70,
                    //     ),
                    //     Container(
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 12,
                    //         vertical: 6,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         gradient: const LinearGradient(
                    //           colors: [
                    //             Color(0xFFFFF176),
                    //             Color(0xFFFFD700),
                    //             Color(0xFFFFA000),
                    //           ],
                    //         ),
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       child: Text(
                    //         "KMR's",
                    //         style: GoogleFonts.poppins(
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),

                  const SizedBox(width: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          height: 70,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        "Lucky Spin",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Container(
              //   margin: const EdgeInsets.symmetric(horizontal: 20),
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(.15),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              // ),

              // const SizedBox(height: 30),

              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    // Gold outer glow
                    Container(
                      width: 340,
                      height: 340,
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
                        border: Border.all(
                          color: Colors.amber,
                          width: 12,
                        ),
                      ),
                    ),

                    FortuneWheel(
                      selected: controller.stream,
                      animateFirst: false,

                      indicators: const [
                        FortuneIndicator(
                          alignment: Alignment.topCenter,
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: 70,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ],

                      items: [
                        for (int index = 0; index < items.length; index++)
                          FortuneItem(
                            style: FortuneItemStyle(
                              color: index.isEven
                                  ? Color(0xFFFFEB3B)
                                  : Color(0xFF1565C0),
                              borderColor: Colors.black,
                              borderWidth: 1,
                            ),
                            child: Text(
                              items[index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Center SPIN button
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  result.isEmpty
                      ? "Press Spin To Win"
                      : "Congratulations! You Won $result",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: spinWheel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "SPIN NOW",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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