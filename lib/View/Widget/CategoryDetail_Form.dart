import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_food/ViewModels/Category_ViewModel.dart';
import 'package:provider/provider.dart';

import 'DialogMessage_Form.dart';

class CategoryDetail extends StatefulWidget {
  const CategoryDetail({super.key});

  @override
  State<CategoryDetail> createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  final TextEditingController txt_cateName = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void showDialogMessage(BuildContext context, String message,) {
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
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Thêm Danh Mục",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent.shade700,
              ),
            ),
            const SizedBox(height: 18),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  color: Colors.grey[200],
                ),
                child: ClipOval(
                  child: _selectedImage == null
                      ? const Icon(Icons.image_outlined,
                          size: 40, color: Colors.blueAccent)
                      : Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 15),

            /// Nhập tên danh mục
            TextField(
              controller: txt_cateName,
              decoration: InputDecoration(
                hintText: "Nhập tên danh mục...",
                prefixIcon: const Icon(Icons.category_outlined,
                    color: Colors.blueAccent),
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

            /// Nút hành động
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text(
                      "Hủy",
                      style: TextStyle(
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
                      if(_selectedImage != null){
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
                      }
                      else{
                        showDialogMessage(context,
                            "Vui lòng thêm ảnh của danh mục sản phẩm (UI)");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: categoryVM.isLoading
                        ? const SizedBox(
                            height: 18, // Giảm kích thước vòng tròn
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, // Làm nét vẽ mảnh hơn
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Thêm",
                            style: TextStyle(
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
