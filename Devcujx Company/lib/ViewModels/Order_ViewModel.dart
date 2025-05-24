import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:order_food/Models/OrderDetail.dart';
import 'package:order_food/Models/PlaceOrder.dart';
import 'package:order_food/Models/Product.dart';
import 'package:order_food/Services/Order_Service.dart';
import 'package:order_food/Services/Product_Service.dart';
import 'package:uuid/uuid.dart';

class Order_ViewModel extends ChangeNotifier {
  final Order_Service order_service = Order_Service();
  final Product_Service product_service = Product_Service();

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<bool> InsertOrder(
      String uidUser,
      String nameUser,
      String phone,
      String paymentMethod,
      String address,
      double total,
      List<Map<String, dynamic>> dataCart) async {
    try {
      _errorMessage = null;
      String orderId = const Uuid().v4();
      String createAt = DateTime.now().toString();
      String status = "Chờ xác nhận";
      String comment = "";

      PlaceOrder placeOrder =
          PlaceOrder(orderId, uidUser, nameUser, phone, address, createAt);
      print('Vm $placeOrder');
      bool isSuccess = await order_service.InsertOrder(placeOrder);
      if (isSuccess == false) {
        _SetError("Lỗi không thể tạo đơn hàng");
        return false;
      }
      for (int i = 0; i < dataCart.length; i++) {
        String orderDetailId = const Uuid().v4();
        final item = dataCart[i];
        OrderDetail orderDetail = OrderDetail(
            orderDetailId,
            orderId,
            item["SellerId"],
            item["UserId"],
            item["ProductId"],
            item["Quantity"],
            paymentMethod,
            status,
            comment,
            createAt);
        bool success = await order_service.InsertOrdersDetail(orderDetail);
        if (success == false) {
          _SetError("Không thể tạo chi tiết đơn hàng");
          return false;
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Lỗi khi đặt hàng: $e");
      print(e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> ShowAllDataOrderDetail(
      String userId, String sellerId, String status, String orderId) async {
    try {
      _errorMessage = null;
      List<Map<String, dynamic>>? orderData =
          await order_service.ShowAllDataOrderDetail(
              userId, sellerId, status, orderId);
      if (orderData!.isEmpty) {
        _SetError("Không có đơn hàng nào");
        return null;
      }
      notifyListeners();
      return orderData;
    } catch (e) {
      _SetError("Lỗi khi tải dữ liệu đơn hàng $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> ShowAllDataOrderDoneAndFail(
      String uid) async {
    try {
      _errorMessage = null;
      List<Map<String, dynamic>>? orderData =
          await order_service.ShowAllDataOrderDetail(uid, "", "Tất cả", "");
      if (orderData!.isEmpty) {
        _SetError("Bạn chưa có đơn hàng nào");
        return null;
      } else {
        List<Map<String, dynamic>> data = orderData.where((order) {
          return order["Status"] == 'Hoàn thành' || order["Status"] == "Đã hủy";
        }).toList();
        return data;
      }
    } catch (e) {
      _SetError("Lỗi khi tìm kiếm đơn hàng trong thống kê chi tiêu của User");
      return null;
    }
  }

  Future<bool> DeleteOrderDetail(String orderDetailId) async {
    try {
      _errorMessage = null;
      bool isSuccess = await order_service.DeleteOrderDetail(orderDetailId);
      if (isSuccess == false) {
        _SetError("Xóa đơn hàng thất bại");
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Lỗi khi xóa đơn hàng");
      return false;
    }
  }

  Future<bool> UpdateStatusOrder(String orderId, String status) async {
    try {
      _errorMessage = null;
      String dateTime = DateTime.now().toString();
      bool isSuccess =
          await order_service.UpdateStatusOrder(orderId, status, dateTime);
      if (isSuccess == false) {
        _SetError("Lỗi không thể sửa trạng thái đơn hàng");
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Lỗi khi sửa trạng thái đơn hàng đơn hàng $e");
      return false;
    }
  }

  Future<PlaceOrder?> ShowAllPlaceOrder(String orderId) async {
    try {
      _errorMessage = null;
      PlaceOrder? placeOrder = await order_service.ShowAllPlaceOrder(orderId);
      if (placeOrder == null) {
        _SetError("Không có đơn hàng nào");
        return null;
      }
      notifyListeners();
      return placeOrder;
    } catch (e) {
      _SetError("Lỗi khi show all order");
      return null;
    }
  }

  Future<Map<String, dynamic>?> StatisticUserMonth(String userId) async {
    try {
      final currentYear = DateTime.now().year;
      Map<String, dynamic> monthlyData = {
        'T1': 0,
        'T2': 0,
        'T3': 0,
        'T4': 0,
        'T5': 0,
        'T6': 0,
        'T7': 0,
        'T8': 0,
        'T9': 0,
        'T10': 0,
        'T11': 0,
        'T12': 0,
      };
      num totalSpending = 0;

      List<Map<String, dynamic>> data =
          await order_service.StatisticUser(userId);
      if (data.isNotEmpty) {
        for (var order in data) {
          Product? product = await product_service.ShowAllProductFormProductId(
              order["ProductId"]);
          if (product != null) {
            DateTime createAt = DateTime.parse(order["CreateAt"]);

            if (createAt.year == currentYear) {
              num total = product.price * (order["Quantity"] ?? 0);
              int month = createAt.month;

              String monthKey = 'T$month';
              if (monthlyData.containsKey(monthKey)) {
                monthlyData[monthKey] = (monthlyData[monthKey] as num) + total;
                totalSpending += total;
              }
            }
          }
        }
      }

      return {
        'monthlyData': monthlyData,
        'totalSpending': totalSpending,
      };
    } catch (e) {
      print('Error in StatisticUser: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> StatisticUserYear(String userId) async {
    try {
      final currentYear = DateTime.now().year;
      Map<String, dynamic> yearlyData = {
        (currentYear - 3).toString(): 0,
        (currentYear - 2).toString(): 0,
        (currentYear - 1).toString(): 0,
        currentYear.toString(): 0,
      };

      num totalSpending = 0;

      List<Map<String, dynamic>> data =
          await order_service.StatisticUser(userId);

      if (data.isNotEmpty) {
        for (var order in data) {
          Product? product = await product_service.ShowAllProductFormProductId(
              order["ProductId"]);
          if (product != null) {
            DateTime createAt = DateTime.parse(order["CreateAt"]);
            int orderYear = createAt.year;

            if (yearlyData.containsKey(orderYear.toString())) {
              num total = product.price * (order["Quantity"] ?? 0);
              yearlyData[orderYear.toString()] =
                  (yearlyData[orderYear.toString()] as num) + total;
              totalSpending += total;
            }
          }
        }
      }

      return {
        'yearlyData': yearlyData,
        'totalSpending': totalSpending,
      };
    } catch (e) {
      print('Error in StatisticUserYear: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> StatisticalSellerDay(
      String sellerId) async {
    try {
      _errorMessage = null;
      final currentDay = DateTime.now();

      final List<Map<String, dynamic>>? orders =
          await order_service.StatisticSeller(sellerId, currentDay);
      if (orders == null || orders.isEmpty) return null;

      final productIds =
          orders.map((o) => o["ProductId"].toString()).toSet().toList();
      final List<Map<String, dynamic>> products =
          await product_service.GetAllProductById(productIds);

      final List<Map<String, dynamic>> results = [];
      num totalSpending = 0;

      for (final order in orders) {
        final product = products.firstWhere(
          (p) => p["ProductId"] == order["ProductId"].toString(),
          orElse: () => {},
        );

        if (product.isNotEmpty) {
          final price = product["Price"] ?? 0;
          final quantity = order["Quantity"] ?? 0;
          final itemTotal = price * quantity;
          final image = product["Image"];

          totalSpending += itemTotal;

          results.add({
            'OrderDetailId': order["OrderDetailId"],
            'ProductId': product["ProductId"],
            'ProductName': product["ProductName"] ?? 'Không có tên',
            'Price': price,
            'Quantity': quantity,
            'Total': itemTotal,
            "Image": image,
            "OrderId": order["OrderId"],
            "PaymentMethod": order["PaymentMethod"],
            "UserId": order["UserId"],
            'CreateAt': order["CreateAt"],
            'Status': order["Status"],
          });
        }
      }

      if (results.isNotEmpty) {
        results.insert(0, {
          'Summary': true,
          'TotalSpending': totalSpending,
          'OrderCount': results.length,
        });
      }

      return results;
    } catch (e) {
      _SetError("StatisticalSellerDay error: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> StatisticalSellerWeek(
      String sellerId) async {
    try {
      List<Map<String, dynamic>> results = [];
      double totalSpending = 0;
      _errorMessage = null;

      final data = await order_service.GetStatisticalSellerWeek(sellerId);
      if (data == null) return null;

      final listIdProduct =
          data.map((x) => x["ProductId"].toString()).toSet().toList();
      final List<Map<String, dynamic>> products =
          await product_service.GetAllProductById(listIdProduct);

      for (var order in data) {
        final product = products.firstWhere(
            (p) => p["ProductId"] == order["ProductId"].toString(),
            orElse: () => {});
        if (product.isNotEmpty) {
          final price = product["Price"] ?? 0;
          final quantity = order["Quantity"] ?? 0;
          final itemTotal = price * quantity;
          final image = product["Image"];

          totalSpending += itemTotal;

          results.add({
            'OrderDetailId': order["OrderDetailId"],
            'ProductId': product["ProductId"],
            'ProductName': product["ProductName"] ?? 'Không có tên',
            'Price': price,
            'Quantity': quantity,
            'Total': itemTotal,
            "Image": image,
            "OrderId": order["OrderId"],
            "PaymentMethod": order["PaymentMethod"],
            "UserId": order["UserId"],
            'CreateAt': order["CreateAt"],
            'Status': order["Status"],
          });
        }
      }
      if (results.isNotEmpty) {
        results.insert(0, {
          'Summary': true,
          'TotalSpending': totalSpending,
          'OrderCount': results.length,
        });
      }
      return results;
    } catch (e) {
      _SetError("Lỗi khi thống kê theo tuần $e");
      return null;
    }
  }

  Future<List<Map<String,dynamic>>?> StatisticalSellerYear(String sellerId) async{
    try{
      _errorMessage = null;
      List<Map<String, dynamic>> results = [];
      double totalSpending = 0;

      final data = await order_service.StatisticalSellerYear(sellerId);
      if (data == null) return null;

      final listIdProduct =
      data.map((x) => x["ProductId"].toString()).toSet().toList();
      final List<Map<String, dynamic>> products =
      await product_service.GetAllProductById(listIdProduct);

      for (var order in data) {
        final product = products.firstWhere(
                (p) => p["ProductId"] == order["ProductId"].toString(),
            orElse: () => {});
        if (product.isNotEmpty) {
          final price = product["Price"] ?? 0;
          final quantity = order["Quantity"] ?? 0;
          final itemTotal = price * quantity;
          final image = product["Image"];

          totalSpending += itemTotal;

          results.add({
            'OrderDetailId': order["OrderDetailId"],
            'ProductId': product["ProductId"],
            'ProductName': product["ProductName"] ?? 'Không có tên',
            'Price': price,
            'Quantity': quantity,
            'Total': itemTotal,
            "Image": image,
            "OrderId": order["OrderId"],
            "PaymentMethod": order["PaymentMethod"],
            "UserId": order["UserId"],
            'CreateAt': order["CreateAt"],
            'Status': order["Status"],
          });
        }
      }
      if (results.isNotEmpty) {
        results.insert(0, {
          'Summary': true,
          'TotalSpending': totalSpending,
          'OrderCount': results.length,
        });
      }
      return results;
    }catch(e){
      _SetError("Lỗi khi thống kê theo năm $e");
      return null;
    }
  }


  Future<List<Map<String,dynamic>>?> StatisticalSellerMonth(String sellerId) async{
    try{
      _errorMessage = null;
      List<Map<String,dynamic>>? results = [];
      double totalSpending = 0.0;

      final data = await order_service.StatisticalSellerMonth(sellerId);
      if (data == null) return null;

      final listIdProduct =
      data.map((x) => x["ProductId"].toString()).toSet().toList();
      final List<Map<String, dynamic>> products =
      await product_service.GetAllProductById(listIdProduct);

      for (var order in data) {
        final product = products.firstWhere(
                (p) => p["ProductId"] == order["ProductId"].toString(),
            orElse: () => {});
        if (product.isNotEmpty) {
          final price = product["Price"] ?? 0;
          final quantity = order["Quantity"] ?? 0;
          final itemTotal = price * quantity;
          final image = product["Image"];

          totalSpending += itemTotal;

          results.add({
            'OrderDetailId': order["OrderDetailId"],
            'ProductId': product["ProductId"],
            'ProductName': product["ProductName"] ?? 'Không có tên',
            'Price': price,
            'Quantity': quantity,
            'Total': itemTotal,
            "Image": image,
            "OrderId": order["OrderId"],
            "PaymentMethod": order["PaymentMethod"],
            "UserId": order["UserId"],
            'CreateAt': order["CreateAt"],
            'Status': order["Status"],
          });
        }
      }
      if (results.isNotEmpty) {
        results.insert(0, {
          'Summary': true,
          'TotalSpending': totalSpending,
          'OrderCount': results.length,
        });
      }

      return results;
    }catch(e){
      _SetError("Lỗi khi thống kê theo tháng $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> ChartSellerWeek(String sellerId) async {
    try {
      _errorMessage = null;
      Map<String, dynamic> chartDataWeek = {
        "T2": 0,
        "T3": 0,
        "T4": 0,
        "T5": 0,
        "T6": 0,
        "T7": 0,
        "CN": 0,
      };

      List<Map<String, dynamic>>? data =
          await order_service.GetStatisticalSellerWeek(sellerId);

      if (data != null) {
        for (var order in data) {
          try {
            Product? product =
                await product_service.ShowAllProductFormProductId(
                    order["ProductId"]);

            if (product != null) {
              double orderTotal =
                  (order["Quantity"] as num).toDouble() * product.price;

              DateTime orderDate = DateTime.parse(order["CreateAt"]).toLocal();
              String dayOfWeek = _getVietnameseDayOfWeek(orderDate.weekday);

              if (chartDataWeek.containsKey(dayOfWeek)) {
                double currentValue =
                    (chartDataWeek[dayOfWeek] as num).toDouble();
                chartDataWeek[dayOfWeek] = currentValue + orderTotal;
              }
            }
          } catch (e) {
            _SetError('Lỗi khi xử lý đơn hàng ${order["id"]}: $e');
          }
        }
      }

      return chartDataWeek;
    } catch (e) {
      _SetError("Lỗi khi truy cập biểu đồ tuần: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> ChartSellerYear(String sellerId) async {
    try {
      final int currentYear = DateTime.now().year; // 2025
      final Map<String, double> results = {
        "$currentYear": 0.0,       // 2025
        "${currentYear - 1}": 0.0, // 2024
        "${currentYear - 2}": 0.0, // 2023
        "${currentYear - 3}": 0.0  // 2022
      };

      final allOrders = await order_service.StatisticalSellerYear(sellerId);

      if (allOrders != null) {
        for (final order in allOrders) {
          try {
            final product = await product_service.ShowAllProductFormProductId(
                order["ProductId"]?.toString() ?? "");

            if (product != null) {
              final orderTotal =
                  (order["Quantity"] as num).toDouble() * product.price.toDouble();

              final createAt = DateTime.parse(order["CreateAt"].toString());
              final yearKey = "${createAt.year}";

              if (results.containsKey(yearKey)) {
                results[yearKey] = results[yearKey]! + orderTotal;
                print('Đã cộng $orderTotal vào năm $yearKey');
              } else {
                print('Bỏ qua năm $yearKey (không thuộc 4 năm gần nhất)');
              }
            }
          } catch (e) {
            print('Lỗi đơn ${order["OrderId"]}: $e');
          }
        }
      }

      print('Kết quả cuối cùng: $results');
      return results;
    } catch (e) {
      print('Lỗi hệ thống: $e');
      return null;
    }
  }

  String _getVietnameseDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return "T2";
      case 2:
        return "T3";
      case 3:
        return "T4";
      case 4:
        return "T5";
      case 5:
        return "T6";
      case 6:
        return "T7";
      case 7:
        return "CN";
      default:
        return "";
    }
  }

  Future<Map<String, dynamic>?> ChartSellerMonth(String sellerId) async {
    try {
      _errorMessage = null;
      Map<String, dynamic> chartDataMonth = {
        "T1": 0.0,
        "T2": 0.0,
        "T3": 0.0,
        "T4": 0.0,
        "T5": 0.0,
        "T6": 0.0,
        "T7": 0.0,
        "T8": 0.0,
        "T9": 0.0,
        "T10": 0.0,
        "T11": 0.0,
        "T12": 0.0,
      };

      List<Map<String, dynamic>>? data = await order_service.StatisticalSellerMonth(sellerId);

      if (data != null) {
        for (var order in data) {
          try {
            Product? product = await product_service.ShowAllProductFormProductId(order["ProductId"]);

            if (product != null) {
              double orderTotal = (order["Quantity"] as num).toDouble() * product.price.toDouble();

              DateTime orderDate = DateTime.parse(order["CreateAt"]).toLocal();
              String month = "T${orderDate.month}";

              if (chartDataMonth.containsKey(month)) {
                chartDataMonth[month] = (chartDataMonth[month] as double) + orderTotal;
              }
            }
          } catch (e) {
            print('Lỗi khi xử lý đơn hàng ${order["id"]}: $e');
          }
        }
      }

      return chartDataMonth;
    } catch (e) {
      _SetError("Lỗi khi truy cập biểu đồ tháng: $e");
      return null;
    }
  }

  Map<String, dynamic>? ChangeProductToMap(Product product) {
    try {
      _errorMessage = null;
      Map<String, dynamic> data = {
        "ProductId": product.productId,
        "SellerId": product.uid,
        "ProductName": product.productName,
        "StoreName": product.storeName,
        "Rating": product.rating,
        "CategoryName": product.categoryName,
        "CreateAt": product.createAt,
        "Description": product.description,
        "Image": product.image,
        "Price": product.price,
      };
      return data;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _SetError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
