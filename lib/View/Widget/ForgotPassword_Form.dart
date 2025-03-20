import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Forgot Password",
          style: TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFFD05558),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Please enter your email to receive a password reset link.",
          style: TextStyle(
              fontFamily: "Poppins",color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: "Enter your email",
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
                padding: EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Hủy",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD05558),
                        fontSize: 14),
                  ),
                )),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                "Gửi yêu cầu",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD05558),
                    fontSize: 14),
              ),
            ),
          ],
        )
      ],
    );
  }
}
