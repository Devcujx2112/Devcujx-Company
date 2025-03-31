import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Page/Login/Login_Page.dart';

class DrawerUserScreen extends StatelessWidget {
  String email, avatar, fullName;

  DrawerUserScreen(
      {super.key, required this.email, required this.fullName, required this.avatar});

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
                child: avatar.isNotEmpty
                    ? Image.network(
                  avatar ,
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                        'asset/images/avatar_default.jpg', fit: BoxFit.cover);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                )
                    : Image.asset(
                    'asset/images/avatar_default.jpg', fit: BoxFit.cover),
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
          _buildDrawerItem(Icons.logout_outlined, "Đăng xuất", () async
              {await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
              );}),
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
