import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_food/ViewModels/Category_ViewModel.dart';
import 'package:provider/provider.dart';
import 'DialogMessage_Form.dart';

class CategoryDetail extends StatefulWidget {
  final Map<String, dynamic>? category;

  const CategoryDetail({super.key, required this.category});

  @override
  State<CategoryDetail> createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  late TextEditingController txt_cateName = TextEditingController();
  File? _selectedImage;
  bool _data = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.category?["CategoryID"] != null) {
      _data = true;
      txt_cateName =
          TextEditingController(text: widget.category?["CategoryName"] ?? "");
    } else {
      txt_cateName = TextEditingController();
      _data = false;
    }
  }

  void showDialogMessage(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: IntrinsicHeight(
            child: DialogMessageForm(
              message: message,
              intValue: Colors.blueAccent,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = Provider.of<Category_ViewModel>(context, listen: true);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _data ? "Chỉnh Sửa Danh Mục" : "Thêm Danh Mục",
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 20),

            /// Ảnh danh mục
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF003366), width: 2),
                  color: Colors.grey[200],
                ),
                child: ClipOval(
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : (widget.category != null &&
                              widget.category!['Image'] != null)
                          ? Image.network(widget.category!['Image'],
                              fit: BoxFit.cover)
                          : Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 18),

            TextField(
              controller: txt_cateName,
              style: GoogleFonts.montserrat(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Nhập tên danh mục...",
                hintStyle: GoogleFonts.montserrat(fontSize: 15),
                prefixIcon: const Icon(Icons.category_outlined,
                    color: Color(0xFF003366)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_data) {
                        bool isSuccess = await categoryVM.DeleteCategory(
                            widget.category?['CategoryID']);
                        print("UI ${widget.category?["CategoryID"]}");
                        if (isSuccess) {
                          Navigator.pop(context, true);
                          showDialogMessage(context, "Xóa sản phẩm thành công");
                        } else {
                          showDialogMessage(
                              context, "${categoryVM.errorMessage}");
                        }
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: categoryVM.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _data ? "Xóa" : "Hủy",
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_data) {
                        File? newImage = _selectedImage ?? null;
                        if (newImage != null ||
                            widget.category?["Image"] != null) {
                          bool isSuccess = await categoryVM.UpdateCategory(
                              widget.category?["CategoryID"],
                              txt_cateName.text,
                              null,
                              widget.category?["Image"]);
                          if (isSuccess) {
                            Navigator.pop(context, true);
                            showDialogMessage(
                                context, "Sửa danh mục sản phẩm thành công");
                          } else {
                            showDialogMessage(context,
                                "Sửa danh mục sản phẩm thất bại (UI) ${categoryVM.errorMessage}");
                          }
                        } else {
                          showDialogMessage(context,
                              "Vui lòng thêm ảnh của danh mục sản phẩm (UI)");
                        }
                      } else {
                        if (_selectedImage != null) {
                          bool isSuccess = await categoryVM.InsertCategory(
                              txt_cateName.text, _selectedImage!);
                          if (isSuccess) {
                            Navigator.pop(context, true);
                            showDialogMessage(
                                context, "Thêm danh mục sản phẩm thành công");
                          } else {
                            showDialogMessage(context,
                                "Thêm danh mục sản phẩm thất bại (UI) ${categoryVM.errorMessage}");
                          }
                        } else {
                          showDialogMessage(context,
                              "Vui lòng thêm ảnh của danh mục sản phẩm (UI)");
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: categoryVM.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _data ? "Lưu" : "Thêm",
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
