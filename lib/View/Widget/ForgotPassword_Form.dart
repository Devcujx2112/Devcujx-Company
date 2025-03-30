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

  void DialogMessage(BuildContext context, message,) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: IntrinsicHeight(
            child: DialogMessageForm(message: message,intValue: Color(0xFFD05558),),
          ),
        );
      },
    );
  }

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
              fontSize: 14),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: txt_email,
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
            authVM.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async{
                      bool success = await authVM.ForgotPassword(txt_email.text);
                      if(success){
                        DialogMessage(context,"Vui lòng kiểm tra Email của bạn");
                      }
                      else{
                        DialogMessage(context,authVM.errorMessage);
                      }
                    },
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
