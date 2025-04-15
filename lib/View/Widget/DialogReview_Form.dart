import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Review_ViewModel.dart';
import 'package:provider/provider.dart';

import '../../Models/Product.dart';

class ReviewDialog extends StatefulWidget {
  final Product dataProduct;
  final String orderId;

  const ReviewDialog(
      {super.key, required this.dataProduct, required this.orderId});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final reviewVM = Provider.of<Review_ViewModel>(context, listen: false);
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    return ModalProgressHUD(
        inAsyncCall: _isLoading,
        progressIndicator: LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 10, 15, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.vertical(
                        top: Radius.circular(20)),
                    color: Colors.green,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Đánh giá sản phẩm',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                              image: DecorationImage(
                                image: NetworkImage(widget.dataProduct.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.dataProduct.productName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.dataProduct.storeName,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Rating
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _rating = index + 1),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 36,
                                      color: index < _rating
                                          ? Colors.amber[400]
                                          : Colors.grey[300],
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            if (_rating > 0)
                              Text(
                                _rating == 5
                                    ? 'Tuyệt vời!'
                                    : _rating == 4
                                        ? 'Rất tốt'
                                        : _rating == 3
                                            ? 'Tạm được'
                                            : _rating == 2
                                                ? 'Không hài lòng'
                                                : 'Rất tệ',
                                style: TextStyle(
                                  color: _rating <= 3
                                      ? (_rating == 3
                                          ? Colors.orange[600]
                                          : Colors.red)
                                      : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _reviewController,
                        maxLines: 4,
                        minLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Chia sẻ cảm nhận của bạn...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.green, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.green, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Tối thiểu 10 ký tự',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_rating == 0) {
                          showDialogMessage(
                              context,
                              "Vui lòng gửi đánh giá của sản phẩm",
                              DialogType.warning);
                          return;
                        }
                        if (_reviewController.text.isEmpty ||
                            _reviewController.text.length < 10) {
                          showDialogMessage(
                              context,
                              "Vui lòng điền bình luận của sản phẩm dài hơn 10 kí tự",
                              DialogType.warning);
                          return;
                        } else {
                          setState(() {
                            _isLoading = true;
                          });
                          bool isSuccess = await reviewVM.InsertReviewUser(
                              widget.dataProduct.productId,
                              authVm.uid!,
                              widget.dataProduct.uid,
                              _rating,
                              _reviewController.text,
                              widget.orderId);
                          if (isSuccess) {
                            Navigator.pop(context, true);
                            setState(() {
                              _isLoading = false;
                            });
                            showDialogMessage(
                                context,
                                "Gửi đánh giá sản phẩm thành công",
                                DialogType.success);
                          } else {
                            setState(() {
                              _isLoading = false;
                            });
                            showDialogMessage(
                                context,
                                "Gửi đánh giá sản phẩm thất bại ${reviewVM.errorMessage}",
                                DialogType.error);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'GỬI ĐÁNH GIÁ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> _submitReview() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
