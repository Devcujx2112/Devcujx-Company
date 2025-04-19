import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/Review.dart';

class Review_Service {
  static const String realTimeAPI =
      "https://test-login-lyasob-default-rtdb.firebaseio.com/Review";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> InsertReviewUser(Review review) async {
    try {
      Uri uri = Uri.parse("$realTimeAPI/${review.reviewId}.json");
      Map<String, dynamic> reviewData = {
        "ReviewId": review.reviewId,
        "ProductId": review.productId,
        "RepliesId": review.replies,
        "UserId": review.userId,
        "SellerId": review.sellerId,
        "Ratting": review.ratting,
        "CreateAt": review.createAt,
        "Comment": review.comment
      };
      final response = await http.put(uri, body: jsonEncode(reviewData));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> ShowAllCommentProduct(
      String productId) async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI.json"));
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data == null) return [];

        List<Map<String, dynamic>> reviewData = data.entries
            .map((entry) => {
                  "ReviewId": entry.key,
                  ...(entry.value as Map<String, dynamic>),
                })
            .toList();

        reviewData =
            reviewData.where((id) => id["ProductId"] == productId).toList();

        return reviewData;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<bool> UpdateComment(
      String comment, String reviewId, double ratting) async {
    try {
      Map<String, dynamic> data = {"Comment": comment, "Ratting": ratting};
      final response = await http.patch(
        Uri.parse("$realTimeAPI/$reviewId.json"),
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> DeleteComment(String reviewID) async {
    try {
      final response =
          await http.delete(Uri.parse("$realTimeAPI/$reviewID.json"));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
