import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Page/Order/OrderManagement_Detail.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:provider/provider.dart';

import '../../../Models/Product.dart';
import '../../../Models/PlaceOrder.dart';
import '../../../ViewModels/Order_ViewModel.dart';
import '../../../ViewModels/Product_ViewModel.dart';

class OrderManagerment extends StatefulWidget {
  const OrderManagerment({super.key});

  @override
  State<OrderManagerment> createState() => _OrderManagermentState();
}

class _OrderManagermentState extends State<OrderManagerment> {
  bool _isLoading = true;
  bool _isNull = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Tất cả';
  final priceFormatter = NumberFormat("#,###", "vi_VN");

  Product_ViewModel product_viewModel = Product_ViewModel();
  late List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    ShowAllData();
  }

  void ShowAllData() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final orderDetail = Provider.of<Order_ViewModel>(context, listen: false);
    if (authVM.uid!.isNotEmpty) {
      List<Map<String, dynamic>>? dataOrderDetail =
          await orderDetail.ShowAllDataOrderDetail("", "", _selectedStatus, _searchController.text);
      if (dataOrderDetail != null) {
        setState(() {
          _orders = dataOrderDetail;
          _isLoading = false;
          _isNull = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isNull = true;
        });
      }
    }
  }

  Future<void> _refreshOrders() async {
    ShowAllData();
  }

  void OneClickOrderDetail(Map<String,dynamic> orderDetail, Product product, PlaceOrder order) async {
    final bool? reloadData = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OrderManagementDetail(dataOrderDetail: orderDetail,product: product,order: order,
        ),
      ),
    );

    if (reloadData == true) {
      ShowAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
          LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text(
            "Quản lý đơn hàng",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        body: _buildOrderList(),
      ),
    );
  }

  Widget _buildOrderList() {
    final orderVM = Provider.of<Order_ViewModel>(context, listen: false);
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Tìm kiếm đơn hàng...',
              hintStyle: TextStyle(fontSize: 15, color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.green, size: 27),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.green),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (value) => ShowAllData(),
          ),
        ),

        // Status Filter Chips
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
              _buildStatusChip('Từ chối'),
            ],
          ),
        ),

        // Order List
        _isNull
            ? _buildEmptyState()
            : Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshOrders,
                  color: Colors.green,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _orders.isEmpty ? 6 : _orders.length,
                    itemBuilder: (context, index) {
                      if (_orders.isEmpty) {
                        return _buildLoadingCard();
                      }
                      final order = _orders[index];
                      return FutureBuilder(
                          future: Future.wait([
                            productVM.ShowAllProductFormProductId(
                                order["ProductId"]),
                            orderVM.ShowAllPlaceOrder(order['OrderId']),
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
                            final orderDetail = snapshot.data![1] as PlaceOrder;

                            return _buildOrderCard(order, product, orderDetail);
                          });
                    },
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, Product dataProduct, PlaceOrder orderInfo) {
    final primaryColor = Colors.green;
    final secondaryColor = Colors.grey[600]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            OneClickOrderDetail(order,dataProduct,orderInfo);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          "#${order['OrderDetailId']
                              .toString()
                              .substring(0, 7)
                              .toUpperCase()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 17),
                        )
                      ],
                    ),
                    _buildStatusBadge(order['Status']),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          dataProduct.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.image,
                                size: 30, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dataProduct.productName,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dataProduct.storeName,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 5),

                          Row(
                            children: [
                              Text(
                                "${priceFormatter.format(dataProduct.price)}đ",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "× ${order["Quantity"]}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.green,thickness: 1,),

                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng cộng:',
                        style: TextStyle(
                          color: secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${priceFormatter.format(dataProduct.price * order["Quantity"])} vnđ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case "Hoàn thành":
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case "Từ chối":
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case "Đang giao hàng":
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case "Chờ lấy hàng":
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case "Chờ xác nhận":
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
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
        onSelected: (selected) {
          setState(() {
            _selectedStatus = status;
            ShowAllData();
          });
        },
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        selectedColor: Colors.green,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 8),
            Text('Không thể tải thông tin đơn hàng',
                style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 200,
        alignment: Alignment.center,
        child: LoadingAnimationWidget.inkDrop(color: Colors.green, size: 30),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Icon(Icons.assignment, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Không có đơn hàng nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
