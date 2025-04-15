import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/Models/ProfileUser.dart';
import 'package:order_food/View/Page/Profile/Contact_Page.dart';
import 'package:order_food/View/Page/Profile/ProfileUser_Detail.dart';
import 'package:order_food/View/Page/Profile/PurchasePolicy.dart';
import 'package:order_food/View/Widget/DialogChangePassword.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:provider/provider.dart';

import '../Page/Login/Login_Page.dart';
import '../Page/Profile/ProfileSeller_Detail.dart';

class ProfileSellerScreen extends StatefulWidget {
  const ProfileSellerScreen({super.key});

  @override
  State<ProfileSellerScreen> createState() => _ProfileSellerScreenState();
}

class _ProfileSellerScreenState extends State<ProfileSellerScreen> {
  String storeName = "";
  String phone = "";
  String email = "";
  String image = "";
  bool _isLoading = true;
  late ProfileSeller dataSeller;

  @override
  void initState() {
    super.initState();
    ShowAllData();
  }

  void OneClickProfileDetail() async {
    final bool? reloadData = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSellerDetail(
          dataSeller: dataSeller,
        ),
      ),
    );

    if (reloadData == true) {
      ShowAllData();
    }
  }

  void ShowAllData() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
    if (authVM.uid!.isNotEmpty) {
      ProfileSeller? seller =
          await profileVM.GetAllDataProfileSeller(authVM.uid!);
      if (seller != null) {
        setState(() {
          dataSeller = seller;
          storeName = dataSeller.storeName;
          phone = dataSeller.phone;
          email = dataSeller.email;
          image = dataSeller.image;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
          LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildProfileHeader(),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildFeatureList(),
                    ]),
                  ),
                ],
              ),
            ),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
                child: (image.isNotEmpty &&
                        Uri.tryParse(image)?.hasAbsolutePath == true)
                    ? CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(image),
                      )
                    : CircleAvatar(
                        radius: 48,
                        child: Icon(Icons.person, size: 48),
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child:
                    const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            storeName,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    return Card(
      elevation: 6,
      shadowColor: Colors.grey.withOpacity(0.7),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          _buildFeatureTile(
            icon: Icons.manage_accounts_rounded,
            title: "Chỉnh sửa trang cá nhân",
            color: Colors.blue,
            onTap: () {
              OneClickProfileDetail();
            },
          ),
          const Divider(
            height: 5,
            indent: 16,
            color: Colors.grey,
            endIndent: 16,
            thickness: 1.5,
          ),
          _buildFeatureTile(
            icon: Icons.policy,
            title: "Chính sách bán hàng",
            color: Colors.purple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PurchasePolicy(roleAccount: dataSeller.role)),
              );
            },
          ),
          const Divider(
            height: 5,
            indent: 16,
            color: Colors.grey,
            endIndent: 16,
            thickness: 1.5,
          ),
          _buildFeatureTile(
            icon: Icons.perm_contact_calendar_outlined,
            title: "Liên hệ",
            color: Colors.green,
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Contact()));
            },
          ),
          const Divider(
            height: 5,
            indent: 16,
            color: Colors.grey,
            endIndent: 16,
            thickness: 1.5,
          ),
          _buildFeatureTile(
            icon: Icons.change_circle_rounded,
            title: "Đổi mật khẩu",
            color: Colors.indigoAccent,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => DialogChangePassword());
            },
          ),
          const Divider(
            height: 5,
            indent: 16,
            color: Colors.grey,
            endIndent: 16,
            thickness: 1.5,
          ),
          _buildFeatureTile(
            icon: Icons.logout,
            title: "Đăng xuất",
            color: Colors.red,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
      trailing: Icon(Icons.chevron_right, color: Colors.green),
      onTap: onTap,
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.red),
              ),
              padding: const EdgeInsets.symmetric(vertical: 11),
            ),
            onPressed: () {},
            child: const Text(
              "Xóa tài khoản",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
