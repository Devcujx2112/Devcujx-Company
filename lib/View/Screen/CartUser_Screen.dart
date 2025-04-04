import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CartUserScreen extends StatefulWidget {
  const CartUserScreen({super.key});

  @override
  State<CartUserScreen> createState() => _CartUserScreenState();
}

class _CartUserScreenState extends State<CartUserScreen> {
  bool _isLoading = false;
  double _totalPrice = 0.0;

  // Danh sách sản phẩm giả lập
  List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'name': 'Bánh mì thịt nướng',
      'price': 25000.0,
      'quantity': 2,
      'image': 'https://via.placeholder.com/150',
    },
    {
      'id': '2',
      'name': 'Cà phê sữa đá',
      'price': 20000.0,
      'quantity': 1,
      'image': 'https://via.placeholder.com/150',
    },
    {
      'id': '3',
      'name': 'Phở bò',
      'price': 45000.0,
      'quantity': 3,
      'image': 'https://via.placeholder.com/150',
    },
  ];

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  void _calculateTotal() {
    _totalPrice = 0.0;
    for (var item in _cartItems) {
      _totalPrice += (item['price'] * item['quantity']);
    }
    setState(() {});
  }

  void _removeItem(String id) {
    setState(() {
      _cartItems.removeWhere((item) => item['id'] == id);
      _calculateTotal();
    });
  }

  void _updateQuantity(String id, int newQuantity) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _cartItems[index]['quantity'] = newQuantity;
        _calculateTotal();
      }
    });
  }

  void _checkout() {
    setState(() => _isLoading = true);
    // Giả lập quá trình thanh toán
    Future.delayed(Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thanh toán thành công!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
          LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "Giỏ hàng",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green,
        ),
        body: Column(
          children: [
            Expanded(
              child: _cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Giỏ hàng trống',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return _buildCartItem(item);
                      },
                    ),
            ),
            if (_cartItems.isNotEmpty) _buildCheckoutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Hình ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 12),
            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${item['price'].toStringAsFixed(0).replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        )}đ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Điều chỉnh số lượng
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (item['quantity'] > 1) {
                      _updateQuantity(item['id'], item['quantity'] - 1);
                    }
                  },
                ),
                Text(
                  item['quantity'].toString(),
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _updateQuantity(item['id'], item['quantity'] + 1);
                  },
                ),
              ],
            ),
            // Nút xóa
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeItem(item['id']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),),
      child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng cộng:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_totalPrice.toStringAsFixed(0).replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        )}đ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _checkout,
                  child: Text(
                    'THANH TOÁN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
