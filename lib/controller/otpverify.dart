import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:profluenceadmin/nav.dart';

class Otpadmincheck extends StatefulWidget {
  const Otpadmincheck({super.key});

  @override
  State<Otpadmincheck> createState() => _OtpadmincheckState();
}

class _OtpadmincheckState extends State<Otpadmincheck> {
  final TextEditingController _accesscode = TextEditingController();
  String error = "";
  bool loading = false;

  @override
  void dispose() {
    _accesscode.dispose();
    super.dispose();
  }

  int generateRandomOTP() {
    final random = Random();
    return 100000 +
        random.nextInt(900000); // Generates a number between 100000 and 999999
  }

  Future<void> getAccessCode() async {
    setState(() {
      loading = true;
    });
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('otp').get();

      bool isValid = false;

      for (var doc in snapshot.docs) {
        var accessCodeFromFirestore = doc['otp'];
        if (_accesscode.text == accessCodeFromFirestore) {
          isValid = true;
          break;
        }
      }

      if (isValid && mounted) {
        // Stop any loading before navigation
        setState(() {
          loading = false;
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SideNavigation()),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          error = "No access match, please try again.";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Theres an error Please try again.";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image.png'), // Your background image
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Center(
            child: Card(
              elevation: 10,
              color: Colors.white,
              child: SizedBox(
                width: 300,
                height: 250,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        const Text(
                          'One Time Code sent to your email',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _accesscode,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Enter 6 diget code',
                            hintStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        loading == false
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff1A1F32),
                                ),
                                onPressed: () {
                                  getAccessCode();
                                },
                                child: const Text(
                                  "Continue",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(
                          textAlign: TextAlign.center,
                          error,
                          style:
                              const TextStyle(fontSize: 13, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
