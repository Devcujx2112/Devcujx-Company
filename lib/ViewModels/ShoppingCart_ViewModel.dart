import 'package:flutter/foundation.dart';
import 'package:order_food/Models/ShoppingCart.dart';
import 'package:order_food/Services/ShoppingCart_Service.dart';
import 'package:uuid/uuid.dart';

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

  void _SetError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
