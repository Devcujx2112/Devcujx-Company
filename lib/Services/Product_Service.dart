import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/Favorite.dart';
import 'package:order_food/Models/Product.dart';

class Product_Service {
  static const String realTimeAPI =
      "https://test-login-lyasob-default-rtdb.firebaseio.com/Product";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> InsertProduct(Product product, File selectedImage) async {
    try {
      String fileName = "Product/${product.productId}.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(selectedImage);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      Uri url = Uri.parse("$realTimeAPI/${product.productId}.json");

      Map<String, dynamic> productData = {
        "ProductId": product.productId,
        "Uid": product.uid,
        "StoreName": product.storeName,
        "CategoryName": product.categoryName,
        "ProductName": product.productName,
        "Image": imageUrl,
        "Price": product.price,
        "Description": product.description,
        "Rating": product.rating,
        "CreateAt": product.createAt
      };
      final response = await http.put(
        url,
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('$e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> ShowAllProduct(
      String query, String uid) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI.json"));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> productData = data.entries
            .map((entry) => {
                  "ProductId": entry.key,
                  ...(entry.value as Map<String, dynamic>),
                })
            .toList();

        if (uid.isNotEmpty) {
          productData =
              productData.where((product) => product["Uid"] == uid).toList();
        }

        if (query.isNotEmpty) {
          productData = productData
              .where((product) =>
                  product["ProductName"]
                      ?.toString()
                      .toLowerCase()
                      .contains(query.toLowerCase().trim()) ??
                  false)
              .toList();
        }
        return productData;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi show all Product: $e');
      return [];
    }
  }

  Future<bool> DeleteProduct(String productId) async {
    try {
      final imageURL =
          await http.get(Uri.parse("$realTimeAPI/$productId.json"));
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
          await http.delete(Uri.parse("$realTimeAPI/$productId.json"));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> UpdateProduct(
      String productId,
      String productName,
      String categoryName,
      String description,
      int price,
      String imageOld,
      File? newImage) async {
    try {
      String imageUrl = imageOld;
      if (newImage != null) {
        try {
          if (imageOld.isNotEmpty) {
            print("Service $imageOld");
            Reference oldImageRef =
                FirebaseStorage.instance.refFromURL(imageOld);
            await oldImageRef.delete();
          }
          Reference newImageRef =
              FirebaseStorage.instance.ref().child("Product/$productId.jpg");
          UploadTask uploadTask = newImageRef.putFile(newImage);
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } catch (e) {
          print("Lỗi khi upload ảnh $e");
          return false;
        }
      }
      Map<String, dynamic> productData = {
        "ProductName": productName,
        "CategoryName": categoryName,
        "Price": price,
        "Description": description,
        "Image": imageUrl
      };
      final response = await http.patch(
        Uri.parse("$realTimeAPI/$productId.json"),
        body: jsonEncode(productData),
        headers: {"Content-Type": "application/json"},
      );

      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> SearchProductFormCategory(
      String categoryName) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI.json"));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> productData = data.entries
            .map((entry) => {
                  "ProductId": entry.key,
                  ...(entry.value as Map<String, dynamic>),
                })
            .toList();

        productData = productData
            .where((product) => product["CategoryName"] == categoryName)
            .toList();

        return productData;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> InsertFavoriteProduct(Favorite favorite) async {
    try {
      Uri url = Uri.parse(
          "https://test-login-lyasob-default-rtdb.firebaseio.com/Favorite/${favorite.favoriteId}.json");

      Map<String, dynamic> favoriteData = {
        "FavoriteId": favorite.favoriteId,
        "Uid": favorite.uid,
        "ProductId": favorite.productId,
      };
      final response = await http.put(
        url,
        body: jsonEncode(favoriteData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> ShowAllFavoriteProduct(String uid) async {
    try {
      final response = await http.get(Uri.parse(
          "https://test-login-lyasob-default-rtdb.firebaseio.com/Favorite.json"));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data == null) return [];
        List<Map<String, dynamic>> favoriteData = data.entries
            .map((entry) => {
                  "FavoriteId": entry.key,
                  ...(entry.value as Map<String, dynamic>),
                })
            .toList();
        favoriteData =
            favoriteData.where((favorite) => favorite["Uid"] == uid).toList();
        return favoriteData;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> SearchProductFormProductId(
      String productId) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI.json"));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> productData = data.entries
            .map((entry) => {
                  "ProductId": entry.key,
                  ...(entry.value as Map<String, dynamic>),
                })
            .toList();

        productData = productData
            .where((product) => product["ProductId"] == productId)
            .toList();

        return productData;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> GetAllProductById(
      List<String> productIds) async {
    try {
      if (productIds.isEmpty) return [];

      final response = await http.get(Uri.parse("$realTimeAPI.json"));
      if (response.statusCode != 200) return [];

      final Map<String, dynamic>? data = jsonDecode(response.body);
      if (data == null) return [];

      return data.entries
          .where((entry) => productIds.contains(entry.key))
          .map((entry) => {
                "ProductId": entry.key,
                ...(entry.value as Map<String, dynamic>),
              })
          .toList();
    } catch (e) {
      print('Error in GetAllProductById: $e');
      return [];
    }
  }

  Future<bool> DeleteFavoriteProduct(String favoriteId) async {
    try {
      Uri url = Uri.parse(
          "https://test-login-lyasob-default-rtdb.firebaseio.com/Favorite/$favoriteId.json");
      final response = await http.delete(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
