import 'dart:io';
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

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get uid => _uid;

  String? get email => _email;

  Future<bool> LoadEmailAccount(String uid) async {
    _errorMessage = null;
    notifyListeners();

    if (uid.isNotEmpty) {
      _email = await profile_service.LoadEmailService(uid);
      _isLoading = false;
      return true;
    } else {
      _SetError("Lỗi tài khoản vui lòng đăng nhập lại");
      return false;
    }
  }

  Future<bool> CreateProfileUserVM(ProfileUser profile,
      File? selectedImage) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
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
          image: "",
          phone: profile.phone,
          age: profile.age,
          gender: profile.gender);
      bool success =
      await profile_service.CreateProfileUser(profile, selectedImage);
      if (success == false) {
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
        return false;
      }

      profileSeller = ProfileSeller(
          profileSeller.uid,
          profileSeller.storeName,
          profileSeller.image,
          profileSeller.ownerName,
          profileSeller.phone,
          profileSeller.address,
          profileSeller.bio);

      bool queryRealtime = await profile_service.CreateProfileSeller(profileSeller, selectedImage);
      if(queryRealtime == false){
        _isLoading = false;
        _SetError("Tạo Profile thất bại");
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

  void _SetError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
}
