import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class OrderSellerScreen extends StatefulWidget {
  const OrderSellerScreen({super.key});

  @override
  State<OrderSellerScreen> createState() => _OrderSellerScreenState();
}

class _OrderSellerScreenState extends State<OrderSellerScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Đơn hàng"),
          ),
        ));
  }
}
