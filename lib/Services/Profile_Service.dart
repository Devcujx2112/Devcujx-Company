import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/Models/ProfileUser.dart';

class Profile_Service {
  static const String realTimeAPI =
      "https://test-login-lyasob-default-rtdb.firebaseio.com";
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> loadEmailService(String uid) async {
    try {
      final String requestUrl =
          "$realTimeAPI/Account/${Uri.encodeComponent(uid)}.json";
      final response = await http.get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);

        if (data != null && data.containsKey("Email")) {
          return data["Email"];
        } else {
          print("Không tìm thấy dữ liệu cho UID: $uid");
          return null;
        }
      } else {
        print("Lỗi khi lấy dữ liệu: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi truy vấn Firebase: $e");
      return null;
    }
  }

  Future<bool> CreateProfileUser(ProfileUser profile,
      File selectedImage) async {
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
        "Email": profile.email,
        "Role": profile.role,
        "FullName": profile.fullName,
        "Year": profile.age,
        "Phone": profile.phone,
        "Gender": profile.gender,
        "Avatar": profile.image,
        "Status": profile.status,
        "CreateAt": profile.createAt
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

  Future<bool> CreateProfileSeller(ProfileSeller profileSeller,
      File selectedImage) async {
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
        "Email": profileSeller.email,
        "Role": profileSeller.role,
        "Avatar": profileSeller.image,
        "StoreName": profileSeller.storeName,
        "OwnerName": profileSeller.ownerName,
        "Phone": profileSeller.phone,
        "Address": profileSeller.address,
        "Bio": profileSeller.bio,
        "Status": profileSeller.status,
        "CreateAt": profileSeller.createAt
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

  Future<bool> SaveLocationStore(String uid, double latitude,
      double longitude) async {
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

  Future<ProfileUser?> GetProfileUser(String uid) async {
    try {
      Uri url = Uri.parse("$realTimeAPI/Profile/$uid.json");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);

        if (data != null) {
          return ProfileUser.fromJson(uid, data);
        } else {
          print("Không tìm thấy thông tin người dùng!");
          return null;
        }
      } else {
        print("Lỗi khi lấy dữ liệu: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi truy vấn Firebase: $e");
      return null;
    }
  }

  Future<ProfileSeller?> GetProfileSeller(String uid) async {
    try {
      Uri url = Uri.parse("$realTimeAPI/Profile/$uid.json");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          ProfileSeller? profileSeller = ProfileSeller(
            uid,
            data["Email"] ?? "",
            data["Role"] ?? "",
            data["StoreName"] ?? "",
            data["Avatar"] ?? "",
            data["OwnerName"] ?? "",
            data["Phone"] ?? "",
            data["Address"] ?? "",
            data["Bio"] ?? "",
            data["Status"] ?? "",
            data["CreateAt"] ?? "",
          );
          return profileSeller;
        } else {
          print("Không tìm thấy thông tin người dùng!");
          return null;
        }
      } else {
        print("Lỗi khi lấy dữ liệu: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi truy vấn Firebase: $e");
      return null;
    }
  }

  Future<Map<String, int>> getCountUserSeller() async {
    try {
      Uri url = Uri.parse("$realTimeAPI/Profile.json");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        int userCount = 0;
        int sellerCount = 0;

        data.forEach((key, value) {
          if (value["Role"] == "User") {
            userCount++;
          } else if (value["Role"] == "Seller") {
            sellerCount++;
          }
        });
        print('Account Vm u $userCount');
        print('Account VM s $sellerCount');
        return {
          "User": userCount,
          "Seller": sellerCount,
        };
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      print("Error: $e");
      return {
        "User": 0,
        "Seller": 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> LoadAllAccount() async {
    try {
      final response = await http.get(Uri.parse("$realTimeAPI/Profile.json"));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);

        if (data == null) return [];

        return data.entries
            .where((entry) =>
        (entry.value as Map<String, dynamic>)["Role"]?.toString() !=
            "Admin")
            .map((entry) {
          return {
            "id": entry.key, // Lưu lại key làm ID
            ...entry.value as Map<String, dynamic>, // Ép kiểu dữ liệu
          };
        }).toList();
      } else {
        throw Exception("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi load tài khoản: $e");
      return [];
    }
  }

  Future<bool> UpdateStatusAccount(String uid, String status) async {
    try{
      final String requestUrl = "$realTimeAPI/Profile/$uid.json";
      final String requestUrl2 = "$realTimeAPI/Account/$uid.json";
      final response = await http.patch(Uri.parse(requestUrl),
          body: jsonEncode({"Status": status}));
      final response2 = await http.patch(Uri.parse(requestUrl2),
          body: jsonEncode({"Status": status}));

      if (response.statusCode == 200 && response2.statusCode == 200) {
        print("Update role successfully!");
        return true;
      } else {
        print("Failed to update role: ${response.body}");
        return false;
      }
    }catch(e){
      print(e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> ShowAllLocationStore() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('locations')
          .get();

      List<Map<String, dynamic>> locations = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      return locations;
    } catch (e) {
      print("Lỗi khi lấy dữ liệu locations: $e");
      throw e;
    }
  }
}
