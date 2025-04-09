import 'package:flutter/cupertino.dart';
import 'package:order_food/Models/OrderDetail.dart';
import 'package:order_food/Models/PlaceOrder.dart';
import 'package:order_food/Services/Order_Service.dart';
import 'package:uuid/uuid.dart';

class Order_ViewModel extends ChangeNotifier {
  final Order_Service order_service = Order_Service();

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<bool> InsertOrder(String uidUser, String nameUser, String phone,
      String address, double total, List<Map<String, dynamic>> dataCart) async {
    try {
      _errorMessage = null;
      String orderId = const Uuid().v4();
      String createAt = DateTime.now().toString();
      String status = "Chờ xác nhận";

      PlaceOrder placeOrder =
          PlaceOrder(orderId, uidUser, nameUser, phone, address, createAt);
      bool isSuccess = await order_service.InsertOrder(placeOrder);
      if (isSuccess == false) {
        _SetError("Lỗi không thể tạo đơn hàng");
        return false;
      }
      for (int i = 0; i < dataCart.length; i++) {
        String orderDetailId = const Uuid().v4();
        final item = dataCart[i];
        OrderDetail orderDetail = OrderDetail(orderDetailId, orderId,
            item["Uid"], item["ProductId"], item["Quantity"], status, createAt);
        bool success = await order_service.InsertOrdersDetail(orderDetail);
        if (success == false) {
          _SetError("Không thể tạo chi tiết đơn hàng");
          return false;
        }
        print('VM Order: $placeOrder');
        print('VM OrderDetail: $orderDetail');
      }
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Lỗi khi đặt hàng: $e");
      print(e);
      return false;
    }
  }

  void _SetError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
