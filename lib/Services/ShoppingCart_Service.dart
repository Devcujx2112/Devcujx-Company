import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/ShoppingCart.dart';

class ShoppingCart_Service{
  static const String realTimeAPI =
      "https://test-login-lyasob-default-rtdb.firebaseio.com/ShoppingCart";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> InsertProductShoppingCart(ShoppingCart shopping)async{
    try{

    Uri url = Uri.parse("$realTimeAPI/${shopping.cartId}.json");

      Map<String, dynamic> shoppingData = {
        "CartId": shopping.cartId,
        "SellerId": shopping.sellerId,
        "UserId": shopping.userId ,
        "ProductId": shopping.productId,
        "Quantity" : shopping.quantity,
        "ProductName": shopping.productName,
        "StoreName": shopping.storeName,
        "Image": shopping.image,
        "Price": shopping.price ,
      };
      final response = await http.put(
        url,
        body: jsonEncode(shoppingData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }

    }catch(e){
      print(e);
      return false;
    }
  }
  Future<List<Map<String,dynamic>>> ShowAllProductFormShoppingCart(String uid) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI.json"));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> productData = data.entries
            .map((entry) => {
          "CartId": entry.key,
          ...(entry.value as Map<String, dynamic>),
        })
            .toList();

          productData =
              productData.where((id) => id["UserId"] == uid).toList();

        return productData;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi show all Product: $e');
      return [];
    }
  }

  Future<bool> UpdateQuantity(String cartId,int quantity) async{
    try{
      Map<String, dynamic> data = {
        "Quantity": quantity
      };
      final response = await http.patch(
        Uri.parse("$realTimeAPI/$cartId.json"),
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );
      if(response.statusCode == 200){
        return true;
      }
      else{
        return false;
      }
    }catch(e){
      print(e);
      return false;
    }
  }

  Future<bool> DeleteProductFormCart(String? cartId) async {
    try{
      if(cartId != null){
        final response =
        await http.delete(Uri.parse("$realTimeAPI/$cartId.json"));
        if(response.statusCode == 200){
          return true;
        }
        return  false;
      }
      else{
        final response =
        await http.delete(Uri.parse("$realTimeAPI.json"));
        if(response.statusCode == 200){
          return true;
        }
        return  false;
      }

    }catch(e){
      print(e);
      return false;
    }
  }
}