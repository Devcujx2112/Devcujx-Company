import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/Product.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Order_ViewModel.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'package:provider/provider.dart';

class OrderUserScreen extends StatefulWidget {
  const OrderUserScreen({super.key});

  @override
  State<OrderUserScreen> createState() => _OrderUserScreenState();
}

class _OrderUserScreenState extends State<OrderUserScreen> {
  Product_ViewModel product_viewModel = Product_ViewModel();
  bool _isLoading = true;
  bool _isNull = false;
  String _selectedStatus = 'Tất cả';
  final dateFormat = DateFormat('dd/MM/yyyy');

  final TextEditingController _searchController = TextEditingController();

  late List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    ShowAllData();
  }

  void ShowAllData() async {
    final orderVM = Provider.of<Order_ViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (authVM.uid!.isNotEmpty) {
      List<Map<String, dynamic>>? orderData =
          await orderVM.ShowAllDataOrderDetail(authVM.uid!,"", _selectedStatus);
      if (orderData == null) {
        setState(() {
          _isNull = true;
          _isLoading = false;
        });
        return;
      } else {
        setState(() {
          _isNull = false;
          _orders = orderData;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      opacity: 0.5,
      progressIndicator:
          LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: _buildAppBar(),
        body: _buildOrderList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.green,
      elevation: 0.5,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text(
        'Đơn hàng',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOrderList() {
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
            ],
          ),
        ),
        _isNull
            ? _buildEmptyState()
            : Expanded(
                child: RefreshIndicator(
                    onRefresh: _refreshOrders,
                    color: Colors.green,
                    child: ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return FutureBuilder<Product?>(
                            future:
                                product_viewModel.ShowAllProductFormProductId(
                                    order["ProductId"]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildLoadingCard();
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return _buildErrorCard();
                              }
                              return _buildOrderCard(order, snapshot.data!);
                            },
                          );
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
            ShowAllData();
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

  Widget _buildOrderCard(Map<String, dynamic> order, Product dataProduct) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.green[500],
                        child: Icon(Icons.store, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dataProduct.storeName,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 4),
                  Text(
                    order["CreateAt"] != null
                        ? dateFormat.format(
                            DateTime.parse(order["CreateAt"].toString()))
                        : 'Không có ngày',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product Info - Dòng 2
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
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
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Product Details - Cột dọc
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          dataProduct.productName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Padding(
                            padding: EdgeInsets.only(right: 10, bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[500],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Số lượng: ${order['Quantity']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        const SizedBox(width: 8),
                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order['Status'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order['Status'],
                            style: TextStyle(
                              fontSize: 13,
                              color: _getStatusColor(order['Status']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              Column(
                children: [
                  Divider(color: Colors.green, height: 20),
                  Row(
                    children: [
                      // Total Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thành tiền',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatPrice(dataProduct.price * order["Quantity"]),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      if (order['Status'] == 'Chờ xác nhận')
                        SizedBox(
                          width: 100,
                          child: OutlinedButton(
                            onPressed: () => _showDialogDeleteOrder(
                                order["OrderDetailId"], context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Hủy đơn',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'asset/images/logo.png',
            width: MediaQuery.of(context).size.width * 0.6,
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có đơn hàng nào',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Hãy khám phá và đặt những món ngon đầu tiên của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _refreshOrders() async {
    ShowAllData();
  }

  void _filterOrders() {
    // Logic lọc đơn hàng
  }

  void _showDialogDeleteOrder(String orderId, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Colors.orange,
              size: 30,
            ),
            SizedBox(width: 20),
            Text('Xác nhận xóa', style: TextStyle(fontSize: 20)),
          ],
        ),
        content: const Text(
          'Bạn chắc chắn muốn xóa đơn hàng này? Thao tác này không thể hoàn tác.',
          style: TextStyle(fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton.tonal(
            onPressed: () {
              _deleteOrder(orderId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      final orderVM = Provider.of<Order_ViewModel>(context, listen: false);
      if (orderId.isEmpty) {
        showDialogMessage(
            context, "Không tìm thấy id của đơn hàng", DialogType.warning);
        return;
      } else {
        bool isSuccess = await orderVM.DeleteOrderDetail(orderId);
        if (isSuccess) {
          showDialogMessage(
              context, "Xóa đơn hàng thành công", DialogType.success);
          ShowAllData();
        } else {
          showDialogMessage(context, "Xóa sản phẩm thất bại", DialogType.error);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa đơn hàng: $e');
    }
  }

  String _formatPrice(num price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return const Color(0xFFFFA000); // Amber
      case 'Chờ lấy hàng':
        return const Color(0xFF1976D2); // Blue
      case 'Đang giao hàng':
        return const Color(0xFF7B1FA2); // Purple
      case 'Hoàn thành':
        return const Color(0xFF388E3C); // Green
      default:
        return Colors.grey;
    }
  }
}
