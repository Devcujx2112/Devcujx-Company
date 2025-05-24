import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/Payment.dart';
import 'package:order_food/Models/ShoppingCart.dart';
import 'package:order_food/Services/ShoppingCart_Service.dart';
import 'package:uuid/uuid.dart';

import '../Models/PaymentLinkResponse.dart';
import '../Models/PaymentStatusResponse.dart';

class ShoppingCart_ViewModel extends ChangeNotifier {
  final ShoppingCart_Service shoppingCart_Service = ShoppingCart_Service();

  String? _errorMessage;
  String? _uid;
  String? _email;
  String? _role;

  String? get errorMessage => _errorMessage;

  String? get uid => _uid;

  String? get email => _email;

  String? get role => _role;

  Future<bool> InsertProductShoppingCart(
    String productName,
    String storeName,
    String sellerId,
    int quantity,
    int price,
    String image,
      String uid,
      String productId
  ) async {
    try{
      _errorMessage = null;

      String cartId =  const Uuid().v4();
      ShoppingCart shoppingCart = ShoppingCart(cartId,sellerId, uid, productId, productName, quantity, price, image, storeName);
    bool isSuccess = await shoppingCart_Service.InsertProductShoppingCart(shoppingCart);
    if(isSuccess == false){
      _SetError("Không thể thêm sản phẩm vào giỏ hàng");
      return false;
    }

    notifyListeners();
    return true;
    }catch(e){
      _SetError("Lỗi khi thêm sản phẩm vào giỏ hàng $e");
      return false;
    }
  }

  Future<List<Map<String,dynamic>>?> ShowAllProductFormShoppingCart(String uid) async{
    try{
      _errorMessage = null;
      List<Map<String,dynamic>> productData = await shoppingCart_Service.ShowAllProductFormShoppingCart(uid);
      if(productData.isEmpty){
        _SetError("Không có sản phẩm nào trong giỏ hàng");
      }

      notifyListeners();
      return productData;
    }catch(e){
      _SetError("Lỗi khi show all sản phẩm trên giỏ hàng $e");
      return null;
    }
  }

  Future<bool> UpdateQuantity(String cartId, int quantity) async {
    try{
      _errorMessage = null;
      bool isSuccess = await shoppingCart_Service.UpdateQuantity(cartId, quantity);
      if(isSuccess == false){
        _SetError("Update số lượng thất bại");
        return false;
      }
      notifyListeners();
      return true;
    }catch(e){
      _SetError("Lỗi khi update số lượng $e");
      return false;
    }
  }

  Future<bool> DeleteProductFormCart(String cartId) async {
    try{
      _errorMessage = null;
      bool isSuccess = await shoppingCart_Service.DeleteProductFormCart(cartId);
      if(isSuccess == false){
        _SetError("Xóa sản phẩm khỏi giỏ hàng thất bại");
        return false;
      }
      notifyListeners();
      return true;
    }catch(e){
      _SetError("Lỗi khi xóa sản phẩm khỏi giỏ hàng $e");
      return false;
    }
  }

  Future<Payment> createPaymentLink(int total) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/create-payment-link'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': total}),
    );

    debugPrint(response.body);

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("FAIL to load");
    }
  }

  Future<PaymentStatusResponse> getPaymentStatus(int orderCode) async {
    final response =
    await http.get(Uri.parse('${dotenv.env['BASE_URL']}/order/$orderCode'));
    if (response.statusCode == 200) {
      PaymentStatusResponse status = PaymentStatusResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
      return status;
    } else {
      throw Exception("Fail to get status");
    }
  }

  Future<List<DeepLinkItemResponse>> getDeepLinkList() async {
    final response = await http.get(Uri.parse(
        'https://api.vietqr.io/v2/${Platform.isAndroid ? 'android' : 'ios'}-app-deeplinks'));
    if (response.statusCode == 200) {
      List<dynamic> apps = jsonDecode(response.body)['apps'];
      List<DeepLinkItemResponse> res = apps.map((app) => DeepLinkItemResponse.fromJson(app) ).toList();
      return res;
    } else {
      throw Exception("Fail to get deep link list");
    }
  }


  void _SetError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
