import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_food/Models/Account.dart';
import 'package:order_food/Models/ProfileUser.dart';
import 'package:order_food/View/Page/Login/Login_Page.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:provider/provider.dart';

import '../../../ViewModels/Auth_ViewModel.dart';
import '../../Widget/DialogMessage_Form.dart';

class CreateProfileUser extends StatefulWidget {
  const CreateProfileUser({super.key});

  @override
  State<CreateProfileUser> createState() => _CreateProfileUserState();
}

class _CreateProfileUserState extends State<CreateProfileUser> {
  Profile_ViewModel profileViewModel = Profile_ViewModel();

  File? _selectedImage;
  String selectedGender = "Male";
  TextEditingController txtFullName = TextEditingController();
  TextEditingController? txtPhone = TextEditingController();
  TextEditingController? txtAge = TextEditingController();
  String? email;
  String? fullName;
  late String uid;
  String role = "User";
  String createAt = DateTime.now().toIso8601String();
  String status = "Active";

  Future<void> LoadEmail(String uid) async {
    if (uid.isNotEmpty) {
      final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
      bool success = await profileVM.LoadEmailAccount(uid);
      if (success) {
        setState(() {
          email = profileVM.email!;
        });
      }
    }
  }

  Future<void> _PickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (authVM.uid != null) {
        uid = authVM.uid!;
        LoadEmail(authVM.uid!);
      }
    });
    txtFullName.addListener(() {
      setState(() {
        fullName = txtFullName.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: true);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Container(
                  width: double.infinity,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFC5C5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Email"),
                      _buildReadOnlyTextField(email ?? "Loading..."),
                      const SizedBox(height: 15),
                      _buildLabel("Full Name"),
                      _buildTextField(controller: txtFullName),
                      const SizedBox(height: 15),
                      _buildLabel("Phone Number"),
                      _buildTextField(
                          controller: txtPhone!, isNumber: true, maxLength: 10),
                      const SizedBox(height: 15),
                      _buildLabel("Year of Birth"),
                      _buildTextField(
                          controller: txtAge!, isNumber: true, maxLength: 4),
                      const SizedBox(height: 15),
                      _buildLabel("Gender"),
                      _buildGenderDropdown(),
                    ],
                  ),
                ),
              ),

              // Nút Submit
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      ProfileUser? profile = ProfileUser(
                          uid: uid,
                          email: email!,
                          role: role,
                          fullName: fullName ?? "",
                          image: "",
                          phone: txtPhone?.text ?? "",
                          age: txtAge?.text ?? "",
                          gender: selectedGender,
                          status: status,
                          createAt: createAt);
                      bool success = await profileVM.CreateProfileUserVM(
                          profile, _selectedImage);
                      if (success) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                        showDialogMessage(context, "Tạo profile thành công",
                            DialogType.success);
                      } else {
                        showDialogMessage(
                            context, "Tạo profile thất bại", DialogType.error);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: profileVM.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white, // Đổi màu phù hợp với nút
                            ),
                          )
                        : const Text(
                            "SUBMIT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),

          // Avatar + Tên
          Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _PickImage,
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : const AssetImage('asset/images/avatar_default.jpg')
                              as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fullName?.isNotEmpty == true ? fullName! : "Your name",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Hiển thị tiêu đề cho mỗi TextField
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13,
          fontFamily: "Poppins",
          color: Colors.grey,
          fontWeight: FontWeight.bold),
    );
  }

  /// Ô nhập liệu có thể chỉnh sửa
  Widget _buildTextField(
      {required TextEditingController controller,
      bool isNumber = false,
      int? maxLength}) {
    return TextField(
      style: const TextStyle(fontFamily: "Poppins", fontSize: 13),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: "",
        contentPadding:
        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      controller: controller,
    );
  }

  /// Ô nhập liệu chỉ đọc
  Widget _buildReadOnlyTextField(String value) {
    return TextField(
      readOnly: true,
      style: const TextStyle(fontFamily: "Poppins", fontSize: 13),
      decoration: InputDecoration(
        contentPadding:
        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      controller: TextEditingController(text: value),
    );
  }

  /// Dropdown chọn giới tính
  Widget _buildGenderDropdown() {
    return Container(
      width: 150,
      child: DropdownButtonFormField<String>(
        style: const TextStyle(
            fontFamily: "Outfit", color: Colors.black, fontSize: 14),
        value: selectedGender,
        items: ["Male", "Female"].map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedGender = newValue!;
          });
        },
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
