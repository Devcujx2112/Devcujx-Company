import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Widget/ProductFormCategory.dart';
import 'package:order_food/ViewModels/Category_ViewModel.dart';
import 'package:provider/provider.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'dart:async';

class HomeUserScreen extends StatefulWidget {
  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  final PageController _bannerController =
      PageController(viewportFraction: 0.85);
  TextEditingController _searchProduct = TextEditingController();
  int _currentBanner = 0;
  Timer? _timer;
  final List<String> _bannerImages = [
    "asset/images/bannerApp2.png",
    "asset/images/bannerApp2.png",
    "asset/images/bannerApp2.png",
  ];
  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> categoryList = [];
  bool _isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _startBannerAnimation();
    ShowAllData();
  }

  void _startBannerAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        setState(() {
          _currentBanner = (_currentBanner + 1) % _bannerImages.length;
        });
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
    _searchProduct.dispose();
    super.dispose();
  }

  void ShowAllData() async {
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    final categoryVm = Provider.of<Category_ViewModel>(context, listen: false);
    List<Map<String, dynamic>>? fetchedCategories =
        await categoryVm.ShowAllCategory(_searchProduct.text) ?? [];
    List<Map<String, dynamic>>? fetchedProduct =
        await productVM.ShowAllProduct(_searchProduct.text, "") ?? [];
    setState(() {
      categoryList = fetchedCategories;
      productList = fetchedProduct;
      _isLoading = false;
    });
  }

  void OneClickProductItems(Map<String, dynamic> product) {
    // Xử lý khi click vào sản phẩm
  }

  void OneClickCategoryItems(Map<String, dynamic> category) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductFormCategory(
                  categoryName: category,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
          LoadingAnimationWidget.inkDrop(color: Colors.green, size: 60),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildSpecialOfferBanner(),
            const SizedBox(height: 16),
            _buildSectionTitleWithSeeAll("Danh mục đồ ăn", true),
            const SizedBox(height: 0),
            _buildCategorySection(),
            const SizedBox(height: 5),
            _buildSectionTitleWithSeeAll("Danh sách sản phẩm", false),
            const SizedBox(height: 8),
            _buildProductGridSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitleWithSeeAll(String title, bool hidden) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          hidden
              ? SizedBox()
              : InkWell(
                  splashColor: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => print('Xem tất cả $title'),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      "Xem tất cả >>",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchProduct,
      decoration: InputDecoration(
          hintText: "Bạn đang tìm kiếm gì?",
          prefixIcon: const Icon(Icons.search, color: Colors.green, size: 28),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
    );
  }

  Widget _buildSpecialOfferBanner() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _bannerController,
        itemCount: _bannerImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                _bannerImages[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    if (categoryList.isEmpty) return const SizedBox();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          final category = categoryList[index];
          final imageUrl = category["Image"]?.toString() ?? '';
          final categoryName =
              category['CategoryName']?.toString() ?? 'Danh mục';

          return InkWell(
              onTap: () {
                OneClickCategoryItems(categoryList[index]);
              },
              child: Container(
                width: 80,
                margin: EdgeInsets.only(
                  left: index == 0 ? 8 : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(15), // Bo tròn cả 4 góc
                      child: Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error), // Xử lý khi ảnh lỗi
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: "Poppins",
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }

  Widget _buildProductGridSection() {
    if (productList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: productList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final product = productList[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => print('One Click Product ${product["ProductName"]}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    product["Image"] ?? '',
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
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
                // Thêm icon trái tim ở góc phải
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      // Thay đổi trạng thái khi bấm
                      isFavorite = !isFavorite;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_outlined
                            : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["ProductName"]?.toString() ?? "Tên sản phẩm",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
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
                          product["StoreName"] ?? "Cửa hàng",
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            product["Rating"]?.toStringAsFixed(1) ?? "0.0",
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
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
  }
}
