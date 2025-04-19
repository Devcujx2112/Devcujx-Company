import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/ProfileUser.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Order_ViewModel.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:order_food/ViewModels/ShoppingCart_ViewModel.dart';
import 'package:provider/provider.dart';

class CheckoutForm extends StatefulWidget {
  List<Map<String, dynamic>> dataCart;
  final double totalAmount;

  CheckoutForm({super.key, required this.totalAmount, required this.dataCart});

  @override
  State<CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<CheckoutForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _paymentMethod = 'cod';
  bool _isLoading = true;

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
  void initState() {
    super.initState();
    LoadAllData();
    print('UI data ${widget.dataCart}');
  }

  void LoadAllData() async {
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (authVM.uid!.isNotEmpty) {
      ProfileUser? profileUser =
          await profileVM.GetAllDataProfileUser(authVM.uid!);
      if (profileUser != null) {
        setState(() {
          _nameController.text = profileUser.fullName;
          _phoneController.text = profileUser.phone;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.totalAmount;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return ModalProgressHUD(
        inAsyncCall: _isLoading,
        progressIndicator:
            LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
        child: Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                Flexible(
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
                            maxlenght: 10,
                            label: 'Số điện thoại',
                            icon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                            isNumber: true,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              if (!RegExp(r'^(0|\+84)\d{9,10}$')
                                  .hasMatch(value!)) {
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
                          const SizedBox(height: 15),

                          const Text(
                            'Phương thức thanh toán',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 5),

                          _buildPaymentMethodCard(
                            value: 'cod',
                            title: 'Thanh toán khi nhận hàng',
                            subtitle: 'Tiền mặt hoặc quẹt thẻ khi giao hàng',
                            icon: Icons.attach_money,
                          ),
                          SizedBox(height: 5),
                          _buildPaymentMethodCard(
                            value: 'banking',
                            title: 'Chuyển khoản ngân hàng',
                            subtitle:
                                'Thanh toán an toàn qua tài khoản ngân hàng',
                            icon: Icons.account_balance,
                          ),

                          const SizedBox(height: 15),

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
                                const Divider(
                                    height: 24,
                                    thickness: 1,
                                    color: Colors.green),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        ));
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required FocusNode focusNode,
      required String label,
      required IconData icon,
      String? Function(String?)? validator,
      TextInputType? keyboardType,
      int? maxLines = 1,
      bool isNumber = false,
      int? maxlenght}) {
    return TextFormField(
      maxLength: maxlenght,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        counterText: "",
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

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    final orderVM = Provider.of<Order_ViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final cartVM = Provider.of<ShoppingCart_ViewModel>(context, listen: false);
    String uid;
    double total = double.parse(widget.totalAmount.toString());
    if (_formKey.currentState!.validate()) {
      if (_paymentMethod == "cod") {
        if (authVM.uid!.isEmpty) {
          showDialogMessage(
              context, "Không tìm thấy uid của tài khoản ", DialogType.warning);
          setState(() {
            _isLoading = false;
          });
          return;
        } else {
          uid = authVM.uid!;
          String paymentMethod = "Thanh toán khi nhận hàng";
          bool isSucess = await orderVM.InsertOrder(
              uid,
              _nameController.text,
              _phoneController.text,
              paymentMethod,
              _addressController.text,
              total,
              widget.dataCart);
          if (isSucess) {
            bool isSuccess = await cartVM.DeleteProductFormCart("");
            if (isSuccess == false) {
              return;
            }
            Navigator.of(context).pop(true);
            showDialogMessage(
                context, "Thêm đơn hàng thành công", DialogType.success);
            setState(() {
              _isLoading = false;
            });
          } else {
            showDialogMessage(
                context, "Lỗi: ${orderVM.errorMessage}", DialogType.error);
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
      if (_paymentMethod == "banking") {}
    }
    else{
      setState(() {
        _isLoading = false;
      });
    }
  }
}
