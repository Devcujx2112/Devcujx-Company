import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/OrderDetail.dart';
import 'package:order_food/Models/PlaceOrder.dart';

class Order_Service {
  static const String realTimeAPI =
      "https://test-login-lyasob-default-rtdb.firebaseio.com";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> InsertOrder(PlaceOrder order) async {
    try {
      Uri url = Uri.parse("$realTimeAPI/Order/${order.orderId}.json");

      Map<String, dynamic> orderData = {
        "OrderId": order.orderId,
        "UserId": order.uidUser,
        "NameUser": order.nameUser,
        "PhoneUser": order.phoneUser,
        "Address": order.addressUser,
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
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> InsertOrdersDetail(OrderDetail orderDetail) async {
    try {
      Uri url = Uri.parse(
          "$realTimeAPI/OrderDetail/${orderDetail.orderDetailId}.json");

      Map<String, dynamic> orderDetailData = {
        "OrderDetailId": orderDetail.orderDetailId,
        "OrderId": orderDetail.orderId,
        "SellerId": orderDetail.sellerId,
        "UserId": orderDetail.userId,
        "ProductId": orderDetail.productid,
        "Quantity": orderDetail.quantity,
        "PaymentMethod": orderDetail.paymentMethod,
        "Status": orderDetail.status,
        "Comment": orderDetail.comment,
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
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> ShowAllDataOrderDetail(
      String userId, String sellerId, String status, String orderId) async {
    try {
      final response =
          await http.get(Uri.parse("$realTimeAPI/OrderDetail.json"));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> orderData = data.entries
            .map((entry) => {
                  "OrderDetailId": entry.key,
                  ...(entry.value as Map<String, dynamic>),
                })
            .toList();

        if (status != "Tất cả") {
          orderData = orderData
              .where((order) =>
                  order["Status"]
                      ?.toString()
                      .toLowerCase()
                      .contains(status.toLowerCase().trim()) ??
                  false)
              .toList();
        }

        if (orderId.isNotEmpty) {
          orderData = orderData
              .where((order) =>
                  order["OrderDetailId"]
                      ?.toString()
                      .toLowerCase()
                      .contains(orderId.toLowerCase().trim()) ??
                  false)
              .toList();
        }

        if (userId.isNotEmpty) {
          orderData = orderData
              .where((product) => product["UserId"] == userId)
              .toList();
        } else if (sellerId.isNotEmpty) {
          orderData = orderData
              .where((product) => product["SellerId"] == sellerId)
              .toList();
        }

        return orderData;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> DeleteOrderDetail(String orderDetailId) async {
    try {
      if (orderDetailId != null) {
        final response = await http
            .delete(Uri.parse("$realTimeAPI/OrderDetail/$orderDetailId.json"));
        if (response.statusCode == 200) {
          return true;
        }
        return false;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<PlaceOrder?> ShowAllPlaceOrder(String orderId) async {
    try {
      Uri url = Uri.parse("$realTimeAPI/Order/$orderId.json");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          PlaceOrder? dataOrder = PlaceOrder(
              data["OrderId"] ?? [],
              data["UserId"] ?? [],
              data["NameUser"] ?? [],
              data["PhoneUser"] ?? [],
              data["Address"] ?? [],
              data["CreateAt"] ?? []);
          return dataOrder;
        } else {
          print("Không tìm thấy thông tin đơn hàng!");
          return null;
        }
      } else {
        print("Lỗi khi lấy dữ liệu: ${response.body}");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> UpdateStatusOrder(
      String orderId, String status, String dateTime) async {
    try {
      Map<String, dynamic> data = {"Status": status, "CreateAt": dateTime};
      Uri url = Uri.parse("$realTimeAPI/OrderDetail/$orderId.json");
      final response = await http.patch(url,
          body: jsonEncode(data),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> UpdateCommentOrder(String orderId, String comment) async {
    try {
      Map<String, dynamic> data = {"Comment": comment};
      Uri url = Uri.parse("$realTimeAPI/OrderDetail/$orderId.json");
      final response = await http.patch(url,
          body: jsonEncode(data),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> StatisticUser(String userId) async {
    try {
      final response =
          await http.get(Uri.parse("$realTimeAPI/OrderDetail/.json"));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> results = [];

        data.forEach((orderID, orderData) {
          if (orderData["UserId"] == userId) {
            results.add({
              'OrderDetailId': orderID,
              "CreateAt": orderData["CreateAt"],
              "ProductId": orderData["ProductId"],
              "Quantity": orderData["Quantity"],
            });
          }
        });
        return results..sort((a, b) => b['CreateAt'].compareTo(a['CreateAt']));
      } else {
        print('Không thể truy cập');
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> StatisticSeller(
      String sellerId, DateTime date) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI/OrderDetail.json"
          "?orderBy=\"SellerId\""
          "&equalTo=\"$sellerId\""));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> results = [];

        data.forEach((orderID, orderData) {
          if (DateTime.parse(orderData["CreateAt"]).day == date.day &&
              orderData["Status"] == "Hoàn thành") {
            results.add({
              'OrderDetailId': orderID,
              "CreateAt": orderData["CreateAt"],
              "ProductId": orderData["ProductId"],
              "Quantity": orderData["Quantity"],
              "Comment": orderData["Comment"],
              "OrderId": orderData["OrderId"],
              "PaymentMethod": orderData["PaymentMethod"],
              "SellerId": orderData["SellerId"],
              "Status": orderData["Status"],
              "UserId": orderData["UserId"]
            });
          }
        });
        return results..sort((a, b) => b['CreateAt'].compareTo(a['CreateAt']));
      } else {
        print('Không thể truy cập');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Map<String,dynamic>>?> StatisticalSellerMonth(String sellerId) async{
    try{
      final response = await http.get(Uri.parse("$realTimeAPI/OrderDetail.json"
          "?orderBy=\"SellerId\""
          "&equalTo=\"$sellerId\""));
      if(response.statusCode == 200){
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data == null) return [];
        int currentYear = DateTime.now().year;

        List<Map<String, dynamic>> results = [];

        data.forEach((orderID, orderData) {
          if (DateTime.parse(orderData["CreateAt"]).year == currentYear &&
              orderData["Status"] == "Hoàn thành") {
            results.add({
              'OrderDetailId': orderID,
              "CreateAt": orderData["CreateAt"],
              "ProductId": orderData["ProductId"],
              "Quantity": orderData["Quantity"],
              "Comment": orderData["Comment"],
              "OrderId": orderData["OrderId"],
              "PaymentMethod": orderData["PaymentMethod"],
              "SellerId": orderData["SellerId"],
              "Status": orderData["Status"],
              "UserId": orderData["UserId"]
            });
          }
        });
        return results..sort((a, b) => b['CreateAt'].compareTo(a['CreateAt']));
      }
    }catch(e){
      print(e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> StatisticalSellerYear(String sellerId) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI/OrderDetail.json"
          "?orderBy=\"SellerId\""
          "&equalTo=\"$sellerId\""));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data == null || data.isEmpty) return [];

        final currentYear = DateTime.now().year;
        final List<Map<String, dynamic>> results = [];

        await Future.forEach(data.entries, (entry) async {
          try {
            final orderData = entry.value as Map<String, dynamic>;
            if (orderData["SellerId"] != sellerId) return;
            if (orderData["Status"] != "Hoàn thành") return;

            final createAt = DateTime.parse(orderData["CreateAt"]);
            if (createAt.year < currentYear - 4) return;

            results.add({
              'OrderDetailId': entry.key,
              ...orderData,
              'CreateAt': createAt,
              'Year': createAt.year,
            });
          } catch (e) {
            print('Error processing order ${entry.key}: $e');
          }
        });

        return results..sort((a, b) => b['CreateAt'].compareTo(a['CreateAt'])); // mới -> cũ
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('StatisticalSellerYear error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> GetStatisticalSellerWeek(
      String sellerId) async {
    try {
      // 1. Xác định phạm vi tuần (thứ 2 đến chủ nhật) theo giờ Việt Nam (UTC+7)
      final now = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 7)); // Chuyển sang giờ VN
      final firstDayOfWeek =
          now.subtract(Duration(days: now.weekday - 1)); // Thứ 2 đầu tuần
      final lastDayOfWeek = firstDayOfWeek.add(const Duration(
          days: 6, hours: 23, minutes: 59, seconds: 59)); // Chủ nhật cuối tuần

      // Đặt lại giờ cho ngày đầu và cuối tuần
      final startOfWeek = DateTime(firstDayOfWeek.year, firstDayOfWeek.month,
          firstDayOfWeek.day, 0, 0, 0);
      final endOfWeek = DateTime(lastDayOfWeek.year, lastDayOfWeek.month,
          lastDayOfWeek.day, 23, 59, 59);

      final response = await http.get(Uri.parse(
          "$realTimeAPI/OrderDetail.json?orderBy=\"SellerId\"&equalTo=\"$sellerId\""));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> weeklyOrders = [];

        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            try {
              final orderDate = DateTime.parse(value["CreateAt"] as String)
                  .toUtc()
                  .add(const Duration(hours: 7)); // Chuyển sang giờ VN
              if (orderDate.isAfter(startOfWeek) &&
                  orderDate.isBefore(endOfWeek) &&
                  value["Status"] == "Hoàn thành") {
                weeklyOrders.add({
                  'id': key,
                  ...value,
                  'orderDate': orderDate,
                });
              }
            } catch (e) {
              print('Lỗi parse ngày: $e');
            }
          }
        });

        return weeklyOrders.isNotEmpty ? weeklyOrders : null;
      }
      return null;
    } catch (e) {
      print('Lỗi hệ thống: $e');
      return null;
    }
  }
}
