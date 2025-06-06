import 'package:order_food/Models/ProfileSeller.dart';

class ValidateInput {
  bool isValidEmail(String email) {
    String emailPattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  bool LenghtPassword(String password) {
    if (password.length < 6) {
      return false;
    }
    return true;
  }

  bool InputCreateProfile(ProfileSeller profile) {
    if (profile.storeName.isNotEmpty &&
        profile.phone.isNotEmpty &&
        profile.address.isNotEmpty &&
        profile.bio.isNotEmpty &&
        profile.ownerName.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  bool InputCategoryInsert(String cateName) {
    if (cateName
        .trim()
        .isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool InputProduct(String uid,
      String categoryName,
      String productName,
      int price,
      String description){
    if(uid.isEmpty || categoryName.isEmpty || productName.isEmpty || price == null || description.isEmpty){
      return false;
    }
    return true;
  }
}
