import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/Models/ProfileUser.dart';

class Profile_Service {
  static const String realTimeAPI =
      "https://crud-firebase-7b852-default-rtdb.firebaseio.com";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> LoadEmailService(String uid) async {
    try {
      final String requestUrl =
          "$realTimeAPI/Account/${Uri.encodeComponent(uid)}.json";

      final response = await http.get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data != null && data.containsKey("Email")) {
          return data["Email"];
        } else {
          print("Không tìm thấy email cho UID: $uid");
          return null;
        }
      } else {
        print("Lỗi khi lấy email: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi truy vấn Firebase: $e");
      return null;
    }
  }

  Future<bool> CreateProfileUser(
      ProfileUser profile, File selectedImage) async {
    try {
      //Firebase Storage
      String fileName = "Profile/User/${profile.uid}.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(selectedImage);
      TaskSnapshot snapshot = await uploadTask;
      profile.image = await snapshot.ref.getDownloadURL();

      //Realtime Database
      Uri url = Uri.parse("$realTimeAPI/Profile/${profile.uid}.json");
      Map<String, dynamic> userData = {
        "Uid": profile.uid,
        "FullName": profile.fullName,
        "Year": profile.age,
        "Phone": profile.phone,
        "Gender": profile.gender,
        "Avatar": profile.image,
      };

      final response = await http.put(
        url,
        body: jsonEncode(userData),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("Profile đã được lưu vào Realtime Database!");
        return true;
      } else {
        print("Lỗi khi lưu dữ liệu: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Lỗi khi tạo profile: $e");
      return false;
    }
  }

  Future<bool> CreateProfileSeller(
      ProfileSeller profileSeller, File selectedImage) async {
    try {
      //Firebase Storage
      String fileName = "Profile/Seller/${profileSeller.uid}.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(selectedImage);
      TaskSnapshot snapshot = await uploadTask;
      profileSeller.image = await snapshot.ref.getDownloadURL();

      //Realtime Database
      Uri url = Uri.parse("$realTimeAPI/Profile/${profileSeller.uid}.json");
      Map<String, dynamic> userData = {
        "Uid": profileSeller.uid,
        "Avatar": profileSeller.image,
        "StoreName": profileSeller.storeName,
        "OwnerName": profileSeller.ownerName,
        "Phone": profileSeller.phone,
        "Address": profileSeller.address,
        "Bio": profileSeller.bio
      };

      final response = await http.put(
        url,
        body: jsonEncode(userData),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("profileSeller đã được lưu vào Realtime Database!");
        return true;
      } else {
        print("Lỗi khi lưu dữ liệu: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Lỗi khi tạo profileSellerSeller: $e");
      return false;
    }
  }

  Future<bool> SaveLocationStore(
      String uid, double latitude, double longitude) async {
    try {
      await FirebaseFirestore.instance
          .collection('locations')
          .doc(uid)
          .set({'latitude': latitude, 'longitude': longitude});
      return true;
    } catch (e) {
      print("Lỗi Service $e");
      return false;
    }
  }

  Future<List<double>?> LoadLocationStore(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('locations')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        double latitude = (data['latitude'] as num).toDouble();
        double longitude = (data['longitude'] as num).toDouble();
        return [latitude, longitude];
      } else {
        print("⚠️ Không tìm thấy dữ liệu vị trí.");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi LoadLocationStore: $e");
      return null;
    }
  }


}
