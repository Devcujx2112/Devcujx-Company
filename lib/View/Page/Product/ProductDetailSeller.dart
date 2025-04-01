import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Category_ViewModel.dart';
import 'package:order_food/ViewModels/Product_ViewModel.dart';
import 'package:provider/provider.dart';

import '../../Widget/DialogMessage_Form.dart';

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
  late List<String> _categories = [];
  bool _isDataOld = false;
  bool _isLoading = true;

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
          _isLoading = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final productVM = Provider.of<Product_ViewModel>(context, listen: true);
    return ModalProgressHUD(
        inAsyncCall: _isLoading,
        progressIndicator: LoadingAnimationWidget.inkDrop(
            color: Colors.green, size: 50),
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
                      showDialogMessage(context, "Xóa sản phẩm thành công",
                          DialogType.success);
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                      showDialogMessage(
                          context,
                          "Xóa sản phẩm thất bại (UI) ${productVM
                              .errorMessage}",
                          DialogType.error);
                    }
                  },
                ),
            ],
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
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
                                    borderRadius:
                                    BorderRadius.circular(15),
                                    border: Border.all(
                                        color: Colors.green, width: 1),
                                    image:  _image != null
                                        ? DecorationImage(
                                      image: FileImage(_image!),
                                      fit: BoxFit.cover,
                                    )
                                        : (_isDataOld
                                        ? DecorationImage(
                                      image: NetworkImage(widget.productData?["Image"] ?? ""),
                                      fit: BoxFit.cover,
                                    )
                                        : null),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 5),
                                      ),
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
                            _buildDropdownField("Danh mục", _categories,
                                _selectedCategory, (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                }),
                            const SizedBox(height: 10),
                            _buildTextField("Giá sản phẩm", txt_price,
                                keyboardType: TextInputType.number),
                            const SizedBox(height: 10),
                            _buildTextField("Mô tả sản phẩm", txt_desc,
                                maxLines: 3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 18,
                left: 16,
                right: 16,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_isDataOld) {
                        if (txt_desc.text.isEmpty || txt_price.text.isEmpty ||
                            txt_desc.text.isEmpty ||
                            _selectedCategory!.isEmpty) {
                          showDialogMessage(context,
                              "Vui lòng điền đầy đủ thông tin sản phẩm",
                              DialogType.warning);
                          return;
                        }
                        else {
                          setState(() {
                            _isLoading = true;
                          });
                          int? price = int.tryParse(txt_price.text.replaceAll(RegExp(r'[,.]'), ''));
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
                                context, "Update thông tin sản phẩm thành công",
                                DialogType.success);
                            setState(() {
                              _isLoading = false;
                            });
                          }
                          else {
                            setState(() {
                              _isLoading = false;
                            });
                            showDialogMessage(context,
                                "Update thông tin sản phẩm thất bại (UI): ${productVM
                                    .errorMessage}", DialogType.error);
                          }
                        }
                      } else {
                        if (_image == null) {
                          showDialogMessage(
                              context,
                              "Vui lòng thêm ảnh của sản phẩm",
                              DialogType.warning);
                          return;
                        } else {
                          if (txt_price.text.isEmpty ||
                              txt_desc.text.isEmpty ||
                              txt_desc.text.isEmpty ||
                              _selectedCategory == null) {
                            showDialogMessage(
                                context,
                                "Vui lòng điền đầy đủ thông tin sản phẩm",
                                DialogType.warning);
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                          });
                          int? price = int.parse(
                              txt_price.text.replaceAll('.', ''));
                          bool isSuccess = await productVM.InsertProduct(
                              uid,
                              _selectedCategory!,
                              txt_name.text,
                              price,
                              txt_desc.text,
                              _image!);

                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                          if (isSuccess) {
                            showDialogMessage(
                                context,
                                "Thêm sản phẩm thành công",
                                DialogType.success);
                            setState(() {
                              InsertSuccessfull();
                              _isLoading = false;
                            });
                          } else {
                            showDialogMessage(
                                context,
                                "Thêm sản phẩm thất bại ${productVM
                                    .errorMessage}",
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
            ],
          ),
        ));
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
