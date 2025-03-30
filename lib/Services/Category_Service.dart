import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Category_Service {
  static const String realTimeAPI =
      "https://crud-firebase-7b852-default-rtdb.firebaseio.com/Category";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> InsertCategory(
      String cateName, File selectedImage, String cateID) async {
    try {
      //Firebase Storage
      String fileName = "Category/$cateID.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(selectedImage);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      //Realtime Database
      Uri url = Uri.parse("$realTimeAPI/$cateID.json");

      Map<String, dynamic> categoryData = {
        "CategoryID": cateID,
        "CategoryName": cateName,
        "Image": imageUrl,
      };

      final response = await http.put(
        url,
        body: jsonEncode(categoryData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Lỗi khi thêm danh mục: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> ShowAllCategory(String query) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI.json"));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> categories = data.entries.map((entry) {
          return {
            "Uid": entry.key,
            ...entry.value as Map<String, dynamic>,
          };
        }).toList();

        // Lọc danh mục nếu có `query`
        if (query.isNotEmpty) {
          categories = categories
              .where((category) =>
          category["CategoryName"]?.toString().trim().contains(query.toString().trim()) ?? false)
              .toList();
        }

        return categories;
      }
    } catch (e) {
      print('Lỗi show all category: $e');
    }
    return [];
  }



}
