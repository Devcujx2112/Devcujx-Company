import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:order_food/View/Page/HomePage/AdminHome_Page.dart';
import 'package:order_food/View/Page/HomePage/SellerHome_Page.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/View/Widget/ForgotPassword_Form.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ViewModels/Auth_ViewModel.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController txt_email = TextEditingController();
  TextEditingController txt_pasword = TextEditingController();
  bool _valueAccount = false;
  bool _hidePassword = true;

  void SaveData() async {
    final SharedPreferences accountSave = await SharedPreferences.getInstance();
    await accountSave.setString("Email", txt_email.text);
    await accountSave.setString("Password", txt_pasword.text);
    await accountSave.setBool("CheckBox", _valueAccount);
  }

  void LoadData() async {
    final SharedPreferences accountSave = await SharedPreferences.getInstance();
    setState(() {
      txt_email.text = accountSave.getString("Email") ?? "";
      txt_pasword.text = accountSave.getString("Password") ?? "";
      _valueAccount = accountSave.getBool("CheckBox") ?? false;
    });
  }

  @override
  void initState() {
    LoadData();
    super.initState();
  }

  void CheckRoleAccount(String role) {
    if (role.toString() == "Admin") {
      Navigator.of(context, rootNavigator: true)
          .pushReplacement(MaterialPageRoute(
        builder: (context) => AdminHomePage(),
      ));
    } else if (role.toString() == "Seller") {
      Navigator.of(context, rootNavigator: true)
          .pushReplacement(MaterialPageRoute(
        builder: (context) => SellerHomePage(),
      ));
    } else if (role.toString() == "User") {
      Navigator.of(context, rootNavigator: true)
          .pushReplacement(MaterialPageRoute(
        builder: (context) => AdminHomePage(),
      ));
    }
  }

  void ForgotPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 210,
            ),
            child: ForgotPasswordForm(),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Login",
            style: TextStyle(
              fontSize: 40,
              fontFamily: "Outfit",
              fontWeight: FontWeight.bold,
              color: Color(0xFFD05558),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key("EmailLogin"),
            style: TextStyle(fontSize: 13, color: Colors.black),
            controller: txt_email,
            decoration: InputDecoration(
                label: Text(
                  "Email",
                  style: TextStyle(
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
          ),
          const SizedBox(height: 15),
          TextField(
            key: const Key("PasswordLogin"),
            style: TextStyle(fontSize: 13, color: Colors.black),
            controller: txt_pasword,
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
                      color: Colors.black87,size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _valueAccount,
                        onChanged: (value) {
                          setState(() {
                            _valueAccount = !_valueAccount;
                          });
                          SaveData();
                        },
                        activeColor: const Color(0xFFB02700),
                      ),
                      const Text(
                        "Remember me",
                        style: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 12,
                            color: Colors.grey),
                      ),
                    ],
                  )),
              TextButton(
                onPressed: () {
                  ForgotPassword(context);
                },
                child: const Text(
                  "Forgot Password ?",
                  style: TextStyle(
                      color: Colors.red, fontFamily: "Outfit", fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          authVM.isLoading
              ? SizedBox(
                  height: 30,
                  width: 30,
                  child:
                      CircularProgressIndicator(color: const Color(0xFFB02700)),
                )
              : ElevatedButton(
            key: Key("ButtonLogin"),
                  onPressed: () async {
                    bool success =
                        await authVM.LoginVM(txt_email.text, txt_pasword.text);
                    if (success) {
                      String? role = authVM.role;
                      CheckRoleAccount(role!);
                      showDialogMessage(
                          context, "Đăng nhập thành công", DialogType.success);
                    } else {
                      showDialogMessage(
                          context, "${authVM.errorMessage}", DialogType.error);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB02700),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 10),
                  ),
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
    );
  }
}
