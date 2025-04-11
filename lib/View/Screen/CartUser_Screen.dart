import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Screen/HomeUser_Screen.dart';
import 'package:order_food/View/Widget/Checkout_Form.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/ShoppingCart_ViewModel.dart';
import 'package:provider/provider.dart';

class CartUserScreen extends StatefulWidget {
  const CartUserScreen({super.key});

  @override
  State<CartUserScreen> createState() => _CartUserScreenState();
}

class _CartUserScreenState extends State<CartUserScreen> {
  bool _isLoading = true;
  double _totalPrice = 0;
  List<Map<String, dynamic>> _cartItems = [];
  String uid = "";
  bool _isNull = false;

  @override
  void initState() {
    super.initState();
    LoadAllData();
  }

  void LoadAllData() async {
    final shoppingCartVM =
        Provider.of<ShoppingCart_ViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    List<Map<String, dynamic>>? data =
        await shoppingCartVM.ShowAllProductFormShoppingCart(authVM.uid!);
    if (data!.isNotEmpty) {
      setState(() {
        _cartItems = data;
        uid = authVM.uid!;
        _calculateTotal();
        _isLoading = false;
      });
    }
    if (data.isEmpty) {
      setState(() {
        _isNull = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator: LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: _isNull
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Giỏ hàng trống',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              // Mô tả
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Bạn chưa thêm sản phẩm nào vào giỏ hàng. Hãy khám phá cửa hàng và thêm sản phẩm yêu thích nhé!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        )
            : Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildCartItem(_cartItems[index]),
                      childCount: _cartItems.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
            _buildCheckoutPanel(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.green,
      title: Text('Giỏ hàng',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Dismissible(
      key: Key(item['CartId']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => _removeItem(item['CartId']),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hình ảnh
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item['Image'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : _buildShimmerEffect(80, 80),
                      errorBuilder: (_, __, ___) => _buildPlaceholder(80, 80),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Thông tin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['ProductName'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 5),
                            Text(
                              item["StoreName"],
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatPrice(item['Price'])}đ',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            _buildQuantityControl(item),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(Map<String, dynamic> item) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              size: 25,
              color: Colors.green,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 36),
            onPressed: () =>
                _updateQuantity(item['CartId'], item['Quantity'] - 1),
          ),
          Text(item['Quantity'].toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey[700])),
          IconButton(
            icon: Icon(
              Icons.add,
              size: 25,
              color: Colors.green,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 36),
            onPressed: () =>
                _updateQuantity(item['CartId'], item['Quantity'] + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tạm tính', style: TextStyle(color: Colors.grey[700])),
              Text(_formatPrice(_totalPrice),
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng cộng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                '${_formatPrice(_totalPrice)}đ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _checkout,
              child: Text(
                'THANH TOÁN',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeItem(String id) async {
    final shoppingCartVM =
        Provider.of<ShoppingCart_ViewModel>(context, listen: false);

    if (id.isEmpty) {
      showDialogMessage(context,
          "Không tìm thấy id của sản phẩm trong giỏ hàng", DialogType.warning);
    } else {
      bool isSuccess = await shoppingCartVM.DeleteProductFormCart(id);
      if (isSuccess) {
        setState(() {
          _cartItems.removeWhere((item) => item['CartId'] == id);
          _calculateTotal();
        });
        showDialogMessage(
            context, "Đã xóa sản phẩm khỏi giỏ hàng", DialogType.success);
      } else {
        showDialogMessage(
            context, "Lỗi: ${shoppingCartVM.errorMessage}", DialogType.error);
      }
    }
  }

  void _updateQuantity(String id, int newQuantity) async {
    final shoppingCartVM =
        Provider.of<ShoppingCart_ViewModel>(context, listen: false);

    if (newQuantity < 1) {
      if (id.isEmpty) {
        showDialogMessage(
            context,
            "Không tìm thấy id của sản phẩm trong giỏ hàng",
            DialogType.warning);
      } else {
        bool isSuccess = await shoppingCartVM.DeleteProductFormCart(id);
        if (isSuccess) {
          setState(() {
            _cartItems.removeWhere((item) => item['CartId'] == id);
            _calculateTotal();
          });
          showDialogMessage(
              context, "Đã xóa sản phẩm khỏi giỏ hàng", DialogType.success);
        } else {
          showDialogMessage(
              context, "Lỗi: ${shoppingCartVM.errorMessage}", DialogType.error);
        }
      }
    } else {
      if (id.isEmpty) {
        showDialogMessage(
            context,
            "Không tìm thấy id của sản phẩm trong giỏ hàng",
            DialogType.warning);
      } else {
        bool isSuccess = await shoppingCartVM.UpdateQuantity(id, newQuantity);
        if (isSuccess) {
          setState(() {
            final index = _cartItems.indexWhere((item) => item['CartId'] == id);
            if (index != -1) {
              _cartItems[index]['Quantity'] = newQuantity;
              _calculateTotal();
            }
          });
        } else {
          showDialogMessage(
              context, "Lỗi: ${shoppingCartVM.errorMessage}", DialogType.error);
        }
      }
    }
  }

  void _calculateTotal() {
    _totalPrice = _cartItems.fold(
        0, (sum, item) => sum + (item['Price'] * item['Quantity']));
  }

  void _checkout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CheckoutForm(
          dataCart: _cartItems,
          totalAmount: _totalPrice,
        );
      },
    );
    if (result == true) {
      LoadAllData();
    }
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

  Widget _buildShimmerEffect(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.red,
    );
  }

  Widget _buildPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(Icons.fastfood, color: Colors.grey[400]),
    );
  }
}
