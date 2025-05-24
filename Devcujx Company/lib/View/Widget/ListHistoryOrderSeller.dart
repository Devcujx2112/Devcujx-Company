import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_food/Models/PlaceOrder.dart';
import 'package:order_food/Models/Product.dart';
import 'package:order_food/ViewModels/Order_ViewModel.dart';
import 'package:provider/provider.dart';

import '../../ViewModels/Product_ViewModel.dart';

class HistoryOrderSeller extends StatefulWidget {
  final Map<String, dynamic> dataOrder;
  final VoidCallback loading;

  const HistoryOrderSeller({
    Key? key,
    required this.dataOrder,
    required this.loading,
  }) : super(key: key);

  @override
  State<HistoryOrderSeller> createState() => _HistoryOrderSellerState();
}

class _HistoryOrderSellerState extends State<HistoryOrderSeller> {
  Product? product;
  PlaceOrder? placeOrder;

  @override
  void initState() {
    super.initState();
    ShowAllData();
  }

  void ShowAllData() async {
    if(!mounted) return;
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    final orderVM = Provider.of<Order_ViewModel>(context,listen: false);
    Product? dataProduct = await productVM.ShowAllProductFormProductId(
        widget.dataOrder["ProductId"] ?? "");
    PlaceOrder? dataPlaceOrder = await orderVM.ShowAllPlaceOrder(widget.dataOrder["OrderId"] ?? "");

    if (dataProduct != null && dataPlaceOrder != null) {
      setState(() {
        placeOrder = dataPlaceOrder;
        product = dataProduct;
        widget.loading();
      });
    } else {
      widget.loading();
    }
  }

  String _formatPrice(dynamic price) {
    final number = (price is num) ? price : 0;
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(number);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return const Color(0xFFFFA000); // Amber 700
      case 'Chờ lấy hàng':
        return const Color(0xFF1976D2); // Blue 700
      case 'Đang giao hàng':
        return const Color(0xFF7B1FA2); // Purple 700
      case 'Hoàn thành':
        return const Color(0xFF388E3C); // Green 700
      case 'Từ chối':
        return const Color(0xFFD32F2F); // Red 700
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return const Color(0xFFFFF3E0); // Amber 50
      case 'Chờ lấy hàng':
        return const Color(0xFFE3F2FD); // Blue 50
      case 'Đang giao hàng':
        return const Color(0xFFF3E5F5); // Purple 50
      case 'Hoàn thành':
        return const Color(0xFFE8F5E9); // Green 50
      case 'Từ chối':
        return const Color(0xFFFFEBEE); // Red 50
      default:
        return Colors.grey.shade100;
    }
  }

  @override

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Đơn #${widget.dataOrder["OrderDetailId"].toString().substring(0, 7).toUpperCase()}",
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                          fontSize: 16
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                          widget.dataOrder["Status"] ?? "Loading"),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.dataOrder["Status"] ?? "Loading",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getStatusTextColor(
                            widget.dataOrder["Status"] ?? "Loading"),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerInfoRow(
                      icon: Icons.person,
                      label: "Khách hàng:",
                      value: placeOrder?.nameUser ?? "Loading",
                    ),
                    const SizedBox(height: 6),
                    _buildCustomerInfoRow(
                      icon: Icons.phone,
                      label: "SĐT:",
                      value: placeOrder?.phoneUser ?? "Loading",
                    ),
                    const SizedBox(height: 6),
                    _buildCustomerInfoRow(
                      icon: Icons.location_on,
                      label: "Địa chỉ:",
                      value: placeOrder?.addressUser ?? "Loading",
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade100,
                      child: product?.image == null
                          ? _buildDefaultImage()
                          : Image.network(
                        product!.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          return progress == null
                              ? child
                              : _buildLoadingImage();
                        },
                        errorBuilder: (_, __, ___) =>
                            _buildDefaultImage(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product?.productName ?? "Đang tải...",
                          style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            color: Colors.green
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 3),

                        Text(
                          "Số lượng: ${widget.dataOrder["Quantity"] ?? 0}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 5),

                        Row(children: [Icon(
                          Icons.payment,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),SizedBox(width: 5,),
                          Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              children: [

                                TextSpan(text: widget.dataOrder["PaymentMethod"] ?? "Chưa xác định"),
                              ],
                            ),
                          ),
                        ),],),
                        const SizedBox(height: 5),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(
                                      widget.dataOrder["CreateAt"] is String
                                          ? DateTime.parse(widget.dataOrder["CreateAt"])
                                          : widget.dataOrder["CreateAt"] as DateTime
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                )
                              ],
                            ),

                            // Giá tiền
                            Text(
                              _formatPrice((widget.dataOrder["Quantity"] ?? 0) *
                                  (product?.price ?? 0)),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
              children: [
                TextSpan(
                  text: "$label  ",
                  style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.green),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }  Widget _buildDefaultImage() {
    return Center(
      child: Icon(
        Icons.fastfood,
        size: 40,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.grey.shade400,
      ),
    );
  }
}