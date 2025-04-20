import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/Replies.dart';
import 'package:order_food/Models/Review.dart';

class Review_Service {
  static const String realTimeAPI =
      "https://test-login-lyasob-default-rtdb.firebaseio.com";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> InsertReviewUser(Review review) async {
    try {
      Uri uri = Uri.parse("$realTimeAPI/Review/${review.reviewId}.json");
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
      final response = await http.get(Uri.parse("$realTimeAPI/Review.json"));
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
      String comment, String reviewId, double ratting, String dateTime) async {
    try {
      Map<String, dynamic> data = {
        "Comment": comment,
        "Ratting": ratting,
        "CreateAt": dateTime
      };
      final response = await http.patch(
        Uri.parse("$realTimeAPI/Review/$reviewId.json"),
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
          await http.delete(Uri.parse("$realTimeAPI/Review/$reviewID.json"));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
  Future<bool> DeleteReplies(String replies) async {
    try {
      final response =
      await http.delete(Uri.parse("$realTimeAPI/Replies/$replies.json"));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> InsertRepliesComment(Replies replies) async {
    try {
      Uri uri = Uri.parse("$realTimeAPI/Replies/${replies.repliesId}.json");
      Map<String, dynamic> repliesData = {
        "RepliesId": replies.repliesId,
        "ReviewId": replies.reviewId,
        "SellerId": replies.sellerId,
        "RepText": replies.repText,
        "CreateAt": replies.createAt
      };
      final response = await http.put(uri, body: jsonEncode(repliesData));

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> data = {
          "RepliesId": replies.repliesId,
        };
        final response = await http.patch(
          Uri.parse("$realTimeAPI/Review/${replies.reviewId}.json"),
          body: jsonEncode(data),
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        }
        return false;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Replies>?> ShowRepliesComment(String reviewId) async {
    try {
      Uri uri = Uri.parse("$realTimeAPI/Replies.json");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data == null || data.isEmpty) {
          print('Không có phản hồi');
          return null;
        }

        final List<Replies> repliesList = data.entries
            .where((entry) =>
                entry.value["ReviewId"] == reviewId)
            .map((entry) => Replies(
                  entry.key,
                  entry.value["ReviewId"],
                  entry.value["SellerId"],
                  entry.value["RepText"],
                  entry.value["CreateAt"],
                ))
            .toList();

        if (repliesList.isEmpty) {
          print('Không tìm thấy phản hồi cho reviewId: $reviewId');
          return null;
        }
        return repliesList;
      } else {
        print('Lỗi khi truy vấn: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("Lỗi trong Service: $e");
      return null;
    }
  }
}
