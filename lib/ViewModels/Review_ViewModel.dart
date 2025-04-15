import 'package:flutter/material.dart';
import 'package:order_food/Models/Review.dart';
import 'package:order_food/Services/Order_Service.dart';
import 'package:order_food/Services/Review_Service.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

class Review_ViewModel extends ChangeNotifier {
  final Review_Service review_service = Review_Service();
  final Order_Service order_service = Order_Service();

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<bool> InsertReviewUser(String productId, String userId,
      String sellerId, int ratting, String comment, String orderId) async {
    try {
      _errorMessage = null;
      String reviewId = const Uuid().v4();
      String replies = "";
      String dateTime = DateTime.now().toString();
      Review review = Review(
          reviewId,
          productId,
          replies,
          userId,
          sellerId,
          ratting,
          dateTime,
          comment);

      bool isSuccess = await review_service.InsertReviewUser(review);
      if(isSuccess == false){
        _SetError("Gửi đánh giá sản phẩm thất bại");
        return false;
      }
      String update = "done";
      bool updateComment = await order_service.UpdateCommentOrder(orderId, update);
      if(updateComment == false){
        _SetError("Lỗi khi update comment order");
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Lỗi khi gửi đánh giá sản phẩm $e");
      return false;
    }
  }

  void _SetError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
