import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:order_food/View/Page/Account/AccountManagement.dart';
import 'package:order_food/View/Page/Category/CategoryManagement.dart';
import 'package:order_food/View/Page/GoogleMap/GoogleMapManagement.dart';
import 'package:order_food/View/Page/Login/Login_Page.dart';
import 'package:order_food/View/Page/Order/OrderManagement.dart';
import 'package:order_food/View/Page/Product/ProductManagement.dart';

class DrawerAdminScreen extends StatelessWidget {
  String fullName;
  String email;
  String image;

  DrawerAdminScreen(
      {super.key,
      required this.fullName,
      required this.email,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              fullName,
              style:
                  GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              email,
              style: GoogleFonts.roboto(fontSize: 13),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 35,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('asset/images/avatar_default.jpg',
                              fit: BoxFit.cover);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                    : Image.asset('asset/images/avatar_default.jpg',
                        fit: BoxFit.cover),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          _buildDrawerItem(Icons.manage_accounts_rounded, "Quản lý tài khoản",
              () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AccountManagement()),
            );
          }),
          _buildDrawerItem(Icons.dashboard, "Danh mục sản phẩm", () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CategoryManagement()),
            );
          }),
          _buildDrawerItem(Icons.shopping_cart, "Quản lý sản phẩm", () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProductManagement()),
            );
          }),
          _buildDrawerItem(Icons.store_sharp, "Vị trí cửa hàng", () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => GoogleMapManagement()),
            );
          }),
          _buildDrawerItem(Icons.receipt_long, "Quản lý đơn hàng", () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => OrderManagerment()),
            );
          }),
          const Divider(
            thickness: 2,
            indent: 15,
            endIndent: 15,
            color: Colors.green,
          ),
          _buildDrawerItem(Icons.logout_outlined, "Đăng xuất", () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
            );
          }),
        ],
      ),
    );
  }

  /// Widget cho từng mục trong Drawer
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700, size: 25),
      title: Text(
        title,
        style: GoogleFonts.roboto(
            fontSize: 15, fontWeight: FontWeight.w500, color: Colors.green),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
      hoverColor: Colors.green.shade100.withOpacity(0.3),
    );
  }
}
