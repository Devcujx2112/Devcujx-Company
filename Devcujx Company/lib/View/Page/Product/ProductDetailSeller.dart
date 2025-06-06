import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/Models/ProfileSeller.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Category_ViewModel.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'package:order_food/ViewModels/Profile_ViewModel.dart';
import 'package:order_food/ViewModels/Review_ViewModel.dart';
import 'package:provider/provider.dart';

import '../../Widget/DialogMessage_Form.dart';
import '../../Widget/ListReview.dart';

class ProductDetailSeller extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const ProductDetailSeller({super.key, this.productData});

  @override
  State<ProductDetailSeller> createState() => _ProductDetailSellerState();
}

class _ProductDetailSellerState extends State<ProductDetailSeller> {
  final TextEditingController txt_name = TextEditingController();
  final TextEditingController txt_price = TextEditingController();
  final TextEditingController txt_desc = TextEditingController();
  String? _selectedCategory;
  File? _image;
  String uid = "";
  String storeName = "";
  late List<String> _categories = [];
  bool _isNullReview = true;
  bool _isDataOld = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> dataReview = [];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  void InsertSuccessfull() {
    setState(() {
      txt_price.text = "";
      txt_desc.text = "";
      txt_name.text = "";
      _selectedCategory = null;
      _image = null;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final categoryVM =
          Provider.of<Category_ViewModel>(context, listen: false);
      List<Map<String, dynamic>>? dataCategory =
          await categoryVM.ShowAllCategory("");
      setState(() {
        if (authVM.uid != null) {
          uid = authVM.uid!;
          _categories = dataCategory
                  ?.map((category) => category['CategoryName'] as String)
                  .toList() ??
              [];
          if (widget.productData != null) {
            _isDataOld = true;
            _selectedCategory = widget.productData!["CategoryName"];
            txt_price.text =
                NumberFormat("#,###").format(widget.productData!["Price"]);
            txt_name.text = widget.productData!["ProductName"];
            txt_desc.text = widget.productData!["Description"];
          }
          LoadStoreName(authVM.uid!);
          _isLoading = false;
        }
      });
      ShowAllData();
    });
  }

  void ShowAllData() async {
    final reviewVM = Provider.of<Review_ViewModel>(context, listen: false);
    if (widget.productData != null) {
      List<Map<String, dynamic>> dataReviewDB =
          await reviewVM.ShowAllDataReview(widget.productData!["ProductId"]);
      if (dataReviewDB != []) {
        setState(() {
          dataReview = dataReviewDB;
          _isNullReview = false;
        });
      }
    }
  }

