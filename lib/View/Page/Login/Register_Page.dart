import 'package:flutter/material.dart';
import 'package:order_food/View/Page/Login/Login_Page.dart';
import 'package:order_food/View/Widget/Login_Form.dart';
import 'package:order_food/View/Widget/Register_Form.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(bottom: 70),
                  color: const Color(0xFFD05558),
                  child: Center(
                    child: Image.asset(
                      'asset/images/logo.png',
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50, left: 30, right: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RegisterForm(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 12,
                            color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontFamily: "Outfit"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
