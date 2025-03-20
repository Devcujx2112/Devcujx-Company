import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Login_Page.dart';
import 'Register_Page.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'asset/images/backgrFirstPage.png',
            fit: BoxFit.cover,
          ),

          Column(
            children: [
              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 50),
                        side: const BorderSide(color: Color(0xFFB02700), width: 3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFB02700)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "or",
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 30),
                        backgroundColor: const Color(0xFFB02700),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Create an account",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Outfit",
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
