import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:order_food/View/Page/Account/AccountManagement.dart';
import 'package:order_food/View/Page/Category/CategoryManagement.dart';
import 'package:order_food/View/Page/Order/OrderManagement.dart';
import 'package:order_food/View/Page/Product/ProductManagement.dart';

class DrawerUserScreen extends StatelessWidget {
  const DrawerUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              "Your Name",
              style:
              GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              "your.email@example.com",
              style: GoogleFonts.roboto(),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 35,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset('asset/images/avatar_default.jpg',
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
          const SizedBox(height: 10),
          const Divider(
            thickness: 2,
            indent: 15,
            endIndent: 15,
            color: Colors.green,
          ),
          _buildDrawerItem(Icons.logout_outlined, "Đăng xuất", () {}),
        ],
      ),
    );
  }

  /// Widget cho từng mục trong Drawer
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700, size: 26),
      title: Text(
        title,
        style: GoogleFonts.roboto(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
      hoverColor: Colors.green.shade100.withOpacity(0.3),
    );
  }
}
