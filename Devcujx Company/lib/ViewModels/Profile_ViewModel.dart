import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/Models/ProfileUser.dart';
import 'package:order_food/Services/Profile_Service.dart';
import '../Helpers/ValidateInput.dart';

class Profile_ViewModel extends ChangeNotifier {
  final Profile_Service profile_service = Profile_Service();
  final ValidateInput _validateInput = ValidateInput();

  bool _isLoading = false;
  String? _errorMessage;
  String? _uid;
  String? _email;
  String? _role;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get uid => _uid;

  String? get email => _email;

  String? get role => _role;

  Future<bool> LoadEmailAccount(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (uid.isEmpty) {
        _isLoading = false;
        _SetError("Không tìm thấy uid của tài khoản (Vm)");
        return false;
      }
      String? loadData = await profile_service.loadEmailService(uid);
      if (loadData == null) {
        _isLoading = false;
        _SetError("Không lấy được Email");
        return false;
      }
      _email = loadData;
      print('VM $_email');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _SetError("Lỗi khi load Email (VM) $e");
      return false;
    }
  }

  Future<bool> CreateProfileUserVM(ProfileUser profile,
      File? selectedImage) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (selectedImage == null) {
        print("Không có ảnh được chọn, sử dụng ảnh mặc định.");

        ByteData byteData =
        await rootBundle.load("asset/images/avatar_default.jpg");
        Uint8List imageData = byteData.buffer.asUint8List();
        File tempFile = File("${Directory.systemTemp.path}/avatar_default.jpg");
        await tempFile.writeAsBytes(imageData);
        selectedImage = tempFile;
      }

      profile = ProfileUser(
          uid: profile.uid,
          fullName: profile.fullName,
          email: profile.email,
          role: profile.role,
          image: "",
          phone: profile.phone,
          age: profile.age,
          gender: profile.gender,
          status: profile.status,
          createAt: profile.createAt);
      bool success =
      await profile_service.CreateProfileUser(profile, selectedImage);
      if (success == false) {
        _isLoading = false;
        print('KHông thể tạo profile');
        _SetError("Lỗi khi khởi tạo profile");
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Lỗi upload profile $e");
      _SetError("Có lỗi xảy ra khi tạo profile");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> CreateProfileSeller(ProfileSeller profileSeller,
      File selectedImage) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool success = _validateInput.InputCreateProfile(profileSeller);
      if (success == false) {
        _SetError("Vui lòng điền đầy đủ thông tin");
        _isLoading = false;
        notifyListeners();
        return false;
      }

      profileSeller = ProfileSeller(
          profileSeller.uid,
          profileSeller.email,
          profileSeller.role,
          profileSeller.storeName,
          profileSeller.image,
          profileSeller.ownerName,
          profileSeller.phone,
          profileSeller.address,
          profileSeller.bio,
          profileSeller.status,
          profileSeller.createAt);

      bool queryRealtime = await profile_service.CreateProfileSeller(
          profileSeller, selectedImage);
      if (queryRealtime == false) {
        _isLoading = false;
        _SetError("Tạo Profile thất bại");
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Lỗi upload profile $e");
      _SetError("Có lỗi xảy ra khi tạo profile");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> SaveLocationStore(String uid, double latitude,
      double longitude) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool success =
      await profile_service.SaveLocationStore(uid, latitude, longitude);
      if (success == false) {
        _isLoading = false;
        _SetError("Lưu vị trí cửa hàng thất bại");
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      notifyListeners();
      return false;
    }
  }

  Future<List<double>?> LoadLocationStore(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    List<double>? location = [];
    try {
      if (uid.isEmpty) {
        _isLoading = false;
        _SetError("Không lấy được UID của tài khoản");
        return null;
      }
      location = await profile_service.LoadLocationStore(uid);
      _isLoading = false;
      notifyListeners();
      return location;
    } catch (e) {
      _isLoading = false;
      _SetError("Lỗi khi lấy vị trí cửa hàng : $e");
      notifyListeners();
      return null;
    }
  }

  Future<ProfileUser?> GetAllDataProfileUser(String uid) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      ProfileUser? user = await profile_service.GetProfileUser(uid);
      if (user != null) {
        return user;
      } else {
        _isLoading = false;
        _SetError("Không tìm thấy dữ liệu người dùng");
        return null;
      }
    } catch (e) {
      _SetError("Lỗi khi nhận dữ liệu từ database $e");
      notifyListeners();
      return null;
    }
  }

  Future<ProfileSeller?> GetAllDataProfileSeller(String uid) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      ProfileSeller? user = await profile_service.GetProfileSeller(uid);
      if (user != null) {
        return user;
      } else {
        _isLoading = false;
        _SetError("Không tìm thấy dữ liệu cửa hàng");
        return null;
      }
    } catch (e) {
      _SetError("Lỗi khi nhận dữ liệu từ database $e");
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, int>> GetCountSellerUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, int>? counts = await profile_service.getCountUserSeller();

      if (counts != null) {
        _isLoading = false;
        notifyListeners();
        return {
          "User": counts["User"] ?? 0,
          "Seller": counts["Seller"] ?? 0,
        };
      } else {
        _isLoading = false;
        _SetError("Dữ liệu trống!");
        throw Exception("Dữ liệu trống!");
      }
    } catch (e) {
      _SetError("Lỗi: $e");
      _isLoading = false;
      notifyListeners();
      return {"User": 0, "Seller": 0};
    }
  }


  Future<List<Map<String, dynamic>>?> LoadAllAccount() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      List<Map<String, dynamic>> accounts = await profile_service
          .LoadAllAccount();
      if (accounts == null) {
        _isLoading = false;
        _SetError("Không có Account");
        return null;
      }
      _isLoading = false;
      notifyListeners();
      return accounts;
    } catch (e) {
      _SetError('Lỗi khi lấy tài khoản $e');
      notifyListeners();
      return null;
    }
  }

  Future<bool> UpdateStatusAccount(String uid, String status) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      bool success = await profile_service.UpdateStatusAccount(uid, status);
      if (success == false) {
        _isLoading = false;
        _SetError("Lỗi khi chỉnh sửa thông tin User");
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _SetError("Lỗi khi update status Account $e");
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> ShowAllLocationStore() async {
    try {
      List<Map<String, dynamic>> dataLocation = await profile_service
          .ShowAllLocationStore();
      if (dataLocation == null) {
        _SetError("Không tìm thấy vị trí của cửa hàng");
        return null;
      }

      notifyListeners();
      return dataLocation;
    } catch (e) {
      _SetError("Lỗi khi tải vị trí của cửa hàng");
      notifyListeners();
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> ShowStoreNear(
      double latitudeUser,
      double longitudeUser,
      ) async {
    try {
      List<Map<String, dynamic>>? dataStore = await profile_service.ShowAllLocationStore();

      if (dataStore == null || dataStore.isEmpty) {
        _SetError("Không tìm thấy cửa hàng nào");
        return null;
      }

      for (var store in dataStore) {
        final lat = store['latitude'] as double? ?? 0;
        final lng = store['longitude'] as double? ?? 0;
        final distance = _calculateDistance(latitudeUser, longitudeUser, lat, lng);
        store['distance_km'] = double.parse(distance.toStringAsFixed(2));
      }

      dataStore.sort((a, b) => (a['distance_km'] as double).compareTo(b['distance_km'] as double));

      final nearestStores = dataStore.take(2).toList();

      return nearestStores.map((store) {
        store['distance_text'] = '${store['distance_km']} km';
        return store;
      }).toList();

    } catch (e) {
      _SetError("Lỗi khi tìm cửa hàng: ${e.toString()}");
      return null;
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2,
      double lon2) {
    const R = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<bool> UpdateProfileUser(String uid, String fullName, String phone,
      String age, String gender, String imageOld, File? newImage) async{
    try{
      _errorMessage = null;
      bool isSuccess = await profile_service.UpdateProfileUser(uid, fullName, phone, age, gender, imageOld, newImage);
      if(isSuccess == false){
        _SetError("Sửa thông tin cá nhân thất bại");
        return false;
      }
      return true;

    }catch(e){
      print(e);
      return false;
    }
  }

  Future<bool> UpdateProfileSeller(String uid, String oldImage, String storeName,
      String ownerName, String phone, String address, String bio, File? newImage) async{
    try{
      _errorMessage = null;
      bool isSuccess = await profile_service.UpdateProfileSeller(uid, oldImage, storeName,ownerName,phone,address,bio,newImage);
      if(isSuccess == false){
        _SetError("Sửa thông tin cá nhân thất bại");
        return false;
      }
      return true;

    }catch(e){
      print(e);
      return false;
    }
  }

  void _SetError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
}
