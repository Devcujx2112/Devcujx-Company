import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:order_food/Models/ProfileUser.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:order_food/ViewModels/Review_ViewModel.dart';
import 'package:provider/provider.dart';

class ListReview extends StatefulWidget {
  Map<String, dynamic> dataReview;
  String productId;
  VoidCallback? reload;

  ListReview(
      {super.key,
      required this.dataReview,
      required this.productId,
      required this.reload});

  @override
  State<ListReview> createState() => _ListReviewState();
}

class _ListReviewState extends State<ListReview> {
  bool _isUpdate = true;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  ProfileUser? profileUser;
  double _selectedRatting = 0;
  TextEditingController comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    ShowAllData();
    print('UI data ${widget.dataReview}');
  }

  void ShowAllData() async {
    final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
    ProfileUser? dataUser =
        await profileVM.GetAllDataProfileUser(widget.dataReview["UserId"]);
    if (dataUser != null) {
      setState(() {
        profileUser = dataUser;
        comment.text = widget.dataReview["Comment"];
        _selectedRatting = widget.dataReview["Ratting"];
      });
    }
  }

  void UpdateComment() async {
    if (_isUpdate) {
      setState(() {
        _isUpdate = false;
      });
    } else {
      final reviewVM = Provider.of<Review_ViewModel>(context, listen: false);
      if (comment.text.length < 10) {
        showDialogMessage(context, "Bình luận phải có nhiều hơn 10 kí tự",
            DialogType.warning);
        return;
      }

      bool isSuccess = await reviewVM.UpdateComment(
          widget.dataReview["ReviewId"], comment.text, _selectedRatting);

      if (isSuccess && mounted) {
        showDialogMessage(context, "Chỉnh sửa bình luận thành công", DialogType.success);
        setState(() {
          _isUpdate = true;
          widget.dataReview["Comment"] = comment.text;
          widget.dataReview["Ratting"] = _selectedRatting;
          widget.reload?.call();
        });
      } else if (mounted) {
        showDialogMessage(
            context, "Thất bại: ${reviewVM.errorMessage}", DialogType.error);
      }
    }
  }

  void _showDiaLogDelete() async {
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
          'Bạn chắc chắn muốn xóa bình luận này? Thao tác này không thể hoàn tác.',
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
              DeleteComment();
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

  void DeleteComment() async {
    final reviewVM = Provider.of<Review_ViewModel>(context, listen: false);
    if(widget.dataReview["ReviewId"] != null){
      bool isSuccess = await reviewVM.DeleteComment(widget.dataReview["ReviewId"]);
      if(isSuccess){
        showDialogMessage(context, "Xóa bình luận thành công",DialogType.success );
        setState(() {
          ShowAllData();
          widget.reload?.call();
        });
      }
      else{
        showDialogMessage(context, "Xóa bình luận thất bại ${reviewVM.errorMessage}",DialogType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profileUser?.image != null
                      ? NetworkImage(profileUser!.image)
                      : null,
                  child: profileUser?.image == null
                      ? Center(
                          child: LoadingAnimationWidget.progressiveDots(
                              color: Colors.green, size: 30))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileUser?.fullName ?? 'Khách hàng',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dateFormat.format(
                            DateTime.parse(widget.dataReview["CreateAt"])),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRatingStars(
                    double.parse(widget.dataReview['Ratting'].toString()) ??
                        0.0),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: _isUpdate ? Colors.transparent : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: comment,
                style: const TextStyle(fontSize: 14, height: 1.4),
                readOnly: _isUpdate,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                  // Remove underline
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: _isUpdate ? null : 'Nhập bình luận...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            if (authVM.uid! == widget.dataReview["UserId"] ||
                authVM.role == "Admin")
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (authVM.uid! == widget.dataReview["UserId"])
                    TextButton(
                      onPressed: () {
                        UpdateComment();
                      },
                      child: Text(
                        _isUpdate ? "Sửa" : "Lưu",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (authVM.role == "Admin" ||
                      authVM.uid! == widget.dataReview["UserId"])
                    TextButton(
                      onPressed: () {
                        _showDiaLogDelete();
                      },
                      child: const Text(
                        "Xóa",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double currentRating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;

        return GestureDetector(
          onTap: _isUpdate
              ? null
              : () {
                  setState(() {
                    _selectedRatting = starIndex.toDouble();
                  });
                },
          child: Icon(
            starIndex <= _selectedRatting ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 24,
          ),
        );
      }),
    );
  }
}
