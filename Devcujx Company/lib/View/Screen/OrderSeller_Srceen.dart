import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/PlaceOrder.dart';
import 'package:order_food/Models/Product.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
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
    'Chờ xác nhận',
    'Chờ lấy hàng',
    'Đang giao hàng',
    'Hoàn thành',
    'Từ chối',
  ];
  String _selectedStatus = 'Tất cả';
  bool _isLoading = true;
  bool _isNull = false;

  List<Map<String, dynamic>> _orders = [];

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
              "", authVM.uid!, _selectedStatus,_searchController.text);
      if (dataOrderDetail != null) {
        setState(() {
          _orders = dataOrderDetail;
          _isNull = false;
          _isLoading = false;
        });
        return;
      } else {
        setState(() {
          _isNull = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshOrders() async {
    ShowAllDataOrder();
  }

  String _formatPrice(num price) {
    return NumberFormat('#,###').format(price);
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
          body: _buildOrderList(),
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
            onChanged: (value) => ShowAllDataOrder(),
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
              _buildStatusChip('Từ chối'),
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

  Widget _buildOrderCard(Map<String, dynamic> orderDetail, Product product, PlaceOrder order) {
    bool completed = false;
    if(orderDetail["Status"] != "Từ chối"){
      completed = true;
    }
    final primaryColor = Colors.green;
    final secondaryColor = Colors.grey[500]!;
    final backgroundColor = Theme.of(context).cardColor;

    return Padding(
      padding: EdgeInsets.only(top: 5,left: 15,right: 15,bottom: 5),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: backgroundColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ĐƠN HÀNG: #${orderDetail['OrderDetailId'].toString().substring(0, 7).toUpperCase()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 40),
                   completed ? SizedBox() :
                    IconButton(
                      icon: Icon(Icons.more_vert, color: secondaryColor),
                      onPressed: () =>
                          _showDeleteDialog(orderDetail['OrderDetailId']),
                    ),
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.image, color: Colors.grey[400]),
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
                            product.productName,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.green[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),


                          _buildInfoItem(
                            icon: Icons.person_outline,
                            value: order.nameUser,
                          ),
                          // Thông tin đơn hàng
                          _buildInfoItem(
                            icon: Icons.phone_outlined,
                            value: order.phoneUser,
                          ),
                          _buildInfoItem(
                            icon: Icons.shopping_cart_outlined,
                            label: "Số lượng",
                            value: "${orderDetail["Quantity"]}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                _buildInfoItem(
                  icon: Icons.location_on_outlined,
                  label: "Địa chỉ",
                  value: order.addressUser,
                ),
                _buildInfoItem(
                  icon: Icons.payment_outlined,
                  label: "Thanh toán",
                  value: orderDetail["PaymentMethod"],
                ),
                _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: "Ngày đặt",
                  value: DateFormat('dd/MM/yyyy').format(
                    DateTime.parse(
                        orderDetail['CreateAt'] ?? order.createAt.toString()),
                  ),
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.grey),

                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      // Tổng thanh toán
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TỔNG THANH TOÁN',
                              style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${_formatPrice(orderDetail["Quantity"] * product.price)} VNĐ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: primaryColor,
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
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    String? label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
                children: [
                  TextSpan(
                    text: "${label ?? ""} :  ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  TextSpan(text: value,style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'chờ xác nhận':
        return Colors.orange;
      case 'chờ lấy hàng':
        return Colors.lightBlueAccent;
      case 'đang giao hàng':
        return Colors.blue;
      case 'hoàn thành':
        return Colors.green;
      case 'từ chối':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.warning_rounded,
                  size: 48,
                  color: Colors.orange.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Xác nhận xóa',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đơn hàng sẽ bị xóa vĩnh viễn',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Quay lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _deleteOrder(orderId);
                      },
                      child: const Text('Xóa ngay'),
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

  Future<void> _deleteOrder(String orderId) async {
    final orderVM = Provider.of<Order_ViewModel>(context, listen: false);
    if (orderId.isNotEmpty) {
      bool isSuccess = await orderVM.DeleteOrderDetail(orderId);
      if (isSuccess) {
        ShowAllDataOrder();
        Navigator.pop(context);
        showDialogMessage(
            context, "Xóa đơn hàng thành công", DialogType.success);
      }
    } else {
      showDialogMessage(
          context, "Không tìm thấy id của đơn hàng", DialogType.warning);
    }
  }

  Widget _buildStatusDropdown(Map<String, dynamic> orderDetail) {
    final statusColor = _getStatusColor(orderDetail["Status"]);
    bool complete = false;
    if(orderDetail["Status"] == "Hoàn thành" || orderDetail["Status"] == "Từ chối"){
      complete = true;
    }
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.5)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: orderDetail["Status"],
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: statusColor),
            iconSize: 24,
            dropdownColor: Colors.white,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
            items: _statusFilters.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: _getStatusColor(value),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: complete ? null :(newValue) {
              if (newValue != null) {
                setState(() {
                  orderDetail["Status"] = newValue;
                });
                UpdateStatusOrder(orderDetail["OrderDetailId"], newValue);
              }
            },
          ),
        ),
      ),
    );
  }

  void UpdateStatusOrder(String orderId, String status) async {
    final orderVM = Provider.of<Order_ViewModel>(context, listen: false);
    if (status.isNotEmpty) {
      bool isSuccess = await orderVM.UpdateStatusOrder(orderId, status);
      if (isSuccess) {
        ShowAllDataOrder();
      }
    } else {
      showDialogMessage(
          context, "Trạng thái đơn hàng trống", DialogType.warning);
    }
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
}
