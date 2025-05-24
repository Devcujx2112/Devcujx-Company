import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Page/HomePage/NearestStore.dart';
import 'package:order_food/View/Page/Product/ProductDetailUser.dart';
import 'package:order_food/View/Page/HomePage/ViewAllProduct.dart';
import 'package:order_food/View/Widget/ProductFormCategory.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Category_ViewModel.dart';
import 'package:provider/provider.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'dart:async';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  final PageController _bannerController =
      PageController(viewportFraction: 0.85);
  final TextEditingController _searchProduct = TextEditingController();
  int _currentBanner = 0;
  Timer? _timer;
  final List<String> _bannerImages = [
    "asset/images/bannerApp2.png",
    "asset/images/bannerApp2.png",
    "asset/images/bannerApp2.png",
  ];
  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> categoryList = [];
  Map<String, bool> favoriteStatus = {};
  bool _isLoading = true;
  int? selectedItems;
  String uid = "";

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
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    List<Map<String, dynamic>>? fetchedCategories =
        await categoryVm.ShowAllCategory("") ?? [];
    List<Map<String, dynamic>>? fetchedProduct =
        await productVM.ShowAllProduct(_searchProduct.text, "") ?? [];
    setState(() {
      categoryList = fetchedCategories;
      productList = fetchedProduct;
      uid = authVM.uid!;
      _isLoading = false;
    });
  }

  void showAllProductFromLowToHigh() async {
    setState(() {
      _isLoading = true;
    });
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    List<Map<String, dynamic>>? fetchedProduct =
        await productVM.ShowAllProduct(_searchProduct.text, "") ?? [];

    if (fetchedProduct.isNotEmpty) {
      fetchedProduct.sort((a, b) {
        final priceA = a['Price'] ?? 0;
        final priceB = b['Price'] ?? 0;
        return priceA.compareTo(priceB);
      });
    }
    setState(() {
      productList = fetchedProduct;
      _isLoading = false;
    });
  }

  void showALlProductFormHighToLow() async {
    setState(() {
      _isLoading = true;
    });
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    List<Map<String, dynamic>>? fetchedProduct =
        await productVM.ShowAllProduct(_searchProduct.text, "") ?? [];

    if (fetchedProduct.isNotEmpty) {
      fetchedProduct.sort((a, b) {
        final priceA = a['Price'] ?? 0;
        final priceB = b['Price'] ?? 0;
        return priceB.compareTo(priceA);
      });
    }
    setState(() {
      productList = fetchedProduct;
      _isLoading = false;
    });
  }

  void OneClickProductItems(Map<String, dynamic> product) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailUser(
                  product: product,
                )));
  }

  void OneClickCategoryItems(Map<String, dynamic> category) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductFormCategory(
                  productData: category,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
          LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
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
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ViewAllProduct()));
                  },
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            controller: _searchProduct,
            style: TextStyle(fontSize: 13, fontFamily: "Poppins"),
            onChanged: (value) => ShowAllData(),
            decoration: InputDecoration(
              hintText: "Bạn đang tìm kiếm gì?",
              hintStyle: TextStyle(fontSize: 13, fontFamily: "Poppins"),
              prefixIcon:
                  const Icon(Icons.search, color: Colors.green, size: 28),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.green),
          onPressed: _showFilterDialog,
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bộ lọc sản phẩm",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.green,
                        size: 25,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const Divider(
                  height: 20,
                  thickness: 2,
                ),

                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.green),
                  title: Text(
                    "Cửa hàng gần tôi nhất",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => NearestStore()));
                  },
                ),

                ListTile(
                  leading: Icon(Icons.arrow_upward, color: Colors.green),
                  title: Text(
                    "Giá: Từ thấp đến cao",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: selectedItems == 1
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() => selectedItems = 1);
                    showAllProductFromLowToHigh();
                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  leading: Icon(Icons.arrow_downward, color: Colors.green),
                  title: Text(
                    "Giá: Từ cao đến thấp",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: selectedItems == 2
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() => selectedItems = 2);
                    showALlProductFormHighToLow();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ));
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
        onTap: () {
          OneClickProductItems(product);
        },
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
