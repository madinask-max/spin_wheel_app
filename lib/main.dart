import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _SpinWheelPageState extends State<SpinWheelPage> {
  final StreamController<int> controller = StreamController<int>();

  final List<String> items = [
    "10%",
    "20%",
    "50%",
    "Flat ₹50",
    "Try Again",
    "Gift Card",
    "Free Spin",

  ];

  String result = "";

  void spinWheel() {
    final selected = Fortune.randomInt(0, items.length);
    controller.add(selected);
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
    controller.close();
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

              Text(
                "Lucky Spin",
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                child: FortuneWheel(
                  selected: controller.stream,
                  animateFirst: false,

                  indicators: [
                    FortuneIndicator(
                      alignment: Alignment.topCenter,
                      child: Transform.translate(
                        offset: const Offset(0, 20), // move down toward wheel
                        // for move up it should be offset: const Offset(0, -20)
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      ),
                    ),
                  ],

                  items: [
                    for (var item in items)
                      FortuneItem(
                        style: FortuneItemStyle(
                          color: Color(0xFF2563EB),
                          borderColor: Color(0xFFFFD700),
                          borderWidth: 2,
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
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