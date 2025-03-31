import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/View/Page/Login/Login_Page.dart';
import 'package:order_food/View/Page/Profile/GoogleMap_Page.dart';
import 'package:provider/provider.dart';
import '../../../ViewModels/Auth_ViewModel.dart';
import '../../../ViewModels/Profile_ViewModel.dart';
import '../../Widget/DialogMessage_Form.dart';

class CreateProfileSeller extends StatefulWidget {
  const CreateProfileSeller({super.key});

  @override
  State<CreateProfileSeller> createState() => _CreateProfileSellerState();
}

class _CreateProfileSellerState extends State<CreateProfileSeller> {
  Profile_ViewModel profileViewModel = Profile_ViewModel();
  File? _selectedImage;
  TextEditingController txtStoreName = TextEditingController();
  TextEditingController txtFullName = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtBio = TextEditingController();
  String? email;
  String? storeName;
  late String uid;
  String role = "Seller";
  String status = "Active";
  String createAt = DateTime.now().toIso8601String();

  Future<void> loadEmailAndRole(String uid) async {
    if (uid.isNotEmpty) {
      bool success = await profileViewModel.LoadEmailAccount(uid);
      if (success) {
        setState(() {
          email = profileViewModel.email!;
        });
      }
    }
  }

  Future<void> pickImage() async {
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
        loadEmailAndRole(authVM.uid!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header background
              Container(
                width: double.infinity,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF007BFF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Email"),
                      _buildReadOnlyTextField(email ?? "Loading..."),
                      const SizedBox(height: 10),
                      _buildLabel("Store Name"),
                      _buildTextField(controller: txtStoreName),
                      const SizedBox(height: 10),
                      _buildLabel("Owner Name"),
                      _buildTextField(controller: txtFullName),
                      const SizedBox(height: 10),
                      _buildLabel("Phone Number"),
                      _buildTextField(controller: txtPhone, isNumber: true),
                      const SizedBox(height: 10),
                      _buildLabel("Address"),
                      _buildTextField(controller: txtAddress),
                      const SizedBox(height: 10),
                      _buildLabel("Bio"),
                      _buildTextField(controller: txtBio, lenght: 3),
                      const SizedBox(height: 15),

                      // Store Location Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 200,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        GoogleMapScreenPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.map, color: Colors.white),
                            label: const Text("Set Store Location",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Poppins",
                                    color: Colors.white)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Ảnh đại diện và tên cửa hàng
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: pickImage,
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 51,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : const AssetImage(
                                      'asset/images/avatar_default.jpg')
                                  as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child:
                              const Icon(Icons.camera_alt, color: Colors.blue,size: 18,),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 40,
            right: 40,
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedImage == null) {
                    showDialogMessage(context, "Vui lòng thêm ảnh của cửa hàng",
                        DialogType.warning);
                    return;
                  }
                  ProfileSeller profileSeller = ProfileSeller(
                      uid,
                      email!,
                      role,
                      txtStoreName.text,
                      "",
                      txtFullName.text,
                      txtPhone.text,
                      txtAddress.text,
                      txtBio.text,
                      status,
                      createAt);
                  bool success = await profileVM.CreateProfileSeller(
                      profileSeller, _selectedImage!);
                  if (success) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                    showDialogMessage(
                        context, "Tạo Profile thành công", DialogType.success);

                  } else {
                    showDialogMessage(
                        context,
                        "Tạo Profile thất bại :${profileVM.errorMessage}",
                        DialogType.error);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "SUBMIT",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontFamily: "Poppins",
      fontWeight: FontWeight.bold,
      color: Colors.black54,
    ),
  );
}

Widget _buildTextField(
    {required TextEditingController controller,
    bool isNumber = false,
    int lenght = 1}) {
  return TextField(
    maxLines: lenght,
    style: TextStyle(fontSize: 13,color: Colors.black,fontFamily: "Poppins"),
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      hintText: isNumber ? "Enter your phone number" : "Enter details",
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    ),
    controller: controller,
  );
}

Widget _buildReadOnlyTextField(String value) {
  return TextField(
    readOnly: true,
    style: TextStyle(fontSize: 13,fontFamily: "Poppins",color: Colors.black) ,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    ),
    controller: TextEditingController(text: value),
  );
}
