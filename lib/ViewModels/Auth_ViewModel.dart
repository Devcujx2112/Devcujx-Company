import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Services/Auth_Service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> register(String email, String password, String againPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if(email.isEmpty || password.isEmpty || againPassword.isEmpty){
      _isLoading = false;
      _SetError("Hãy điền đầy đủ các trường");
      return false;
    }

    if (!email.contains('@')) {
      _SetError("Email không hợp lệ");
      return false;
    }

    if (password.length < 6) {
      _SetError("Mật khẩu phải có ít nhất 6 ký tự");
      return false;
    }

    if(password.toString() != againPassword.toString()){
      _isLoading = false;
      _SetError("Mật khẩu không trùng khớp");
      return false;
    }

    try {
      final user = await _authService.register(email, password);
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _SetError("Đăng ký thất bại: ${e.toString()}");
      return false;
    }
  }

  void _SetError(String message){
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }

}

