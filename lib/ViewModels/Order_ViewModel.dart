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
          await order_service.ShowAllDataOrderDetail(userId, sellerId, status,orderId);
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

  Future<List<Map<String,dynamic>>?> ShowAllDataOrderDoneAndFail(String uid) async {
    try{
      _errorMessage = null;
      List<Map<String,dynamic>>? orderData = await order_service.ShowAllDataOrderDetail(uid, "", "Tất cả", "");
      if(orderData!.isEmpty){
        _SetError("Bạn chưa có đơn hàng nào");
        return null;
      }
      else{
        List<Map<String,dynamic>> data = orderData.where((order){
          return order["Status"] == 'Hoàn thành' || order["Status"] == "Đã hủy";
        }).toList();
        return data;
      }
    }catch(e){
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
      String dateTime = DateTime.now().toString() ;
      bool isSuccess = await order_service.UpdateStatusOrder(orderId,status,dateTime);
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

  Future<Map<String, dynamic>?> StatisticUser(String userId) async {
    try {
      final currentYear = DateTime.now().year;
      Map<String, dynamic> result = {
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
      List<Map<String, dynamic>> data = await order_service.StatisticUser(userId);
      if (data.isNotEmpty) {
        for (var order in data) {
          Product? product = await product_service.ShowAllProductFormProductId(order["ProductId"]);
          if (product != null) {
            DateTime createAt = DateTime.parse(order["CreateAt"]);

            if (createAt.year == currentYear) {
              num total = product.price * (order["Quantity"] ?? 0);
              int month = createAt.month;

              String monthKey = 'T$month';
              if (result.containsKey(monthKey)) {
                result[monthKey] = (result[monthKey] as num) + total;
              }
            }
          }
        }
      }
      return result;
    } catch (e) {
      print('Error in StatisticUser: $e');
      return null;
    }
  }

  Map<String,dynamic>? ChangeProductToMap(Product product){
    try{
      _errorMessage = null;
      Map<String,dynamic> data = {
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
    }catch(e){
      print(e);
      return null;
    }
  }

  void _SetError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}











