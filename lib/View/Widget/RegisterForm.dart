import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Page/Login/UserOrSellerPage.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 10, left: 20, right: 20, bottom: 20),
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
            "Sign Up",
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
                    Icons.visibility_off_rounded,
                    color: Colors.black87,
                  ),
                  onPressed: (){}),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            obscureText: true,
            decoration: InputDecoration(
              label: Text(
                "Reenter password",
                style: TextStyle(
                    fontFamily: "Outfit",
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              suffixIcon: IconButton(
                  icon: Icon(
                    Icons.visibility_off_rounded,
                    color: Colors.black87,
                  ),
                  onPressed: (){}),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserOrSellerPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB02700),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))
              ),
              child: const Text(
                "Comfirm",
                style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold,fontFamily: "Outfit"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
