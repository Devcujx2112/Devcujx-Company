import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CheckoutForm extends StatefulWidget {
  final double totalAmount;

  const CheckoutForm({
    super.key,
    required this.totalAmount,
  });

  @override
  State<CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<CheckoutForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _paymentMethod = 'cod';
  final _deliveryFee = 15000;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.totalAmount + _deliveryFee;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_checkout, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Thanh toán đơn hàng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin nhận hàng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TextField Họ và tên
                      _buildTextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        label: 'Họ và tên',
                        icon: Icons.person_outline,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Vui lòng nhập tên người nhận'
                            : null,
                      ),
                      const SizedBox(height: 10),

                      // TextField Số điện thoại
                      _buildTextField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        label: 'Số điện thoại',
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Vui lòng nhập số điện thoại';
                          if (!RegExp(r'^(0|\+84)\d{9,10}$').hasMatch(value!)) {
                            return 'Số điện thoại không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // TextField Địa chỉ
                      _buildTextField(
                        controller: _addressController,
                        focusNode: _addressFocusNode,
                        label: 'Địa chỉ nhận hàng',
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Vui lòng nhập địa chỉ'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Phương thức thanh toán
                      const Text(
                        'Phương thức thanh toán',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildPaymentMethodCard(
                        value: 'cod',
                        title: 'Thanh toán khi nhận hàng',
                        subtitle: 'Tiền mặt hoặc quẹt thẻ khi giao hàng',
                        icon: Icons.attach_money,
                      ),
                      const SizedBox(height: 12),

                      _buildPaymentMethodCard(
                        value: 'banking',
                        title: 'Chuyển khoản ngân hàng',
                        subtitle: 'Thanh toán qua Internet Banking',
                        icon: Icons.account_balance_outlined,
                      ),
                      const SizedBox(height: 12),

                      _buildPaymentMethodCard(
                        value: 'ewallet',
                        title: 'Ví điện tử',
                        subtitle: 'Momo, ZaloPay, VNPay',
                        icon: Icons.wallet_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Tổng tiền
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _buildAmountRow(
                              'Tổng tiền hàng',
                              currencyFormat.format(widget.totalAmount),
                            ),
                            const SizedBox(height: 8),
                            _buildAmountRow(
                              'Phí vận chuyển',
                              currencyFormat.format(_deliveryFee),
                            ),
                            const Divider(height: 24, thickness: 1, color: Colors.green),
                            _buildAmountRow(
                              'Tổng thanh toán',
                              currencyFormat.format(total),
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'QUAY LẠI',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: const Text(
                        'XÁC NHẬN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.green, fontSize: 16),
        prefixIcon: Icon(icon, color: Colors.green, size: 27),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: _paymentMethod == value ? Colors.green : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _paymentMethod,
        onChanged: (value) => setState(() => _paymentMethod = value!),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: _paymentMethod == value ? Colors.green : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: _paymentMethod == value ? Colors.green : Colors.grey,
          ),
        ),
        secondary: Icon(
          icon,
          color: _paymentMethod == value ? Colors.green : Colors.grey,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildAmountRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isTotal ? Colors.green : Colors.black,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final orderInfo = {
        'customerName': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'paymentMethod': _paymentMethod,
        'orderTime': DateTime.now().toString(),
        'subtotal': widget.totalAmount,
        'deliveryFee': _deliveryFee,
        'total': widget.totalAmount + _deliveryFee,
      };
      // Navigator.of(context).pop(orderInfo);
    }
  }
}
