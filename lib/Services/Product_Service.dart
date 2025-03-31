import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/Product.dart';

class Product_Service{
  static const String realTimeAPI =
      "https://crud-firebase-7b852-default-rtdb.firebaseio.com/Product";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> InsertProduct(Product product, File selectedImage) async {
    try{
      String fileName = "Product/${product.productId}.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(selectedImage);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      Uri url = Uri.parse("$realTimeAPI/${product.productId}.json");

      Map<String, dynamic> productData = {
        "ProductId" : product.productId,
        "Uid" : product.uid,
        "CategoryName" : product.categoryName,
        "ProductName": product.productName,
        "Image" : imageUrl,
        "Price" : product.price,
        "Description" : product.description,
        "Rating" : product.rating,
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

    }catch(e){
      print('$e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> ShowAllProduct(String query, String uid) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI.json"));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> productData = data.entries
            .map((entry) => {
          "ProductId": entry.key,
          ...entry.value as Map<String, dynamic>,
        })
            .where((product) => product["Uid"] == uid)
            .toList();

        if (query.isNotEmpty) {
          productData = productData
              .where((product) =>
          product["ProductName"]
              ?.toString()
              .toLowerCase()
              .contains(query.toLowerCase().trim()) ?? false)
              .toList();
        }

        return productData;
      }
    } catch (e) {
      print('Lỗi show all Product: $e');
    }
    return [];
  }


  Future<bool> DeleteProduct(String productId) async {
    try {
      final imageURL = await http.get(Uri.parse("$realTimeAPI/$productId.json"));
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
}
