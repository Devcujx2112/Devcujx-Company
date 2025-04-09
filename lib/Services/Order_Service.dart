import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/OrderDetail.dart';
import 'package:order_food/Models/PlaceOrder.dart';

class Order_Service{

  static const String realTimeAPI =
      "https://test-login-lyasob-default-rtdb.firebaseio.com/Order";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> InsertOrder(PlaceOrder order) async{
    try{
      Uri url = Uri.parse("$realTimeAPI/${order.orderId}.json");

      Map<String, dynamic> orderData = {
        "OrderId": order.orderId,
        "UserId": order.uidUser,
        "NameUser": order.nameUser,
        "PhoneUser": order.phoneUser,
        "Address" : order.addressUser,
        "CreateAt": order.createAt
      };
      final response = await http.put(
        url,
        body: jsonEncode(orderData),
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

  Future<bool> InsertOrdersDetail(OrderDetail orderDetail) async{
    try{
      Uri url = Uri.parse("$realTimeAPI/${orderDetail.orderId}/${orderDetail.orderDetailId}.json");

      Map<String, dynamic> orderDetailData = {
        "OrderDetailId": orderDetail.orderDetailId,
        "OrderId": orderDetail.orderId,
        "SellerId": orderDetail.sellerId,
        "ProductId": orderDetail.productid,
        "Quantity" : orderDetail.quantity,
        "Status": orderDetail.status,
        "CreateAt": orderDetail.createAt
      };
      final response = await http.put(
        url,
        body: jsonEncode(orderDetailData),
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
}