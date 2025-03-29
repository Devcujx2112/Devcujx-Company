import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/Account.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String realTimeAPI =
      "https://crud-firebase-7b852-default-rtdb.firebaseio.com/Account";

  //Register Account
  Future<User?> RegisterService(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return null;
    }
  }

  Future<void> AddAccountService(Account account) async {
    try {
      final Map<String, dynamic> userData = {
        "uid": account.uid,
        "Email": account.email,
        "Role": account.role,
        "Status": account.status,
        "CreateAt": account.createAt
      };
      final response = await http.put(
        Uri.parse("$realTimeAPI/${account.uid}.json"),
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        print("User added successfully!");
      } else {
        print("Failed to add user: ${response.body}");
      }
    } catch (e) {
      print('Erros RealTime API Add Account $e');
    }
  }

  Future<void> UpdateRoleUserService(String uid, String role) async {
    try {
      final String requestUrl = "$realTimeAPI/${Uri.encodeComponent(uid)}.json";

      final response = await http.patch(Uri.parse(requestUrl),
          body: jsonEncode({"Role": role}));

      if (response.statusCode == 200) {
        print("Update role successfully!");
      } else {
        print("Failed to update role: ${response.body}");
      }
    } catch (e) {
      print('Erros RealTime API update role $e');
    }
  }

  Future<bool> CheckEmailExistsService(String email) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI.json"));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          for (var key in data.keys) {
            if (data[key]["Email"] == email) {
              return true;
            }
          }
        }
      }
      return false;
    } catch (e) {
      print("Lỗi kiểm tra Email: $e");
      return false;
    }
  }

  Future<User?> LoginService(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Lỗi đăng nhập: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserDataService(String uid) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI/$uid.json"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Lỗi lấy dữ liệu người dùng: $e");
    }
    return null;
  }

  Future<bool> ForgotPasswordService(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("❌ Lỗi gửi email đặt lại mật khẩu: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> LoadAllAccount() async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI.json"));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);

        if (data == null) return [];

        return data.entries
            .where((entry) =>
                (entry.value as Map<String, dynamic>)["role"]?.toString() !=
                "Admin")
            .map((entry) {
          return {
            "id": entry.key, // Lưu lại key làm ID
            ...entry.value as Map<String, dynamic>, // Ép kiểu dữ liệu
          };
        }).toList();
      } else {
        throw Exception("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi load tài khoản: $e");
      return [];
    }
  }
}
