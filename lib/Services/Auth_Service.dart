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
}
