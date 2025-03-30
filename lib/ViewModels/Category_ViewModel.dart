import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:order_food/Services/Category_Service.dart';
import 'package:uuid/uuid.dart';
import '../Helpers/ValidateInput.dart';

class Category_ViewModel extends ChangeNotifier{
  final Category_Service category_service = Category_Service();
  final ValidateInput _validateInput = ValidateInput();

  bool _isLoading = false;
  String? _errorMessage;
  String? _uid;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get uid => _uid;


  Future<bool> InsertCategory(String cateName, File? selectedImage) async {
    try{
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if(_validateInput.InputCategoryInsert(cateName) == false){
        _isLoading = false;
        _SetError("Vui lòng nhập tên danh mục");
        return false;
      }
      String cateID =  const Uuid().v4();
      bool isSuccess = await category_service.InsertCategory(cateName, selectedImage!,cateID);
      if(isSuccess == false){
        _isLoading = false;
        _SetError("Lỗi khi thêm category vào hệ thống (VM)");
        return false;
      }
      _uid = cateID;
      _isLoading = false;
      return true;

    }catch(e){
      _SetError("Lỗi khi thêm category vào hệ thống (VM) $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> ShowAllCategory(String query) async{
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      List<Map<String, dynamic>> category = await category_service.ShowAllCategory(query);
      if(category == null){
        _isLoading = false;
        _SetError("Không có danh mục sản phẩm nào");
        return null;
      }
      _isLoading = false;
      notifyListeners();
      return category;

    }catch(e){
      _SetError('Lỗi khi lấy tài khoản $e');
      return null;
    }
  }

  void _SetError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
}