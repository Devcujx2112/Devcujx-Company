import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Page/Product/ProductManagement.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'package:provider/provider.dart';

class ProductDetailAdmin extends StatefulWidget {
  final Map<String, dynamic> productList;

  const ProductDetailAdmin({super.key, required this.productList});

  @override
  State<ProductDetailAdmin> createState() => _ProductDetailAdminState();
}

class _ProductDetailAdminState extends State<ProductDetailAdmin> {
  bool _isLoading = false;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  double _fabOpacity = 1.0;

  @override
  Widget build(BuildContext context) {
    final product = widget.productList;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final productVM = Provider.of<Product_ViewModel>(context,listen: true);

    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator: LoadingAnimationWidget.inkDrop(
        color: Colors.green[600]!,
        size: 50,
      ),
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.green,
            centerTitle: true,
            title: Text(
              "Chi tiết sản phẩm",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context, true),
            ),actions: [
              IconButton(onPressed: () async{
                setState(() {
                  _isLoading = true;
                });
                if(widget.productList["ProductId"] != null){
                  bool isSuccess = await productVM.DeleteProduct(widget.productList["ProductId"]);
                  if(isSuccess){
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pop(context,true);
                    showDialogMessage(context, "Xóa sản phẩm thành công",DialogType.success);
                  }else{
                    showDialogMessage(context, "Xóa sản phẩm thất bại ${productVM.errorMessage}",DialogType.error);
                  }
                }else{
                  showDialogMessage(context, "Không tìm thấy ID của sản phẩm", DialogType.warning);
                }
              }, icon: Icon(Icons.delete_sharp),color: Colors.white,)
        ],),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Product Image
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      product['Image'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Product Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // Điều chỉnh padding ngang
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name and Rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product['ProductName'] ?? 'Không có tên',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: "Poppins",
                              color: Colors.green,
                              height: 1.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 18, color: Colors.amber[600]),
                              const SizedBox(width: 4),
                              Text(
                                product['Rating']?.toStringAsFixed(1) ?? '0.0',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Store Info
                    Row(
                      children: [
                        Icon(Icons.store_mall_directory_rounded,
                            size: 18, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          product['StoreName'] ?? 'Không có cửa hàng',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(
                      height: 1,
                      thickness: 2,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 15),

                    // Details Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: screenWidth > 400 ? 3.5 : 3.2,
                      // Điều chỉnh tỉ lệ
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      padding: const EdgeInsets.only(bottom: 0),
                      // Thêm padding dưới
                      children: [
                        _buildDetailCard(
                            icon: Icons.category_rounded,
                            title: 'Danh mục',
                            value: product['CategoryName'] ?? '--',
                            color: Colors.grey),
                        _buildDetailCard(
                            icon: Icons.attach_money_rounded,
                            title: 'Giá tiền',
                            value:
                                '${NumberFormat('#,###').format(product['Price'] ?? 0)}đ',
                            color: Colors.red),
                        _buildDetailCard(
                            icon: Icons.calendar_today_rounded,
                            title: 'Ngày tạo',
                            value: product['CreateAt'] != null
                                ? _dateFormat
                                    .format(DateTime.parse(product['CreateAt']))
                                : '--',
                            color: Colors.grey),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(
                      height: 1,
                      thickness: 2,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 15),

                    // Description
                    Text(
                      'MÔ TẢ SẢN PHẨM',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      // Thêm padding dưới
                      child: Text(
                        product['Description'] ?? 'Không có mô tả',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                          height: 1.4, // Điều chỉnh line height
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
      {required IconData icon,
      required String title,
      required String value,
      required Color color}) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1, // Cho phép tối đa 2 dòng
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
