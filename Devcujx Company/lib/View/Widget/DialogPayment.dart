
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:order_food/View/Screen/CartUser_Screen.dart';
import 'package:order_food/View/Screen/OrderUser_Screen.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/ShoppingCart_ViewModel.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Models/Payment.dart';
import '../../Models/PaymentLinkResponse.dart';
import '../../Models/PaymentStatusResponse.dart';
import '../../ViewModels/Auth_ViewModel.dart';
import '../../ViewModels/Order_ViewModel.dart';

class DialogPayment extends StatefulWidget {
  double total;
  String nameUser;
  String phoneUser;
  String addressUser;
  List<Map<String, dynamic>> dataCart;
  final VoidCallback onPaymentSuccess;

  DialogPayment(
      {super.key, required this.total, required this.nameUser, required this.phoneUser, required this.addressUser,required this.dataCart, required this.onPaymentSuccess});

  @override
  State<DialogPayment> createState() {
    return _DialogPaymentState();
  }
}

WebViewEnvironment? webViewEnvironment;

class _DialogPaymentState extends State<DialogPayment> {
  final GlobalKey webViewKey = GlobalKey();
  late Future<Payment> paymentLink;
  late Future<List<DeepLinkItemResponse>> deepLinkList;

  @override
  void initState() {
    super.initState();
    ShowAllData();
  }

  void ShowAllData() {
    final cartVM = Provider.of<ShoppingCart_ViewModel>(context, listen: false);
    int totalInt = widget.total.round();
    paymentLink = cartVM.createPaymentLink(totalInt);
    deepLinkList = cartVM.getDeepLinkList();
  }

  String _formatAmount(int amount) {
    final currencyFormat = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: 'VNĐ',
        decimalDigits: 0
    );

    if (amount >= 1000000) {
      double millions = amount / 1000000;
      return '${millions.toStringAsFixed(
          millions.truncateToDouble() == millions ? 0 : 1)}M';
    }
    return currencyFormat.format(amount);
  }

  void _isSuccessPayment() async {
    final cartVM = Provider.of<ShoppingCart_ViewModel>(context, listen: false);
    final orderVM = Provider.of<Order_ViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);


    if (authVM.uid?.isEmpty ?? true) {
      showDialogMessage(
          context, "Không tìm thấy uid của tài khoản", DialogType.warning);
      return;
    }

    String paymentMethod = "Chuyển khoản qua ngân hàng";
    bool isSuccess = await orderVM.InsertOrder(
      authVM.uid!,
      widget.nameUser,
      widget.phoneUser,
      paymentMethod,
      widget.addressUser,
      widget.total,
      widget.dataCart,
    );

    if (isSuccess) {
      bool deleted = await cartVM.DeleteProductFormCart("");
      if (!deleted) return;

      widget.onPaymentSuccess();

      Navigator.of(context).pop();
      Navigator.of(context).pop();

      showDialogMessage(
          context, "Thêm đơn hàng thành công", DialogType.success);

    } else {
      showDialogMessage(
          context, "Lỗi: ${orderVM.errorMessage}", DialogType.error);
    }
  }


  @override
  Widget build(BuildContext context) {
    final cartVM = Provider.of<ShoppingCart_ViewModel>(context, listen: false);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 612),
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Payment>(
          future: paymentLink,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<PaymentStatusResponse>(
                    stream: Stream.periodic(const Duration(seconds: 1))
                        .asyncMap(
                            (i) => cartVM.getPaymentStatus(data.orderCode)),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        dynamic result = snapshot.data?.data;
                        if (result['status'] == "PAID" && context.mounted) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _isSuccessPayment();
                          });
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      width: 300,
                      image:
                      'https://img.vietqr.io/image/${data.bin}-${data
                          .accountNumber}-vietqr_pro.png?amount=${data
                          .amount}&addInfo=${data
                          .description}&accountName=${data.accountName}'),
                  const SizedBox(height: 12),
                  CustomInfo(label: "Tên tài khoản:", info: data.accountName),
                  CustomInfo(label: "Số tài khoản:", info: "0364703365"),
                  CustomInfo(
                      label: "Số tiền:", info: _formatAmount(data.amount)),
                  CustomInfo(label: "Nội dung:", info: data.description),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Đóng'),
                  ),
                ],
              );
            } else {
              return const Text('Lỗi tải dữ liệu');
            }
          },
        ),
      ),
    );
  }
}

class BankButton extends StatelessWidget {
  final String label;
  final String bankId;
  final String amount;
  final String bankLogo;
  final String accountNo;
  final String des;
  late Color? bgColor;
  late Color? textColor;

  BankButton({super.key,
    required this.label,
    this.bgColor,
    this.textColor,
    required this.bankId,
    required this.amount,
    required this.bankLogo,
    required this.accountNo,
    required this.des});

  @override
  Widget build(BuildContext context) {
    const redirectUrl = 'https://payos-flutter-demo.netlify.app/success';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 85.0, minWidth: 85.0),
      child: TextButton(
        onPressed: () async {
          final deepLink = Uri.parse(
              'https://dl.vietqr.io/pay?app=${bankId}&ba=$accountNo&am=$amount&tn=$des&redirect_url=$redirectUrl');
          if (await canLaunchUrl(deepLink)) {
            await launchUrl(deepLink, mode: LaunchMode.externalApplication);
          }
        },
        style: TextButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  placeholderColor: Colors.amber,
                  width: 45,
                  image: bankLogo),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              margin: const EdgeInsets.only(top: 3),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

class CustomInfo extends StatelessWidget {
  final String label;
  final String info;

  const CustomInfo({super.key, required this.label, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Text(
              info,
              style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ],
        ));
  }
}
