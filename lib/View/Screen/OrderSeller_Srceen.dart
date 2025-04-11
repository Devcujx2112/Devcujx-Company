import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/PlaceOrder.dart';
import 'package:order_food/Models/Product.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Order_ViewModel.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'package:provider/provider.dart';

class OrderSellerScreen extends StatefulWidget {
  const OrderSellerScreen({super.key});

  @override
  State<OrderSellerScreen> createState() => _OrderSellerScreenState();
}

class _OrderSellerScreenState extends State<OrderSellerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _statusFilters = [
    'Tất cả',
    'Chờ xác nhận',
    'Chờ lấy hàng',
    'Đang giao hàng',
    'Hoàn thành'
  ];
  String _selectedStatus = 'Tất cả';
  bool _isLoading = true;
  bool _isNull = false;

  late List<Map<String, dynamic>> _orders;

  @override
  void initState() {
    super.initState();
    ShowAllDataOrder();
  }

  Future<void> ShowAllDataOrder() async {
    final orderDetailVM = Provider.of<Order_ViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (authVM.uid!.isNotEmpty) {
      List<Map<String, dynamic>>? dataOrderDetail =
          await orderDetailVM.ShowAllDataOrderDetail(
              "", authVM.uid!, _selectedStatus);
      if(dataOrderDetail == null){
        setState(() {
          _isNull = true;
          _isLoading = false;
        });
        return;
      }
      if (dataOrderDetail != null) {
        setState(() {
          print('UI data $_selectedStatus');
          _orders = dataOrderDetail;
          _isNull = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshOrders() async {
    ShowAllDataOrder();
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
              'Quản Lý Đơn Hàng',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.green,
            automaticallyImplyLeading: false,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildOrderList(),
        ));
  }

  Widget _buildOrderList() {
    final orderVM = Provider.of<Order_ViewModel>(context, listen: false);
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Tìm kiếm đơn hàng...',
              hintStyle: TextStyle(fontSize: 15, color: Colors.grey[600]),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.green,
                size: 27,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.green),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.green, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (value) => _filterOrders(),
          ),
        ),

        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildStatusChip('Tất cả'),
              _buildStatusChip('Chờ xác nhận'),
              _buildStatusChip('Chờ lấy hàng'),
              _buildStatusChip('Đang giao hàng'),
              _buildStatusChip('Hoàn thành'),
            ],
          ),
        ),

        // Order list
        Expanded(
          child: RefreshIndicator(
              onRefresh: _refreshOrders,
              color: Colors.green,
              child: _isNull
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final orderDetail = _orders[index];
                        return FutureBuilder(
                            future: Future.wait([
                              productVM.ShowAllProductFormProductId(
                                  orderDetail["ProductId"]),
                              orderVM.ShowAllPlaceOrder(orderDetail['OrderId']),
                            ]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildLoadingCard();
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return _buildErrorCard();
                              }
                              final product = snapshot.data![0] as Product;
                              final order = snapshot.data![1] as PlaceOrder;

                              return _buildOrderCard(
                                  orderDetail, product, order);
                            });
                      })),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 200,
        alignment: Alignment.center,
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text('Không thể tải thông tin đơn hàng',
                style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
      Map<String, dynamic> orderDetail, Product product, PlaceOrder order) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mã đơn:",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.delete_outline, color: Colors.red, size: 23),
                    onPressed: () =>
                        _showDeleteDialog(orderDetail['OrderDetailId']),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // Product info row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text("Khách hàng:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                    fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              order.nameUser,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Số lượng:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                    fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              "${orderDetail["Quantity"]}",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order info rows
              _buildInfoRow(Icons.phone, order.phoneUser),
              _buildInfoRow(Icons.location_on, order.addressUser),
              _buildInfoRow(Icons.payment, orderDetail["PaymentMethod"]),
              _buildInfoRow(
                Icons.calendar_today,
                DateFormat('dd/MM/yyyy').format(
                  DateTime.parse(orderDetail['CreateAt'] ??
                      orderDetail['createAt'] ??
                      order.createAt.toString()),
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.grey),

              // Footer
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng thanh toán',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "${_formatPrice((orderDetail["Quantity"] * product.price))} VNĐ",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusDropdown(orderDetail),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _deleteOrder(orderId);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOrder(String orderId) async {}

  Widget _buildStatusDropdown(Map<String, dynamic> orderDetail) {
    return Container(
      width: 150,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[500]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: orderDetail["Status"],
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 24),
          style: const TextStyle(fontSize: 14, color: Colors.black),
          items: _statusFilters
              .where((status) => status != 'Tất cả')
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              orderDetail["Status"] = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (context) {
          setState(() {
            _selectedStatus = status;
            ShowAllDataOrder();
          });
        },
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        checkmarkColor: Colors.white,
        selectedColor: Colors.green,
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Không có đơn hàng nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Khi có đơn hàng mới, chúng sẽ xuất hiện tại đây',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Chờ lấy hàng':
        return Colors.blue;
      case 'Đang giao hàng':
        return Colors.purple;
      case 'Hoàn thành':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatPrice(num price) {
    return NumberFormat('#,###').format(price);
  }

  void _filterOrders() {
    // Logic lọc đơn hàng theo search và status
  }
}
