import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Category_Service {
  static const String realTimeAPI =
      "https://test-login-lyasob-default-rtdb.firebaseio.com/Category";
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

        if (query.isNotEmpty) {
          categories = categories
              .where((category) =>
                  category["CategoryName"]
                      ?.toString().toLowerCase()
                      .trim()
                      .contains(query.toString().toLowerCase().trim()) ??
                  false)
              .toList();
        }

        return categories;
      }
    } catch (e) {
      print('Lỗi show all category: $e');
    }
    return [];
  }

  Future<bool> DeleteCategory(String cateID) async {
    try {
      final imageURL = await http.get(Uri.parse("$realTimeAPI/$cateID.json"));
      if (imageURL.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(imageURL.body);
        if (data != null && data.containsKey("Image")) {
          String image = data["Image"];
          try {
            Reference storageRef = FirebaseStorage.instance.refFromURL(image);
            await storageRef.delete();
          } catch (e) {
            print("Lỗi khi xóa ảnh: $e");
          }
        }
      }
      final response =
          await http.delete(Uri.parse("$realTimeAPI/$cateID.json"));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> UpdateCategory(String cateID, File? selectedImage,
      String cateName, String imageOld) async {
    try {
      String? imageUrl = imageOld;
      if (selectedImage != null) {
        try {
          if (imageOld.isNotEmpty) {
            Reference oldImageRef =
                FirebaseStorage.instance.refFromURL(imageOld);
            await oldImageRef.delete();
          }

          Reference newImageRef =
              FirebaseStorage.instance.ref().child("Category/$cateID.jpg");
          UploadTask uploadTask = newImageRef.putFile(selectedImage);
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (e) {
          print("Lỗi khi upload ảnh: $e");
          return false;
        }
      }
      Map<String, dynamic> categoryData = {
        "CategoryID": cateID,
        "CategoryName": cateName,
        "Image": imageUrl,
      };

      final response = await http.patch(
        Uri.parse("$realTimeAPI/$cateID.json"),
        body: jsonEncode(categoryData),
        headers: {"Content-Type": "application/json"},
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi khi cập nhật danh mục: $e");
      return false;
    }
  }
}
