import 'dart:io';

import 'package:flutter/material.dart';
import 'package:order_food/Models/Favorite.dart';
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
      String storeName,
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
      Product product = Product(productId, uid, storeName, categoryName,
          productName, "", price, description, rating, createAt);
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

  Future<List<Map<String, dynamic>>?> SearchProductFormCategory(
      String categoryName) async {
    try {
      _errorMessage = null;
      notifyListeners();

      List<Map<String, dynamic>>? productData =
          await product_service.SearchProductFormCategory(categoryName);
      if (productData == null) {
        _SetError("Không tìm thấy sản phẩm cho danh mục $categoryName");
        return null;
      }

      notifyListeners();
      return productData;
    } catch (e) {
      _SetError("Lỗi khi tìm sản phẩm $e");
      return null;
    }
  }

  Future<bool> InsertFavorite(String productId, String uid) async {
    try {
      _errorMessage = null;
      notifyListeners();
      String favoriteId = const Uuid().v4();
      Favorite favorite = Favorite(favoriteId, uid, productId);
      bool _isSuccess = await product_service.InsertFavoriteProduct(favorite);

      if (_isSuccess == false) {
        _SetError("Thêm sản phẩm yêu thích thất bại");
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Có lỗi khi thêm sản phẩm yêu thích");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> ShowAllFavoriteProduct(String uid) async {
    try {
      _errorMessage = null;
      List<Map<String, dynamic>>? data =
          await product_service.ShowAllFavoriteProduct(uid);
      if (data == null) {
        _SetError("Không có sản phẩm yêu thích");
        return [];
      }
      return data;
    } catch (e) {
      _SetError("Lỗi khi tải dữ liệu");
      return null;
    }
  }
  //
  // Future<List<Map<String, dynamic>>?> ShowAllProductFormProductId(
  //     String productId) async {
  //   try {
  //     _errorMessage = null;
  //     notifyListeners();
  //
  //     List<Map<String, dynamic>>? productData =
  //         await product_service.SearchProductFormProductId(productId);
  //     if (productData == null) {
  //       _SetError("Không tìm thấy sản phẩm ");
  //       return null;
  //     }
  //
  //     notifyListeners();
  //     return productData;
  //   } catch (e) {
  //     _SetError("Lỗi khi tìm sản phẩm $e");
  //     return null;
  //   }
  // }

  Future<List<Map<String, dynamic>>> ShowAllProductById(
      List<String> productId) async {
    try {
      _errorMessage = null;
      List<Map<String, dynamic>> allProduct = [];
      allProduct = await product_service.GetAllProductById(productId);
      if (allProduct.isEmpty) {
        return [];
      }
      return allProduct;
    } catch (e) {
      _SetError("Lỗi khi tìm kiếm sản phẩm qua id $e");
      return [];
    }
  }

  Future<String?> GetFavoriteId(List<Map<String, dynamic>> favoriteList,
      String productId, String uid) async {
    try {
      _errorMessage = null;
      final favoriteItem = favoriteList.firstWhere(
        (item) =>
            item['ProductId'].toString() == productId &&
            item['Uid'].toString() == uid,
        orElse: () => <String, dynamic>{},
      );
      notifyListeners();
      return favoriteItem.isNotEmpty
          ? favoriteItem['FavoriteId'].toString()
          : null;
    } catch (e) {
      _SetError("Lỗi khi tìm kiếm id sản phẩm yêu thích");
      return null;
    }
  }

  Future<bool> DeleteFavoritProduct(String favoriteId) async {
    try {
      _errorMessage = null;
      bool isSuccess = await product_service.DeleteFavoriteProduct(favoriteId);
      if (isSuccess == false) {
        _SetError("Không thể xóa sản phẩm yêu thích");
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Ngoại lệ khi xóa sản phẩm $e");
      return false;
    }
  }

  Future<Product?> ShowAllProductFormProductId(String productId) async {
    try{
      _errorMessage = null;
      Product? product = await product_service.ShowAllProductFormProductId(productId);
      if(product == null){
        _SetError("Không có sản phẩm nào");
        return null;
      }
      notifyListeners();
      return product;
    }catch(e){
      _SetError("Lỗi khi show sản phẩm $e");
      return null;
    }
  }
}
