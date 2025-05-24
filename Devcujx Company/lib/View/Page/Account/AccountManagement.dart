import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_food/View/Page/Profile/ProfileUserAdmin_Detail.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:provider/provider.dart';

import '../Profile/ProfileSellerAdmin_Detail.dart';

class AccountManagement extends StatefulWidget {
  const AccountManagement({super.key});

  @override
  State<AccountManagement> createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement> {
  late int buyerCount;
  late int sellerCount;
  bool _isLoading = true;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
      try {
        Map<String, int> counts = await profileVM.GetCountSellerUser();
        List<Map<String, dynamic>> fetchedUsers =
            await profileVM.LoadAllAccount() ?? [];

        if (mounted) {
          setState(() {
            users = fetchedUsers;
            buyerCount = counts['User'] ?? 0;
            sellerCount = counts['Seller'] ?? 0;
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Lỗi khi tải dữ liệu: $e");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  String formatDate(String isoString) {
    try {
      DateTime dateTime = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    } catch (e) {
      return "Không xác định";
    }
  }

  void OneClickItemUser(Map<String, dynamic> user) async {
      final bool? shouldReload = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileDetailUser(user: user),
        ),
      );
      if (shouldReload == true) reloadDataList();

  }

  void OnClickItemSeller(Map<String, dynamic> user) async{
    final bool? shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailSeller(user: user),
      ),
    );
    if (shouldReload == true) reloadDataList();

  }


  void reloadDataList() async {
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
    try {
      List<Map<String, dynamic>> updatedUsers = await profileVM.LoadAllAccount() ?? [];
      if (mounted) {
        setState(() {
          users = updatedUsers;
        });
      }
    } catch (e) {
      print("Lỗi khi cập nhật danh sách: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8278FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Quản lý tài khoản',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(
                          "Người mua hàng", buyerCount, Colors.blueAccent),
                      _buildStatCard("Người bán hàng", sellerCount,
                          Colors.deepPurpleAccent),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(
                          child: Divider(
                              thickness: 2,
                              color: Colors.blueAccent,
                              endIndent: 10)),
                      Text(
                        "Danh sách tài khoản",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: Color(0xFF3D3A62)),
                      ),
                      Expanded(
                          child: Divider(
                              thickness: 2,
                              color: Colors.deepPurple,
                              indent: 10)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return _buildUserTile(users[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              blurRadius: 8,
              offset: const Offset(0,4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins"),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    return InkWell(
      onTap: () {
        user["Role"] == "Seller"
            ? OnClickItemSeller(user)
            : OneClickItemUser(user);
      },
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Bo góc ảnh vuông
                child: Image.network(
                  user['Avatar'],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'asset/images/avatar_default.jpg',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.person,
                        user['OwnerName'] ?? user['FullName'],
                        bold: true),
                    _buildInfoRow(Icons.email, user['Email']),
                    _buildInfoRow(Icons.access_time_filled_outlined,
                        formatDate(user['CreateAt']),
                        fontSize: 12),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                      child: _buildTag(
                          user['Role'],
                          user['Role'] == "User"
                              ? Colors.blueAccent
                              : Colors.deepPurpleAccent)),
                  const SizedBox(height: 6),
                  Flexible(
                      child: _buildTag(
                          user['Status'],
                          user['Status'] == "Ban"
                              ? Colors.redAccent
                              : Colors.green)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text,
      {bool bold = false, double fontSize = 13, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.blueAccent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Color(0xFF3D3A62),
                fontFamily: "Poppins",
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
