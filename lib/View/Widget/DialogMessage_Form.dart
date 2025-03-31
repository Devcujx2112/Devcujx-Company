import 'package:flutter/material.dart';

/// Enum đại diện cho 3 trạng thái của thông báo
enum DialogType { warning, success, error }

void showDialogMessage(BuildContext context, String message, DialogType type) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 2), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: IntrinsicHeight(
          child: DialogMessageForm(message: message, type: type),
        ),
      );
    },
  );
}

class DialogMessageForm extends StatelessWidget {
  final String message;
  final DialogType type;

  const DialogMessageForm({super.key, required this.message, required this.type});

  /// Hàm lấy màu sắc dựa vào trạng thái
  Color get _color {
    switch (type) {
      case DialogType.warning:
        return Colors.orange;
      case DialogType.success:
        return Colors.green;
      case DialogType.error:
        return Colors.red;
    }
  }

  /// Hàm lấy icon tương ứng với trạng thái
  IconData get _icon {
    switch (type) {
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.success:
        return Icons.check_circle_outline;
      case DialogType.error:
        return Icons.cancel_outlined;
    }
  }

  /// Hàm lấy tiêu đề tương ứng với trạng thái
  String get _title {
    switch (type) {
      case DialogType.warning:
        return "Cảnh báo";
      case DialogType.success:
        return "Hoàn thành";
      case DialogType.error:
        return "Từ chối";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(_icon, color: _color, size: 50),
        const SizedBox(height: 10),
        Text(
          _title,
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: _color,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "Poppins",
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
