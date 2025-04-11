import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/ProfileUser.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:provider/provider.dart';

class ProfileUserDetail extends StatefulWidget {
  final ProfileUser profileUser;

  const ProfileUserDetail({super.key, required this.profileUser});

  @override
  State<ProfileUserDetail> createState() => _ProfileUserDetailState();
}

class _ProfileUserDetailState extends State<ProfileUserDetail> {
  bool _isLoading = false;
  late ProfileUser profileUserData;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  File? _avatar;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _avatar = File(pickedImage.path);
      });
    }
  }

  void _loadAllData() {
    setState(() {
      profileUserData = widget.profileUser;
      _fullNameController.text = profileUserData.fullName ?? '';
      _phoneController.text = profileUserData.phone ?? '';
      _ageController.text = profileUserData.age ?? '';
      _selectedGender = profileUserData.gender;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: _isLoading,
        progressIndicator:
        LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileImage(),
                const SizedBox(height: 30),
                _buildInfoForm(),
                const SizedBox(height: 40),
                _buildUpdateButton(),
              ],
            ),
          ),
          appBar: AppBar(
            title: const Text('Chỉnh sửa hồ sơ',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.green[700],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context,true),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
        ));
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[700]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _avatar == null
                      ? NetworkImage(profileUserData.image!)
                      : FileImage(_avatar!),
                  child: profileUserData.image == null
                      ? const Icon(Icons.person, size: 48, color: Colors.grey)
                      : null,
                ),
              )),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child:
              const Icon(Icons.camera_alt, size: 22, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCustomTextField(
            controller: _fullNameController,
            label: 'Họ và tên',
            icon: Icons.person_outline,
            isEditable: true,
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            label: 'Email',
            icon: Icons.email_outlined,
            value: profileUserData.email,
            isEditable: false,
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            label: 'Vai trò',
            icon: Icons.people_outline,
            value: profileUserData.role == "User" ? "Người mua hàng" : "Admin",
            isEditable: false,
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            controller: _phoneController,
            label: 'Số điện thoại',
            icon: Icons.phone_outlined,
            isEditable: true,
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            controller: _ageController,
            label: 'Năm sinh',
            icon: Icons.calendar_today_outlined,
            isEditable: true,
          ),
          const SizedBox(height: 20),
          _buildGenderDropdown(),
          const SizedBox(height: 20),
          _buildCustomTextField(
            label: 'Trạng thái',
            icon: Icons.verified_outlined,
            value: profileUserData.status == "Active"
                ? "Đang hoạt động"
                : "Không xác định",
            isEditable: false,
            iconColor: Colors.green,
          ),
          const SizedBox(height: 20),
          _buildCustomTextField(
            label: 'Ngày tạo',
            icon: Icons.date_range_outlined,
            value: profileUserData.createAt != null
                ? _dateFormat.format(DateTime.parse(profileUserData.createAt))
                : 'Không có ngày tạo',
            isEditable: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    TextEditingController? controller,
    String? label,
    IconData? icon,
    String? value,
    required bool isEditable,
    Color iconColor = Colors.green,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? value : null,
      readOnly: !isEditable,
      style: TextStyle(
          color: isEditable ? Colors.black : Colors.grey[600],
          fontWeight: FontWeight.w500,
          fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        prefixIcon: icon != null ? Icon(icon, color: iconColor) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green[400]!, width: 1.5),
        ),
        filled: true,
        fillColor: isEditable ? Colors.white : Colors.grey[100],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    final genderOptions = {'Male': 'Nam', 'Female': 'Nữ', 'Other': 'Khác'};

    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Giới tính',
        labelStyle:
        const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        prefixIcon: const Icon(Icons.transgender_outlined, color: Colors.green),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green[400]!, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: genderOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedGender = newValue;
          });
        }
      },
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildUpdateButton() {
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.green.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () async {
          if (_fullNameController.text.isEmpty ||
              _phoneController.text.isEmpty || _ageController.text.isEmpty ||
              _selectedGender!.isEmpty) {
            showDialogMessage(
                context, "Vui lòng điền đủ thông tin", DialogType.warning);
          }
          else {
            setState(() {
              _isLoading = true;
            });
            bool isSuccess = await profileVM.UpdateProfileUser(
                widget.profileUser.uid,
                _fullNameController.text,
                _phoneController.text,
                _ageController.text,
                _selectedGender!,
                widget.profileUser.image,
                _avatar);
            if(isSuccess){
              setState(() {
                _isLoading = false;
              });
              showDialogMessage(context, "Chỉnh sửa thông tin cá nhân thành công", DialogType.success);
            }
            else{
              setState(() {
                _isLoading = false;
              });
              showDialogMessage(context, "Chỉnh sửa thông tin thất bại ${profileVM.errorMessage}",DialogType.error);
            }
          }
        },
        child: const Text(
          'CẬP NHẬT THÔNG TIN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
