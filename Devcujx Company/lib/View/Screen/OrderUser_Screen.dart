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
    final productVM = Provider.of<Product_ViewModel>(context, listen: false);
    if (authVM.uid!.isNotEmpty) {
      List<Map<String, dynamic>>? orderData =
          await orderVM.ShowAllDataOrderDetail(
              authVM.uid!, "", _selectedStatus,_searchController.text);
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
    final primaryColor = Colors.green;
    final secondaryColor = Colors.grey[600]!;

    final orderCode = order["OrderDetailId"]?.toString().substring(0, 7).toUpperCase() ?? "------";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Card(
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long, size: 16, color: Colors.green,),
                          const SizedBox(width: 6),
                          Text(
                            "Mã đơn hàng: $orderCode",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      order["CreateAt"] != null
                          ? dateFormat.format(DateTime.parse(order["CreateAt"].toString()))
                          : 'Không có ngày',
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: primaryColor,
                      child: Icon(Icons.store, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dataProduct.storeName,
                      style: TextStyle(
                        fontSize: 17,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
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
                            child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(height: 8),


                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['Status']).withOpacity(0.1),
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
                          const SizedBox(height: 8),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Số lượng: ${order['Quantity']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                            ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                Divider(color: Colors.grey[300], thickness: 2,),
                Row(
                  children: [
                    // Tổng tiền
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thành tiền',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(dataProduct.price * order["Quantity"]),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    if (order['Status'] == 'Chờ xác nhận')
                      SizedBox(
                        width: 100,
                        child: OutlinedButton(
                          onPressed: () => _showDialogDeleteOrder(order["OrderDetailId"], context),
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
                                fontSize: 13,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
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
      case 'Từ chối':
        return Colors.red; // Green
      default:
        return Colors.grey;
    }
  }
}
