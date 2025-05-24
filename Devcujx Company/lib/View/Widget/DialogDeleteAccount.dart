import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:provider/provider.dart';

import '../Page/Login/Login_Page.dart';

class DialogDeleteAccount extends StatefulWidget {
  const DialogDeleteAccount({super.key});

  @override
  State<DialogDeleteAccount> createState() => _DialogDeleteAccountState();
}

class _DialogDeleteAccountState extends State<DialogDeleteAccount> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final bool _isLoading = false;
  final String _errorMessage = '';
  bool _hideOldPassword = true;

  String uid = "";

  @override
  void dispose() {
    _oldPasswordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_rounded, size: 32, color: Colors.orange),
        iconColor: Colors.orange.shade100,
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Xác nhận xóa tài khoản",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hành động này sẽ:"),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, size: 8),
                SizedBox(width: 8),
                Expanded(child: Text(" Xóa vĩnh viễn mọi dữ liệu cá nhân")),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, size: 8),
                SizedBox(width: 8),
                Expanded(child: Text(" Không thể khôi phục lại tài khoản")),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: const Text("Hủy"),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
            ),
            child: const Text("Xóa tài khoản"),
          ),
        ],
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  "Đang xóa tài khoản...",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
      try {
        final success = await authVM.DeleteAccount(_oldPasswordController.text, authVM.uid!);

        if (mounted) Navigator.pop(context);

        if (success) {
          showDialogMessage(context, "Xóa tài khoản thành công", DialogType.success);
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
            );
          }
        } else {
          showDialogMessage(context, "Xóa tài khoản thất bại: ${authVM.errorMessage}", DialogType.warning);
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Lỗi hệ thống"),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: _isLoading,
        progressIndicator:
            LoadingAnimationWidget.inkDrop(color: Colors.green, size: 40),
        child: AlertDialog(
          title: Center(
              child: const Text("Vui lòng nhập mật khẩu",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 20))),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: _hideOldPassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideOldPassword = !_hideOldPassword;
                            });
                          },
                          icon: Icon(_hideOldPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Xác nhận xóa tài khoản',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
