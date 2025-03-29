import 'dart:async';

import 'package:flutter/material.dart';
import 'package:order_food/Helpers/ValidateInput.dart';
import 'package:order_food/Models/Account.dart';
import '../Services/Auth_Service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ValidateInput _validateInput = ValidateInput();

  bool _isLoading = false;
  String? _errorMessage;
  String? _uid;
  String? _role;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get uid => _uid;

  String? get role => _role;


  Future<bool> RegisterVM(String email, String password,
      String againPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.isEmpty || password.isEmpty || againPassword.isEmpty) {
      _isLoading = false;
      _SetError("Hãy điền đầy đủ các trường");
      return false;
    }

    if (!_validateInput.isValidEmail(email)) {
      _isLoading = false;
      _SetError("Email không hợp lệ");
      return false;
    }

    if (_validateInput.LenghtPassword(password) == false) {
      _isLoading = false;
      _SetError("Password phải có nhều hơn 6 kí tự");
      return false;
    }

    if (password.toString() != againPassword.toString()) {
      _isLoading = false;
      _SetError("Mật khẩu không trùng khớp");
      return false;
    }

    try {
      bool emailExists = await CheckEmailExists(email);
      if (emailExists == false) {
        _SetError("Tài khoản đã được sử dụng");
      }
      final user = await _authService.RegisterService(email, password);
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _uid = user.uid;

      String createAt = DateTime.now().toIso8601String();
      Account account = Account(_uid!, email, "", "Active", createAt);
      await _authService.AddAccountService(account);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Đăng ký thất bại: ${e.toString()}");
      return false;
    }
  }

  bool UpdateRoleVM(String role, String uid) {
    _isLoading = true;
    try {
      if (role.isNotEmpty && uid.isNotEmpty) {
        _authService.UpdateRoleUserService(uid, role);
        _isLoading = false;
        _role = role;
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //Check Email
  Future<bool> CheckEmailExists(String email) async {
    bool emailExists = await _authService.CheckEmailExistsService(email);
    if (emailExists) {
      return false;
    }
    return true;
  }

  //Login
  Future<bool> LoginVM(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.isEmpty || password.isEmpty) {
      _isLoading = false;
      _SetError("Hãy điền đầy đủ các trường");
      return false;
    }

    if (!_validateInput.isValidEmail(email)) {
      _SetError("Email không hợp lệ");
      _isLoading = false;
      return false;
    }

    if (_validateInput.LenghtPassword(password) == false) {
      _SetError("Mật khẩu phải đủ 6 kí tự");
      _isLoading = false;
      return false;
    }

    try {
      final user = await _authService.LoginService(email, password);
      if (user == null) {
        _SetError("Tên đăng nhập hoặc mật khẩu không chính xác");
        _isLoading = false;
        return false;
      }
      _uid = user.uid;

      final roleAccount = await _authService.getUserDataService(_uid!);
      if (roleAccount != null && roleAccount.containsKey("Role") && roleAccount.containsKey("Status")) {
        _role = roleAccount["Role"];
        if(roleAccount["Status"] == "Ban"){
          _isLoading = false;
          _SetError("Tài khoản của bạn đã bị khóa");
          return false;
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Lỗi đăng nhập ${e.toString()}");
      return false;
    }
  }

  Future<bool> ForgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.isEmpty) {
      _isLoading = false;
      _SetError("Hãy điền Email của bạn");
      return false;
    }

    if (!_validateInput.isValidEmail(email)) {
      _SetError("Email không hợp lệ");
      return false;
    }
    try {
      bool success = await _authService.ForgotPasswordService(email);
      _isLoading = false;
      notifyListeners();
      if (!success) {
        _SetError("Gửi Email thất bại. Vui lòng thử lại!");
        return false;
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void _SetError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }

  void setUid(String newUid) {
    _uid = newUid;
    notifyListeners();
  }

}
