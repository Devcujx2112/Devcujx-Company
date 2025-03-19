import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:order_food/View/Page/Login/ForgotPasswordPage.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Login",
            style: TextStyle(
              fontSize: 50,
              fontFamily: "Outfit",
              fontWeight: FontWeight.bold,
              color: Color(0xFFD05558),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            decoration: InputDecoration(
              label: Text(
                "Email",
                style: TextStyle(
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              label: Text(
                "Password",
                style: TextStyle(
                    fontFamily: "Outfit",
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              suffixIcon: IconButton(
                  icon: Icon(
                    Icons.visibility_off,
                    color: Colors.black87,
                  ),
                  onPressed: () {}),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Remember me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                    activeColor: const Color(0xFFB02700),
                  ),
                  const Text(
                    "Remember me",
                    style: TextStyle(
                        fontFamily: "Outfit", fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                },
                child: const Text(
                  "Forgot Password ?",
                  style: TextStyle(
                      color: Colors.red, fontFamily: "Outfit", fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Nút đăng nhập
          ElevatedButton(
            onPressed: () {
              // Xử lý đăng nhập
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB02700),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              "Log In",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
