import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogMessageForm extends StatefulWidget {
  String message;
  Color intValue;
  DialogMessageForm({super.key, required this.message,required this.intValue});

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
            color: widget.intValue,
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
