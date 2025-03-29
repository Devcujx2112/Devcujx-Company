class ProfileUser {
  String uid;
  String email;
  String role;
  String fullName;
  String image;
  String phone;
  String age;
  String gender;
  String status;
  String createAt;

  ProfileUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.fullName,
    required this.image,
    required this.phone,
    required this.age,
    required this.gender,
    required this.status,
    required this.createAt
  });

  factory ProfileUser.fromJson(String uid, Map<String, dynamic> json) {
    return ProfileUser(
      uid: uid,
      email: json['Email'],
      role: json['Role'],
      fullName: json['FullName'],
      image: json['Avatar'],
      phone: json['Phone'] ?? 'Unknow',
      age: json['Year']?? 'Unknow',
      gender: json['Gender']?? 'Unknow',
      status: json['Status'],
      createAt: json['CreateAt']
    );
  }
}