  Future<void> LoadStoreName(String uid) async {
    final profile = Provider.of<Profile_ViewModel>(context, listen: false);
    ProfileSeller? profileSeller = await profile.GetAllDataProfileSeller(uid);
    if (profileSeller != null) {
      storeName = profileSeller.storeName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productVM = Provider.of<Product_ViewModel>(context, listen: true);
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
          LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            _isDataOld ? "Chỉnh sửa sản phẩm" : "Thêm Sản Phẩm",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 19,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, true),
          ),
          actions: [
            if (_isDataOld)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  bool isSuccess = await productVM.DeleteProduct(
                      widget.productData?["ProductId"]);
                  if (isSuccess) {
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pop(context, true);
                    showDialogMessage(
                        context, "Xóa sản phẩm thành công", DialogType.success);
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                    showDialogMessage(
                        context,
                        "Xóa sản phẩm thất bại (UI) ${productVM.errorMessage}",
                        DialogType.error);
                  }
                },
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.green, width: 1),
                            image: _image != null
                                ? DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                                : (_isDataOld
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            widget.productData?["Image"] ?? ""),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 5),
                              )
                            ],
                          ),
                          child: _isDataOld || _image != null
                              ? null
                              : const Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildTextField("Tên sản phẩm", txt_name),
                    const SizedBox(height: 10),
                    _buildDropdownField(
                        "Danh mục", _categories, _selectedCategory, (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }),
                    const SizedBox(height: 10),
                    _buildTextField("Giá sản phẩm", txt_price,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    _buildTextField("Mô tả sản phẩm", txt_desc, maxLines: 3),
                    const SizedBox(height: 20),
                    Divider(color: Colors.green, thickness: 1.5),
                    const SizedBox(height: 15),
                    if (widget.productData != null)
                      _buildReviewList(widget.productData!["ProductId"]),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_isDataOld) {
                  if (txt_desc.text.isEmpty ||
                      txt_price.text.isEmpty ||
                      txt_desc.text.isEmpty ||
                      _selectedCategory!.isEmpty) {
                    showDialogMessage(
                        context,
                        "Vui lòng điền đầy đủ thông tin sản phẩm",
                        DialogType.warning);
                    return;
                  } else {
                    setState(() {
                      _isLoading = true;
                    });
                    int? price = int.tryParse(
                        txt_price.text.replaceAll(RegExp(r'[,.]'), ''));
                    bool isSuccess = await productVM.UpdateProduct(
                        widget.productData!["ProductId"],
                        txt_name.text,
                        _selectedCategory!,
                        txt_desc.text,
                        price!,
                        widget.productData!["Image"],
                        _image);

                    if (isSuccess) {
                      showDialogMessage(
                          context,
                          "Cập nhật thông tin sản phẩm thành công",
                          DialogType.success);
                      setState(() {
                        _isLoading = false;
                      });
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                      showDialogMessage(
                          context,
                          "Update thông tin sản phẩm thất bại (UI): ${productVM.errorMessage}",
                          DialogType.error);
                    }
                  }
                } else {
                  if (txt_desc.text.isEmpty ||
                      txt_price.text.isEmpty ||
                      txt_desc.text.isEmpty ||
                      _selectedCategory!.isEmpty || _image == null) {
                    showDialogMessage(
                        context,
                        "Vui lòng điền đầy đủ thông tin sản phẩm",
                        DialogType.warning);
                    return;
                  }
                  else {
                    setState(() {
                      _isLoading = true;
                    });
                    int? price = int.tryParse(
                        txt_price.text.replaceAll(RegExp(r'[,.]'), ''));
                    bool isSuccess = await productVM.InsertProduct(
                        uid, storeName,_selectedCategory! , txt_name.text, price!, txt_desc.text,_image!);

                    if (isSuccess) {
                      Navigator.pop(context,true);
                      showDialogMessage(
                          context,
                          "Thêm sản phẩm thành công",
                          DialogType.success);
                      setState(() {
                        _isLoading = false;
                      });
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                      showDialogMessage(
                          context,
                          "Thêm sản phẩm thất bại (UI): ${productVM.errorMessage}",
                          DialogType.error);
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadowColor: Colors.black38,
                elevation: 5,
              ),
              child: const Text(
                "Lưu sản phẩm",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewList(String productId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Đánh giá & Bình luận",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        if (_isNullReview)
          SizedBox(
            height: 100,
            child: Center(
              child: LoadingAnimationWidget.inkDrop(
                color: Colors.green,
                size: 35,
              ),
            ),
          )
        else if (dataReview.isEmpty)
          SizedBox(
            height: 60,
            child: Center(
              child: Text(
                "Chưa có đánh giá",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...dataReview.map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ListReview(
                    dataReview: review,
                    productId: productId,
                    reload: ShowAllData,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Colors.green),
      inputFormatters: label == "Giá sản phẩm"
          ? [FilteringTextInputFormatter.digitsOnly]
          : [],
      onChanged: (value) {
        if (label == "Giá sản phẩm" && value.isNotEmpty) {
          int? parsedPrice = int.tryParse(value.replaceAll('.', ''));
          if (parsedPrice != null) {
            controller.value = TextEditingValue(
              text: NumberFormat("#,###", "vi_VN").format(parsedPrice),
              selection: TextSelection.collapsed(
                  offset: NumberFormat("#,###", "vi_VN")
                      .format(parsedPrice)
                      .length),
            );
          }
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: Colors.green, fontWeight: FontWeight.w500, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        suffixText: label == "Giá sản phẩm" ? "VNĐ" : null,
        // Thêm đơn vị VNĐ
        suffixStyle:
            const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget Dropdown chọn danh mục, nhỏ hơn và có màu xanh
  Widget _buildDropdownField(String label, List<String> items,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      hint: Text(
        label,
        style: TextStyle(
            fontSize: 14, color: Colors.green, fontWeight: FontWeight.w500),
      ),
      style: TextStyle(fontSize: 14, color: Colors.green),
      // Chữ màu xanh
      items: items.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w500)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.green, fontWeight: FontWeight.w500, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        // Giảm chiều cao
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}
