import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/PlaceOrder.dart';
import 'package:order_food/Models/Product.dart';
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Order_ViewModel.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:provider/provider.dart';

class OrderManagementDetail extends StatefulWidget {
  Map<String, dynamic> dataOrderDetail;
  Product product;
  PlaceOrder order;

  OrderManagementDetail(
      {super.key,
      required this.dataOrderDetail,
      required this.product,
      required this.order});

  @override
  State<OrderManagementDetail> createState() => _OrderManagementDetailState();
}

class _OrderManagementDetailState extends State<OrderManagementDetail> {
  bool _isLoading = true;
  bool _isNull = false;
  final NumberFormat _priceFormatter = NumberFormat("#,###", "vi_VN");
  ProfileSeller? profileSeller;
  String? sellerId;

  @override
  void initState() {
    super.initState();
    ShowAllData();
  }

  void ShowAllData() async {
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
    sellerId = widget.product.uid;
    if (sellerId != null) {
      ProfileSeller? dataSeller =
          await profileVM.GetAllDataProfileSeller(sellerId!);
      if (dataSeller != null) {
        setState(() {
          profileSeller = dataSeller;
          _isLoading = false;
        });
      }
      else{
        _isLoading = false;
        _isNull = true;
      }
    }
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
          backgroundColor: Colors.green,
          centerTitle: true,
          title: const Text(
            "Chi tiết đơn hàng",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        body: _isNull ? _buildLoadingCard() : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(),
              const SizedBox(height: 10),

              _buildProductInfo(),
              const SizedBox(height: 10),

              _buildOrderInfo(),
              const SizedBox(height: 10),

              _buildCustomerInfo(),
              const SizedBox(height: 10),

              _buildStoreInfo(),
              const SizedBox(height: 10),

              // Tổng thanh toán
              _buildTotalPayment(),
            ],
          ),
        ),
        bottomNavigationBar: _deteleOrderDetail(),
      ),
    );
  }

  Widget _deteleOrderDetail(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isLoading = true;
          });
          _showDeleteConfirmationDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[400],
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, size: 22),
            SizedBox(width: 8),
            Text(
              "Xóa đơn hàng",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa",style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 25),),
        content: const Text("Bạn có chắc muốn xóa đơn hàng này? Thao tác này không thể hoàn tác."),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder();
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOrder() async {
    final orderVM = Provider.of<Order_ViewModel>(context,listen: false);
    if(widget.dataOrderDetail["OrderDetailId"] != null){
      bool isSuccess = await orderVM.DeleteOrderDetail(widget.dataOrderDetail["OrderDetailId"]);
      if(isSuccess){
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context,true);
        showDialogMessage(context, "Xóa đơn hàng thành công",DialogType.success);
      }
      else{
        showDialogMessage(context,"Xóa đơn hàng thất bại",DialogType.error);
      }
    }
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

  Widget _buildOrderHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mã đơn hàng",
                  style: TextStyle(
                      color: Color(0xFF616161),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "#${widget.dataOrderDetail['OrderDetailId'].toString().substring(0, 7).toUpperCase()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            _buildStatusChip(widget.dataOrderDetail['Status']),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sản phẩm",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
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
                      widget.product.image,
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
                        widget.product.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${_priceFormatter.format(widget.product.price)}đ",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Số lượng: ${widget.dataOrderDetail['Quantity']}",
                        style: const TextStyle(
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin đơn hàng",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: "Ngày tạo",
              value: DateFormat('dd/MM/yyyy - HH:mm').format(
                DateTime.parse(widget.dataOrderDetail['CreateAt']),
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.payment,
              label: "Phương thức thanh toán",
              value: widget.dataOrderDetail['PaymentMethod'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thông tin khách hàng",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person,
              label: "Tên khách hàng",
              value: widget.order.nameUser,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.phone,
              label: "Số điện thoại",
              value: widget.order.phoneUser,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.location_on,
              label: "Địa chỉ",
              value: widget.order.addressUser,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin cửa hàng",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.store,
              label: "Tên cửa hàng",
              value: profileSeller?.storeName ?? "",
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.phone_android,
              label: "Số điện thoại",
              value: profileSeller?.phone ?? "",
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: "Email",
              value: profileSeller?.email ?? "",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPayment() {
    final total = widget.product.price * widget.dataOrderDetail['Quantity'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tổng thanh toán",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
            Text(
              "${_priceFormatter.format(total)} vnđ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
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
          fontSize: 14,
        ),
      ),
    );
  }
}
