import 'package:flutter/material.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:provider/provider.dart';

import '../../Models/ProfileSeller.dart';
import '../../ViewModels/Profile_ViewModel.dart';

class HomeSellerScreen extends StatefulWidget {
  const HomeSellerScreen({super.key});

  @override
  State<HomeSellerScreen> createState() => _HomeSellerScreenState();
}

class _HomeSellerScreenState extends State<HomeSellerScreen> {
  final TextEditingController _searchController = TextEditingController();
  late String ownerName = "", avatar = "", role = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
      final authVM = Provider.of<AuthViewModel>(context, listen: false);

      if (authVM.uid != null) {
        ProfileSeller? seller =
            await profileVM.GetAllDataProfileSeller(authVM.uid!);
        if (seller != null && mounted) {
          setState(() {
            ownerName = seller.ownerName;
            avatar = seller.image;
            role = seller.role;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade300,
              child: ClipOval(
                child: avatar == ""
                    ? CircularProgressIndicator()
                    : Image.network(avatar,
                        fit: BoxFit.cover, width: 44, height: 44),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text(ownerName,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF4CAF50), size: 27),
            onPressed: () {},
          ),
        ],
      ),
      body: (ownerName == "" || avatar == "" || role == "")
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "Tìm kiếm sản phẩm...",
                        hintStyle:
                            TextStyle(fontSize: 13, fontFamily: "Poppins"),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 10, right: 5),
                          child: Icon(Icons.search,
                              color: Color(0xFF4CAF50), size: 18),
                        ),
                        prefixIconConstraints:
                            BoxConstraints(minWidth: 30, minHeight: 30),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Expanded(
                          child: Divider(
                              thickness: 1.5,
                              color: Color(0xFF4CAF50),
                              endIndent: 8)),
                      Text(
                        "Sản phẩm của cửa hàng",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50)),
                      ),
                      Expanded(
                          child: Divider(
                              thickness: 1.5,
                              color: Color(0xFF4CAF50),
                              indent: 8)),
                      // ✅ Nhỏ hơn
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: GridView.builder(
                      itemCount: 10,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15)),
                                    child: Image.asset(
                                      "asset/images/logo.png",
                                      height: 104,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "Danh mục",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                child: Divider(
                                  color: Color(0xFF4CAF50),
                                  thickness: 1.5,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Mixed Salad Bonb...",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2), // ✅ Nhỏ hơn

                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 12),
                                        const SizedBox(width: 3),
                                        const Text("4.8 (1.2k)",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                        // ✅ Giảm font
                                      ],
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween, // Giữ khoảng cách đều
                                      children: [
                                        Text(
                                          "100.000 vnđ",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                        SizedBox(
                                          height: 40,
                                          child: role != "Seller"
                                              ? IconButton(
                                                  icon: const Icon(
                                                      Icons.favorite_border,
                                                      color: Colors.red,
                                                      size: 18),
                                                  onPressed: () {},
                                                )
                                              : SizedBox
                                                  .shrink(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
