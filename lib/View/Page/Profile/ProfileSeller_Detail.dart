import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:provider/provider.dart';

import '../../../Models/ProfileSeller.dart';
import 'GoogleMap_Page.dart';

class ProfileSellerDetail extends StatefulWidget {
  ProfileSeller dataSeller;

  ProfileSellerDetail({super.key, required this.dataSeller});

  @override
  State<ProfileSellerDetail> createState() => _ProfileSellerDetailState();
}

class _ProfileSellerDetailState extends State<ProfileSellerDetail> {
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color lightGreen = const Color(0xFFC8E6C9);
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color accentGreen = const Color(0xFF81C784);
  File? _avatar;
  String uid = "";
  bool _isLoading = true;

  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ShowAllData();
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

  void ShowAllData() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (widget.dataSeller != null) {
      setState(() {
        uid = authVM.uid!;
        _storeNameController.text = widget.dataSeller.storeName;
        _ownerNameController.text = widget.dataSeller.ownerName;
        _phoneController.text = widget.dataSeller.phone;
        _addressController.text = widget.dataSeller.address;
        _bioController.text = widget.dataSeller.bio;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return ModalProgressHUD(
        inAsyncCall: _isLoading,
        progressIndicator:
            LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Thông tin cửa hàng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            centerTitle: true,
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context, true)),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header với avatar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: lightGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryGreen, accentGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _avatar == null
                                  ? NetworkImage(widget.dataSeller.image)
                                  : FileImage(_avatar!),
                              child: widget.dataSeller.image == null
                                  ? const Icon(Icons.person,
                                      size: 48, color: Colors.grey)
                                  : null,
                            ),
                          )),
                      const SizedBox(height: 10),
                      Text(
                        widget.dataSeller.storeName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                _buildInfoSection(
                  title: 'Thông tin cửa hàng',
                  icon: Icons.store_mall_directory_outlined,
                  children: [
                    _buildEditableField(
                      label: 'Tên cửa hàng',
                      controller: _storeNameController,
                      icon: Icons.badge_outlined,
                    ),
                    _buildEditableField(
                      label: 'Tên chủ cửa hàng',
                      controller: _ownerNameController,
                      icon: Icons.person_outline,
                    ),
                    _buildReadOnlyField(
                      label: 'Email',
                      value: widget.dataSeller.email,
                      icon: Icons.email_outlined,
                    ),
                    _buildReadOnlyField(
                      label: 'Vai trò',
                      value: widget.dataSeller.role,
                      icon: Icons.work_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _buildInfoSection(
                  title: 'Liên hệ',
                  icon: Icons.contact_phone_outlined,
                  children: [
                    _buildEditableField(
                      label: 'Số điện thoại',
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      maxlenght: 10,
                      isNumber: true
                    ),
                    _buildEditableField(
                      label: 'Địa chỉ',
                      controller: _addressController,
                      maxLines: 2,
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _buildInfoSection(
                  title: 'Thông tin hệ thống',
                  icon: Icons.settings_outlined,
                  children: [
                    _buildReadOnlyField(
                      label: 'Trạng thái tài khoản',
                      value: "Active",
                      icon: Icons.check_circle_outline,
                    ),
                    _buildReadOnlyField(
                      label: 'Ngày tạo',
                      value: dateFormat
                          .format(DateTime.parse(widget.dataSeller.createAt)),
                      icon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _buildInfoSection(
                  title: 'Giới thiệu',
                  icon: Icons.info_outline,
                  children: [
                    _buildEditableField(
                      label: 'Mô tả cửa hàng',
                      controller: _bioController,
                      maxLines: 3,
                      icon: Icons.description_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    GoogleMapScreenPage()));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primaryGreen, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: primaryGreen,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on_outlined),
                            SizedBox(width: 8),
                            Text(
                              'Cập nhật vị trí',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          final profileVM = Provider.of<Profile_ViewModel>(
                              context,
                              listen: false);
                          if (_storeNameController.text.isEmpty ||
                              _ownerNameController.text.isEmpty ||
                              _phoneController.text.isEmpty ||
                              _addressController.text.isEmpty ||
                              _bioController.text.isEmpty) {
                            showDialogMessage(
                                context,
                                "Vui lòng điền đủ thông tin",
                                DialogType.warning);
                            return;
                          } else {
                            bool isSuccess =
                                await profileVM.UpdateProfileSeller(
                                    uid,
                                    widget.dataSeller.image,
                                    _storeNameController.text,
                                    _ownerNameController.text,
                                    _phoneController.text,
                                    _addressController.text,
                                    _bioController.text,
                                    _avatar);
                            if (isSuccess) {
                              setState(() {_isLoading = false;});
                              showDialogMessage(
                                  context,
                                  "Cập nhật thông tin thành công",
                                  DialogType.success);
                            } else {
                              setState(() {_isLoading = false;});
                              showDialogMessage(
                                  context,
                                  "Lỗi: ${profileVM.errorMessage}",
                                  DialogType.error);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: primaryGreen.withOpacity(0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 8),
                            Text('Cập nhật thông tin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ));
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: lightGreen.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: primaryGreen),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: children
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: e,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    int? maxlenght,
    bool isNumber = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          maxLength: maxlenght,
          decoration: InputDecoration(
            counterText: "",
            prefixIcon: Icon(icon, color: primaryGreen),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
