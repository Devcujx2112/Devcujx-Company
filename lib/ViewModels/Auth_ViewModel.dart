import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:order_food/Models/Account.dart';
import '../Services/Auth_Service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _uid;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get uid => _uid;

  Future<bool> RegisterVM(String email, String password, String againPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.isEmpty || password.isEmpty || againPassword.isEmpty) {
      _isLoading = false;
      _SetError("Hãy điền đầy đủ các trường");
      return false;
    }

    bool isValidEmail(String email) {
      String emailPattern =
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
      RegExp regex = RegExp(emailPattern);
      return regex.hasMatch(email);
    }

    if (!isValidEmail(email)) {
      _SetError("Email không hợp lệ");
      return false;
    }

    if (password.length < 6) {
      _SetError("Mật khẩu phải có ít nhất 6 ký tự");
      return false;
    }

    if (password.toString() != againPassword.toString()) {
      _isLoading = false;
      _SetError("Mật khẩu không trùng khớp");
      return false;
    }

    try {
      final user = await _authService.RegisterService(email, password);
      if (user == null) {
        print("Không tìm thấy uid tài khoản hiện tại.");
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _uid = user.uid;

      String createAt = DateTime.now().toIso8601String();
      Account account = Account(_uid!,email,"","Active",createAt);
      await _authService.AddAccountService(account);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Đăng ký thất bại: ${e.toString()}");
      return false;
    }
  }

  void UpdateRoleVM(String role, String uid) {
    _isLoading = true;
    try{
      if (role.isNotEmpty && uid.isNotEmpty){
        _authService.UpdateRoleUserService(uid, role);
        _isLoading = false;
      }
    }catch(e){
      print(e);
    }
  }

  void _SetError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
}

