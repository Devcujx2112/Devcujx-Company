import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/Models/ProfileUser.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:order_food/ViewModels/Review_ViewModel.dart';
import 'package:provider/provider.dart';

import '../../Models/Replies.dart';

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
  ProfileSeller? profileSeller;
  double _selectedRatting = 0;
  TextEditingController txt_comment = TextEditingController();
  bool _isReplies = false;
  TextEditingController txt_replies = TextEditingController();
  Replies? replies;
  bool _isLoading = true;
  bool sellerUpdate = true;
  bool update = false;

  @override
  void initState() {
    super.initState();
    ShowAllData();
  }

  Future<void> ShowAllData() async {
    try {
      final profileVM = Provider.of<Profile_ViewModel>(context, listen: false);
      final reviewVM = Provider.of<Review_ViewModel>(context, listen: false);
      final authVM = Provider.of<AuthViewModel>(context, listen: false);

      if (authVM.role == "Seller") {
        setState(() {
          sellerUpdate = false;
        });
      }

      final results = await Future.wait([
        profileVM.GetAllDataProfileUser(widget.dataReview["UserId"]),
        profileVM.GetAllDataProfileSeller(widget.dataReview["SellerId"]),
        reviewVM.ShowRepliesComment(widget.dataReview["ReviewId"])
      ]);

      if (mounted) {
        setState(() {
          profileUser = results[0] as ProfileUser?;
          profileSeller = results[1] as ProfileSeller?;
          replies = results[2] as Replies?;
          txt_comment.text = widget.dataReview["Comment"];
          _selectedRatting = widget.dataReview["Ratting"];
          txt_replies.text = replies?.repText ?? "";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showDialogMessage(context, "Lỗi tải dữ liệu", DialogType.error);
      }
    }
  }

  void UpdateComment() async {
    if (_isUpdate) {
      setState(() {
        _isUpdate = false;
      });
    } else {
      final reviewVM = Provider.of<Review_ViewModel>(context, listen: false);
      if (txt_comment.text.length < 10) {
        showDialogMessage(context, "Bình luận phải có nhiều hơn 10 kí tự",
            DialogType.warning);
        return;
      }

      bool isSuccess = await reviewVM.UpdateComment(
          widget.dataReview["ReviewId"], txt_comment.text, _selectedRatting);

      if (isSuccess && mounted) {
        showDialogMessage(
            context, "Chỉnh sửa bình luận thành công", DialogType.success);
        setState(() {
          _isUpdate = true;
          widget.dataReview["Comment"] = txt_comment.text;
          widget.dataReview["Ratting"] = _selectedRatting;
          widget.reload?.call();
        });
      } else if (mounted) {
        showDialogMessage(
            context, "Thất bại: ${reviewVM.errorMessage}", DialogType.error);
      }
    }
  }

  void ShowUIUpdateReplies() {
    setState(() {
      _isReplies = true;
      sellerUpdate = false;
      update = true;
    });
  }

  void UpdateReplies() async {
    final reviewVM = Provider.of<Review_ViewModel>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    if (txt_replies.text.isEmpty) {
      showDialogMessage(
          context, "Vui lòng điền vào phản hồi của bạn", DialogType.warning);
      return;
    } else {
      if (replies?.repliesId != null) {
        bool isSuccess =
            await reviewVM.UpdateReplies(replies!.repliesId, txt_replies.text);
        if (isSuccess) {
          showDialogMessage(
              context, "Cập nhật phản hồi thành công", DialogType.success);
          setState(() {
            _isReplies = false;
            sellerUpdate = true;
            _isLoading = false;
            update = false;
          });
          return;
        } else {
          showDialogMessage(
              context, "Lỗi: ${reviewVM.errorMessage}", DialogType.error);
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
    }
  }

  void _showDiaLogDelete(String reviewId, String repliesId) async {
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
              if (reviewId.isNotEmpty) {
                DeleteComment(reviewId);
                Navigator.pop(context);
                return;
              }
              if (repliesId.isNotEmpty) {
                DeleteReplies(repliesId);
                Navigator.pop(context);
                return;
              }
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

  void DeleteReplies(String repliesId) async {
    setState(() {
      _isLoading = true;
    });
    final reviewVM = Provider.of<Review_ViewModel>(context, listen: false);
    bool isSuccess =
        await reviewVM.DeleteReplies(repliesId, widget.dataReview["ReviewId"]);
    if (isSuccess) {
      widget.reload?.call();
      await ShowAllData();
      showDialogMessage(context, "Xóa phản hồi thành công", DialogType.success);
      setState(() {
        txt_replies.clear();
        _isLoading = false;
      });
    } else {
      showDialogMessage(context,
          "Xóa phản hồi thất bại ${reviewVM.errorMessage}", DialogType.error);
      setState(() {
        _isLoading = false;
        _isReplies = false;
      });
      return;
    }
  }

  void DeleteComment(String reviewId) async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    final deletedData = widget.dataReview;

    try {
      final reviewVM = Provider.of<Review_ViewModel>(context, listen: false);
      final repliesId = replies?.repliesId;

      if (reviewId == null) {
        showDialogMessage(
            context, "ID bình luận không hợp lệ", DialogType.warning);
        return;
      }

      final isSuccess = await reviewVM.DeleteComment(reviewId, repliesId);

      if (!mounted) return;

      if (!isSuccess) {
        setState(() => widget.dataReview = deletedData);
        showDialogMessage(context, "Xóa thất bại: ${reviewVM.errorMessage}",
            DialogType.error);
        return;
      }
      widget.reload?.call();
      await ShowAllData();

      showDialogMessage(context, "Xóa thành công", DialogType.success);
    } catch (e) {
      if (mounted) {
        setState(() => widget.dataReview = deletedData);
        showDialogMessage(
            context, "Lỗi hệ thống: ${e.toString()}", DialogType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void InsertRepliesComment(String sellerId) async {
    final reviewVM = Provider.of<Review_ViewModel>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    if (txt_replies.text.isNotEmpty) {
      bool isSuccess = await reviewVM.InsertRepliesComment(
          widget.dataReview["ReviewId"], sellerId, txt_replies.text);
      if (isSuccess) {
        setState(() {
          _isReplies = false;
          ShowAllData();
          widget.reload!.call();
          _isLoading = false;
        });
      } else {
        showDialogMessage(
            context,
            "Lỗi khi gửi phản hồi tới người dùng ${reviewVM.errorMessage}",
            DialogType.error);
      }
    } else {
      showDialogMessage(
          context, "Hãy nhập phản hồi của bạn", DialogType.warning);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (_isLoading) {
      return _buildLoadingShimmer();
    }
    return Card(
      elevation: 4,
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
                controller: txt_comment,
                style: const TextStyle(fontSize: 14),
                readOnly: _isUpdate,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.only(top: 5, left: 10, bottom: 5),
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
                        _showDiaLogDelete(widget.dataReview["ReviewId"], "");
                      },
                      child: const Text(
                        "Xóa",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            if (widget.dataReview["RepliesId"].toString().isNotEmpty ||
                sellerUpdate == false)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: profileSeller?.image != null
                                ? NetworkImage(profileSeller!.image)
                                : null,
                            child: profileSeller?.image == null
                                ? Center(
                                    child:
                                        LoadingAnimationWidget.progressiveDots(
                                            color: Colors.green, size: 30))
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profileSeller?.storeName ?? "Loading...",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  replies?.createAt != null
                                      ? _dateFormat.format(
                                          DateTime.parse(replies!.createAt))
                                      : "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if ((widget.dataReview["SellerId"] == authVM.uid ||
                                  authVM.role == "Admin") &&
                              txt_replies.text.isNotEmpty)
                            Row(
                              children: [
                                if (widget.dataReview["SellerId"] == authVM.uid)
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        size: 18, color: Colors.blueAccent),
                                    onPressed: () {
                                      ShowUIUpdateReplies();
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      size: 18, color: Colors.red[300]),
                                  onPressed: () {
                                    String repliesId = replies!.repliesId;
                                    if (repliesId.isNotEmpty) {
                                      _showDiaLogDelete("", replies!.repliesId);
                                    } else {
                                      showDialogMessage(
                                          context,
                                          "Id replies is empty",
                                          DialogType.warning);
                                      return;
                                    }
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                readOnly: sellerUpdate,
                                controller: txt_replies,
                                maxLines: 3,
                                minLines: 1,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                                decoration: InputDecoration(
                                  hintText: "Nhập phản hồi của bạn...",
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.all(16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.green.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.green,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      if (widget.dataReview["RepliesId"].toString().isEmpty ||
                          _isReplies)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isReplies = !_isReplies;
                                  sellerUpdate = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey,
                                elevation: 7,
                                padding: EdgeInsets.all(2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor: Colors.green.withOpacity(0.3),
                              ),
                              child: Text(
                                "HỦY",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (update) {
                                  UpdateReplies();
                                  return;
                                } else {
                                  InsertRepliesComment(authVM.uid!);
                                  return;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 7,
                                padding: EdgeInsets.all(2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor: Colors.green.withOpacity(0.3),
                              ),
                              child: Text(
                                "LƯU",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.grey, size: 20),
                    Icon(Icons.star, color: Colors.grey, size: 20),
                    Icon(Icons.star, color: Colors.grey, size: 20),
                    Icon(Icons.star, color: Colors.grey, size: 20),
                    Icon(Icons.star, color: Colors.grey, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 60,
              color: Colors.grey,
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
