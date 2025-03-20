import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogMessageForm extends StatefulWidget {
  String message;
  DialogMessageForm({super.key, required this.message});

  @override
  State<DialogMessageForm> createState() => _DialogMessageFormState();
}

class _DialogMessageFormState extends State<DialogMessageForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Thông báo",
          style: TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w600,
            fontSize: 30,
            color: Color(0xFFD05558),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.message,
          style: TextStyle(
              fontFamily: "Poppins",
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14),
        ),
      ],
    );
  }
}
