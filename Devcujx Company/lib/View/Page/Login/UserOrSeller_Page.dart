import 'package:flutter/material.dart';
import 'package:order_food/Services/Auth_Service.dart';
import 'package:order_food/View/Page/Profile/CreateProfileUser_Page.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:provider/provider.dart';

import '../Profile/CreateProfileSeller_Page.dart';

class UserOrSellerPage extends StatefulWidget {
  final String uid;

  const UserOrSellerPage({super.key, required this.uid});

  @override
  State<UserOrSellerPage> createState() => _UserOrSellerPageState();
}

class _UserOrSellerPageState extends State<UserOrSellerPage> {
  final AuthViewModel authViewModel = AuthViewModel();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/images/backgrUserSeller.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      bool success =
                          authVM.UpdateRoleVM("User", widget.uid);
                      if (success) {
                        Navigator.of(context, rootNavigator: true)
                            .pushReplacement(MaterialPageRoute(
                          builder: (context) => CreateProfileUser(),
                        ));
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 40),
                      side: const BorderSide(color: Colors.red, width: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: authVM.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Bạn là người mua hàng?",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                                fontFamily: "Outfit"),
                          ),
                  ),
                  const Text(
                    "or",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Outfit"),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      bool success =
                          authVM.UpdateRoleVM("Seller", widget.uid);
                      if (success) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => CreateProfileSeller()),
                        );
                      }
                      else{
                        showDialogMessage(context, "Chọn vai trò thất bại${authVM.errorMessage}",DialogType.error);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: authVM.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Bạn là người bán hàng..?",
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
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
