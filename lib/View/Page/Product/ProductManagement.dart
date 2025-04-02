import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/View/Page/Product/ProductDetailAdmin.dart';
import 'package:order_food/View/Page/Product/ProductDetailSeller.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:provider/provider.dart';

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  State<ProductManagement> createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  bool _isLoading = true;
  TextEditingController searchController = TextEditingController();
  int _countProduct = 0;

  List<Map<String, dynamic>> productList = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final productListVm =
          Provider.of<Product_ViewModel>(context, listen: false);
      List<Map<String, dynamic>> productData =
          await productListVm.ShowAllProduct("", "") ?? [];
      print('UI $productListVm');
      if (productData != null) {
        setState(() {
          productList = productData;
          _countProduct = productData.length;
          _isLoading = false;
        });
      }
    });
  }

  void ReloadData() async {
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    List<Map<String, dynamic>>? fetchedProduct =
        await productVM.ShowAllProduct(searchController.text, "") ?? [];
    setState(() {
      productList = fetchedProduct;
      _isLoading = false;
    });
  }

  void OneClickProduct(Map<String, dynamic> productData) async {
    final bool? reloadData = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailAdmin(productList: productData,
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
          title: const Text(
            "Quản lý sản phẩm",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12.withOpacity(0.05), blurRadius: 5),
                  ],
                ),
                child: TextField(
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: "Poppins",
                      fontStyle: FontStyle.normal),
                  controller: searchController,
                  onChanged: (value) => ReloadData(),
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm sản phẩm...",
                    hintStyle: TextStyle(fontSize: 13, fontFamily: "Poppins"),
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tổng số sản phẩm:",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    Text(productList.length.toString(),
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.green, thickness: 2)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Danh sách sản phẩm",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: "Poppins")),
                  ),
                  Expanded(child: Divider(color: Colors.green, thickness: 2)),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: productList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = productList[index];
                    return InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          OneClickProduct(productList[index]);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      product["Image"],
                                      width: double.infinity,
                                      height: 135,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        product["CategoryName"],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product["ProductName"]?.toString() ?? "",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.storefront,
                                            size: 16, color: Colors.grey),
                                        // Icon cửa hàng
                                        const SizedBox(width: 6),
                                        Text(
                                          product["StoreName"],
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${NumberFormat("#,###").format(product["Price"] ?? 0)} VNĐ",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.amber, size: 16),
                                            const SizedBox(width: 1),
                                            Text(
                                              product["Rating"].toString(),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
