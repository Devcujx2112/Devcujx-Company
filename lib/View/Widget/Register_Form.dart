import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:order_food/Services/Auth_Service.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:provider/provider.dart';

import '../Page/Login/UserOrSeller_Page.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController againPass = TextEditingController();

  bool _hidePassword = true;
  bool _hidePasswordAgain = true;

  void DialogMessage(BuildContext context, message, uid,
      {bool isSuccess = false}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            if (isSuccess) {
              Navigator.of(context, rootNavigator: true).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => UserOrSellerPage(
                          uid: uid,
                        )),
              );
            }
          }
        });
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: IntrinsicHeight(
            child: DialogMessageForm(message: message),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

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
            controller: email,
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
            controller: password,
            obscureText: _hidePassword,
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
                    _hidePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  }),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: againPass,
            obscureText: _hidePasswordAgain,
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
                    _hidePasswordAgain
                        ? Icons.visibility_off_rounded
                        : Icons.visibility,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    setState(() {
                      _hidePasswordAgain = !_hidePasswordAgain;
                    });
                  }),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: authVM.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      bool success = await authVM.RegisterVM(
                          email.text, password.text, againPass.text);
                      String uidAccount = authVM.uid.toString();
                      print('uid form $uidAccount');
                      if (success) {
                        DialogMessage(
                            context,
                            "Đăng kí thành công",
                            isSuccess: true,
                            uidAccount);
                      } else {
                        DialogMessage(context, authVM.errorMessage, uidAccount,
                            isSuccess: false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB02700),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text(
                      "Comfirm",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Outfit"),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
