import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../ViewModels/Auth_ViewModel.dart';

class CreateProfileUser extends StatefulWidget {
  String uid;
  CreateProfileUser({super.key, required this.uid});

  @override
  State<CreateProfileUser> createState() => _CreateProfileUserState();
}

class _CreateProfileUserState extends State<CreateProfileUser> {
  String selectedGender = "Male";
  TextEditingController txtFullName = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtAge = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Phần xám trên cùng
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 180,
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

              // Form nhập liệu (Khoảng cách giữa các TextField đồng đều)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Email"),
                      _buildReadOnlyTextField("dev.duongvu2112@gmail.com"),
                      const SizedBox(height: 15),

                      _buildLabel("Full Name"),
                      _buildTextField(controller: txtFullName),
                      const SizedBox(height: 15),

                      _buildLabel("Phone Number"),
                      _buildTextField(controller: txtPhone, isNumber: true, maxLength: 10),
                      const SizedBox(height: 15),

                      _buildLabel("Year of Birth"),
                      _buildTextField(controller: txtAge, isNumber: true, maxLength: 4),
                      const SizedBox(height: 15),

                      _buildLabel("Gender"),
                      _buildGenderDropdown(),
                    ],
                  ),
                ),
              ),

              // Nút Submit
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Create User "+ authVM.uid.toString());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
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

          // Avatar
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                const AssetImage('asset/images/default_avatar.png'),
                backgroundColor: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị tiêu đề cho mỗi TextField
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: "Poppins",
        color: Colors.grey,
        fontWeight: FontWeight.bold
      ),
    );
  }

  /// Ô nhập liệu có thể chỉnh sửa
  Widget _buildTextField({required TextEditingController controller, bool isNumber = false, int? maxLength}) {
    return TextField(
      style: const TextStyle(fontFamily: "Outfit", fontSize: 15),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: "", // Ẩn số ký tự nhập vào
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
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
      style: const TextStyle(fontFamily: "Outfit", fontSize: 15),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      controller: TextEditingController(text: value),
    );
  }

  /// Dropdown chọn giới tính
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      style: const TextStyle(fontFamily: "Outfit", color: Colors.black, fontSize: 16),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
