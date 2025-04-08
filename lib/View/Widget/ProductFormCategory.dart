import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Page/Product/ProductDetailUser.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'package:provider/provider.dart';

class ProductFormCategory extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductFormCategory({super.key, required this.productData});

  @override
  State<ProductFormCategory> createState() => _ProductFormCategoryState();
}

class _ProductFormCategoryState extends State<ProductFormCategory> {
  bool _isLoading = true;
  List<Map<String, dynamic>> productList = [];
  bool isFavorite = false;
  bool _isNotNull = false;

  @override
  void initState() {
    super.initState();
    LoadAllProduct();
  }

  void LoadAllProduct() async {
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    List<Map<String, dynamic>>? productData =
        await productVM.SearchProductFormCategory(
            widget.productData["CategoryName"]);
    setState(() {
      _isLoading = false;
      if (productData == null || productData.isEmpty) {
        _isNotNull = true;
        productList = [];
      } else {
        _isNotNull = false;
        productList = productData;
      }
    });
  }

  void OneClickProductFormCategory(Map<String, dynamic> productListData) async {
    final bool? reloadData = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailUser(
          product: productListData,
        ),
      ),
    );
    // if (reloadData == true) {
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        progressIndicator:
            LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
        inAsyncCall: _isLoading,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Text(
                "Danh mục: ${widget.productData["CategoryName"]}",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 21),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: _isNotNull
                ? Center(
                    child: Text(
                    "Chưa có sản phẩm nào cho danh mục này",
                    style:
                        TextStyle(color: Colors.green, fontFamily: "Poppins"),
                  ))
                : Padding(
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: productList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final product = productList[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              OneClickProductFormCategory(product);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                      child: Image.network(
                                        product["Image"] ?? '',
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 120,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                              Icons.image_not_supported),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          product["CategoryName"] ?? 'Danh mục',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product["ProductName"]?.toString() ??
                                            "Tên sản phẩm",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.storefront,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              product["StoreName"] ??
                                                  "Cửa hàng",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${NumberFormat("#,###").format(product["Price"] ?? 0)}đ",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 16),
                                              const SizedBox(width: 2),
                                              Text(
                                                product["Rating"]
                                                        ?.toStringAsFixed(1) ??
                                                    "0.0",
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                          ),
                        );
                      },
                    ),
                  )));
  }
}
