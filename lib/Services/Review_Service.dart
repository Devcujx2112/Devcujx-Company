import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/Review.dart';

class Review_Service{
  static const String realTimeAPI =
      "https://test-login-lyasob-default-rtdb.firebaseio.com/Review";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> InsertReviewUser(Review review) async {
    try{
      Uri uri = Uri.parse("$realTimeAPI/${review.reviewId}.json");
      Map<String,dynamic> reviewData = {
        "ReviewId": review.reviewId,
        "ProductId": review.productId,
        "RepliesId": review.replies,
        "UserId": review.userId,
        "SellerId": review.sellerId,
        "Ratting": review.ratting,
        "CreateAt": review.createAt,
        "Comment": review.comment
      };
      final response = await http.put(uri,body: jsonEncode(reviewData));

      if(response.statusCode == 200 || response.statusCode == 201){
        return true;
      }
      return false;

    }catch(e) {
      print(e);
      return false;
    }
  }
}