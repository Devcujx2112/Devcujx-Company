class ProfileUser {
  String uid;
  String fullName;
  String image;
  String phone;
  String age;
  String gender;

  ProfileUser({
    required this.uid,
    required this.fullName,
    required this.image,
    required this.phone,
    required this.age,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'image': image,
      'phone': phone,
      'age': age,
      'gender': gender,
    };
  }
}
