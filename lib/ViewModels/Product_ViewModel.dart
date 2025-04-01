import 'dart:io';

import 'package:flutter/material.dart';
import 'package:order_food/Models/Product.dart';
import 'package:order_food/Services/Product_Service.dart';
import 'package:uuid/uuid.dart';

import '../Helpers/ValidateInput.dart';

class Product_ViewModel extends ChangeNotifier {
  final Product_Service product_service = Product_Service();
  final ValidateInput _validateInput = ValidateInput();

  bool _isLoading = false;
  String? _errorMessage;
  String? _uid;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get uid => _uid;

  Future<bool> InsertProduct(
      String uid,
      String categoryName,
      String productName,
      int price,
      String description,
      File selectedImage) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_validateInput.InputProduct(
              uid, categoryName, productName, price, description) ==
          false) {
        _isLoading = false;
        _SetError("Vui lòng điền đầy đủ thông tin của sản phẩm");
        return false;
      }
      String productId = const Uuid().v4();
      String createAt = DateTime.now().toString();
      double rating = 5;
      Product product = Product(productId, uid, categoryName, productName, "",
          price, description, rating, createAt);
      bool isSuccess =
          await product_service.InsertProduct(product, selectedImage);
      if (isSuccess == false) {
        _isLoading = false;
        _SetError("Thêm sản phẩm thất bại");
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Lỗi không thể thêm sản phẩm (VM)) $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> ShowAllProduct(
      String query, String uid) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      List<Map<String, dynamic>> productData =
          await product_service.ShowAllProduct(query, uid);
      if (productData == null) {
        _isLoading = false;
        _SetError("Không tìm thấy sản phẩm nào");
        return null;
      }
      _isLoading = false;
      notifyListeners();
      return productData;
    } catch (e) {
      _SetError('Lỗi khi lấy thông tin sản phẩm $e');
      return null;
    }
  }

  Future<bool> DeleteProduct(String productId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (productId == null) {
        _isLoading = false;
        _SetError("Không tìm thấy id của sản phẩm");
        return false;
      }
      bool isSuccess = await product_service.DeleteProduct(productId);
      if (isSuccess == false) {
        _isLoading = false;
        _SetError("Xóa sản phẩm thất bại (VM)");
        return false;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _SetError("Lỗi khi xóa sản phẩm (VM)");
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      bool isSuccess = await product_service.UpdateProduct(productId,
          productName, categoryName, description, price, imageOld, newImage);
      if (isSuccess == false) {
        _isLoading = false;
        _SetError("Update sản phẩm thất bại");
        return false;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _SetError("Lỗi khi update sản phẩm $e");
      return false;
    }
  }

  void _SetError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
}
