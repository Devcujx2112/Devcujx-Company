import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/View/Widget/ListReview.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'package:order_food/ViewModels/Review_ViewModel.dart';
import 'package:order_food/ViewModels/ShoppingCart_ViewModel.dart';
import 'package:provider/provider.dart';

class ProductDetailUser extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailUser({super.key, required this.product});

  @override
  _ProductDetailUserState createState() => _ProductDetailUserState();
}

class _ProductDetailUserState extends State<ProductDetailUser> {
  bool _isFavorite = false;
  int _quantity = 1;
  String favoriteId = "";
  bool _isNullReview = true;
  List<Map<String,dynamic>> dataReview = [];
  double? rattingData;

  @override
  void initState() {
    super.initState();
    LoadData();
  }

  void LoadData() async {
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final reviewVM = Provider.of<Review_ViewModel>(context,listen: false);
    List<Map<String, dynamic>>? productListId =
        await productVM.ShowAllFavoriteProduct(authVM.uid!) ?? [];
    List<String> productId =
    productListId.map((key) => key["ProductId"].toString()).toList();
    bool isFavorite =
    productId.contains(widget.product["ProductId"].toString());
    String? fav = await productVM.GetFavoriteId(
        productListId, widget.product["ProductId"], authVM.uid!);
    if (isFavorite) {
      setState(() {
        _isFavorite = true;
      });
    }
    if (fav != null) {
      favoriteId = fav;
    }
    List<Map<String,dynamic>> dataReviewDb = await reviewVM.ShowAllDataReview(widget.product["ProductId"]);
    if(dataReviewDb != []){
      List allRattings = dataReviewDb
          .map((review) => review['Ratting']?.toDouble() ?? 0.0)
          .toList();
      double averageRating = allRattings.isNotEmpty
          ? allRattings.reduce((a, b) => a + b) / allRattings.length
          : 0.0;
      setState(() {
        rattingData = double.tryParse(averageRating.toStringAsFixed(1));
        dataReview = dataReviewDb;
        _isNullReview = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildTransparentAppBar(authVM.uid!),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.product['Image'] ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) =>
                        Center(
                          child: CircularProgressIndicator(
                            color: Colors.green,
                          ),
                        ),
                    errorWidget: (context, url, error) =>
                        Container(
                          color: Colors.grey[200],
                          child:
                          Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text(
                            rattingData?.toString() ??
                                'Loading...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product['ProductName'] ?? 'Tên sản phẩm',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.store, color: Colors.green),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.product['StoreName'] ?? 'Cửa hàng',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              )
                            ]),
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          widget.product['CategoryName'] ?? 'Danh mục',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GIÁ:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                _formatPrice(widget.product['Price'] ?? 0),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextSpan(
                                text: 'VNĐ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.grey, thickness: 2),
                  SizedBox(height: 12),
                  Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product['Description'] ?? 'Không có mô tả',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey, thickness: 2),
                  const SizedBox(height: 10),
                  _buildReviewHeader(),
                  const SizedBox(height: 10),
                  _buildReviewList(widget.product["ProductId"]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildReviewHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Đánh giá sản phẩm",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        if (dataReview.isNotEmpty)
          Text(
            "(${dataReview.length} đánh giá)",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildReviewList(String productId) {
    if (_isNullReview) {
      return SizedBox(
        height: 100,
        child: Center(
          child: LoadingAnimationWidget.inkDrop(
            color: Colors.green,
            size: 35,
          ),
        ),
      );
    }

    if (dataReview.isEmpty) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text(
            "Chưa có đánh giá",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    }

    print('UI data reviews: ${dataReview.map((review) => review.toString()).toList()}');
    for (var review in dataReview) {
      debugPrint('Review ID: ${review["ReviewId"]}, ProductId: ${review["ProductId"]}');
      if (review["RepliesId"] != null) {
        debugPrint('-> Has reply: ${review["Comment"]}');
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...dataReview.map(
              (review) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListReview(
              dataReview: review,
              productId: productId,
              reload: LoadData,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2.0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    size: 22,
                    color: Colors.green,
                  ),
                  onPressed: () =>
                      setState(
                              () =>
                          _quantity = _quantity > 1 ? _quantity - 1 : 1),
                ),
                Text('$_quantity',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 22,
                    color: Colors.green,
                  ),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _addToCart,
              child: Text(
                'THÊM VÀO GIỎ HÀNG',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildTransparentAppBar(String uid) {
    final productVm = Provider.of<Product_ViewModel>(context, listen: false);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[600]),
          onPressed: () => Navigator.pop(context, true),
          padding: EdgeInsets.zero,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: Colors.red,
            ),
            onPressed: () async {
              if (_isFavorite) {
                if (favoriteId.isEmpty) {
                  showDialogMessage(
                      context,
                      "Không tìm thấy id của sản phẩm yêu thích",
                      DialogType.warning);
                } else {
                  bool isSuccess = await productVm.DeleteFavoritProduct(favoriteId);
                  if (isSuccess) {
                    setState(() => _isFavorite = false);
                    Navigator.pop(context, true);
                    showDialogMessage(
                        context, "Đã xóa sản phẩm yêu thích", DialogType.success);
                  } else {
                    showDialogMessage(context, "Lỗi: ${productVm.errorMessage}",
                        DialogType.error);
                  }
                }
              } else {
                String productId = widget.product["ProductId"];
                if (productId.isEmpty || uid.isEmpty) {
                  showDialogMessage(
                      context, "Không tìm thấy thông tin", DialogType.warning);
                } else {
                  bool isSuccess = await productVm.InsertFavorite(productId, uid);
                  if (isSuccess) {
                    setState(() {
                      _isFavorite = true;
                      LoadData();
                    });
                    showDialogMessage(context, "Thêm sản phẩm yêu thích thành công",
                        DialogType.success);
                  } else {
                    showDialogMessage(context, "Lỗi: ${productVm.errorMessage}",
                        DialogType.error);
                  }
                }
              }
            },
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  String _formatPrice(dynamic price) {
    if (price is int || price is double) {
      return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );
    }
    return '0';
  }

  void _addToCart() async {
    final shoppingVM = Provider.of<ShoppingCart_ViewModel>(
        context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (widget.product.isEmpty && authVM.uid!.isEmpty) {
      showDialogMessage(
          context, "Thông tin sản phẩm không đầy đủ", DialogType.warning);
    }
    else {
      bool isSuccess = await shoppingVM.InsertProductShoppingCart(
          widget.product["ProductName"],
          widget.product["StoreName"],
          widget.product["Uid"],
          _quantity,
          widget.product["Price"],
          widget.product["Image"],
          authVM.uid!,
          widget.product["ProductId"]);
      if (isSuccess) {
        Navigator.pop(context, true);
        showDialogMessage(context, "Thêm sản phẩm vào giỏ hàng thành công",
            DialogType.success);
      } else {
        showDialogMessage(
            context, "Lỗi: ${shoppingVM.errorMessage}", DialogType.error);
      }
    }
  }
}
