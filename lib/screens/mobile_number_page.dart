import 'package:flutter/material.dart';
import 'spin_wheel_page.dart';

class MobileNumberPage extends StatefulWidget {
  const MobileNumberPage({super.key});

  @override
  State<MobileNumberPage> createState() => _MobileNumberPageState();
}

class _MobileNumberPageState extends State<MobileNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _mobileController.clear();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    Image.asset(
                      "assets/images/kmr_logo.png",
                      height: 100,
                    ),

                    const SizedBox(height: 20),

                    Image.asset(
                      "assets/images/anniversary_banner.png",
                      height: 70,
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "Enter Mobile Number",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "Enter Mobile Number",
                        hintStyle:
                        const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.phone_android,
                          color: Colors.amber,
                        ),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            !RegExp(r'^[6-9]\d{9}$')
                                .hasMatch(value)) {
                          return "Enter a valid 10-digit mobile number";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpinWheelPage(
                                mobileNumber:
                                _mobileController.text,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "CONTINUE",
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
        ),
      ),
    );
  }
}
