import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Page/Product/ProductDetailSeller.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
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
  List<Map<String, dynamic>>? allProduct = [];
  bool _isLoading = true;
  late String uid;
  bool _isNull = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final productVM = Provider.of<Product_ViewModel>(context, listen: false);

      if (authVM.uid != null) {
        uid = authVM.uid!;
        List<Map<String, dynamic>>? data =
            await productVM.ShowAllProduct(_searchController.text, uid) ?? [];
        ProfileSeller? seller =
            await profileVM.GetAllDataProfileSeller(authVM.uid!);
        if (seller != null && data != null && mounted) {
          setState(() {
            allProduct = data;
            ownerName = seller.ownerName;
            avatar = seller.image;
            role = seller.role;
            _isLoading = false;
            _isNull = false;
          });
        }
        if (data.isEmpty){
          _isNull = true;
          _isLoading = false;
        }
      }
    });
  }

  void AddProduct() async {
    final bool? reloadData = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailSeller(),
      ),
    );
    if (reloadData == true) {
      ReloadData();
    }
  }

  void ReloadData() async {
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    List<Map<String, dynamic>>? fetchedCategories =
        await productVM.ShowAllProduct(_searchController.text, uid) ?? [];
    if(fetchedCategories == null){
      setState(() {
        _isNull = true;
      });
    }else {
      setState(() {
        allProduct = fetchedCategories;
        _isLoading = false;
        _isNull = false;
      });
    }
  }

  void OneClickProduct(Map<String, dynamic>? productData) async {
    final bool? reloadData = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailSeller(
          productData: productData,
        ),
      ),
    );
    if (reloadData == true) {
      ReloadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: _isLoading,
        progressIndicator:
            LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
        child: Scaffold(
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
                        ? null
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
                onPressed: () {
                  AddProduct();
                },
              ),
            ],
          ),
          body: _isNull
              ? Center(
                  child: Text("Chưa có sản phẩm nào trong cửa hàng",
                      style: TextStyle(color: Colors.green,fontFamily: "Poppins",fontSize: 16)),
                )
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
                          onChanged: (value) => ReloadData(),
                          style: TextStyle(
                            fontSize: 13,
                          ),
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
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(
                                  thickness: 1.5,
                                  color: Color(0xFF4CAF50),
                                  endIndent: 8)),
                          Text(
                            "Sản phẩm của cửa hàng",
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50)),
                          ),
                          const Expanded(
                              child: Divider(
                                  thickness: 1.5,
                                  color: Color(0xFF4CAF50),
                                  indent: 8)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: GridView.builder(
                          itemCount: allProduct?.length ?? 0,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 0.82,
                          ),
                          itemBuilder: (context, index) {
                            final productList = allProduct?[index];
                            return InkWell(
                              onTap: () {
                                OneClickProduct(allProduct?[index]);
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          child: Image.network(
                                            productList?["Image"],
                                            height: 105,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          left: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              productList?["CategoryName"] ??
                                                  "",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      child: Divider(
                                        color: Color(0xFF4CAF50),
                                        thickness: 1.5,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            productList?["ProductName"] ?? "",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 12),
                                              const SizedBox(width: 3),
                                              Text(
                                                productList?["Rating"]
                                                        ?.toString() ??
                                                    "0",
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${NumberFormat("#,###").format(productList?["Price"] ?? 0)} VNĐ",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                  fontFamily: "Poppins",
                                                ),
                                              ),
                                              if (role != "Seller")
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.favorite_border,
                                                    color: Colors.red,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {},
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
