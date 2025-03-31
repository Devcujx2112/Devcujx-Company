import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModels/Auth_ViewModel.dart';
import 'DialogMessage_Form.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  TextEditingController txt_email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

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
              fontFamily: "Poppins",
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: txt_email,
          style: TextStyle(fontSize: 13, color: Colors.black),
          decoration: InputDecoration(
            hintText: "Enter your email",
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 20),
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
                        fontSize: 13),
                  ),
                )),
            authVM.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      bool success =
                          await authVM.ForgotPassword(txt_email.text);
                      if (success) {
                        Navigator.pop(context);
                        showDialogMessage(
                            context,
                            "Vui lòng kiểm tra Email của bạn",
                            DialogType.success);
                      } else {
                        showDialogMessage(context, "${authVM.errorMessage}",
                            DialogType.warning);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB02700),
                    ),
                    child: Text(
                      "Gửi yêu cầu",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13),
                    ),
                  ),
          ],
        )
      ],
    );
  }
}
