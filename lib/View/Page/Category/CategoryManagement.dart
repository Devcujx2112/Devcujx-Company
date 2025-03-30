import 'dart:io';

import 'package:flutter/material.dart';
import 'package:order_food/View/Widget/CategoryDetail_Form.dart';
import 'package:provider/provider.dart';

import '../../../ViewModels/Category_ViewModel.dart';
import '../../Widget/DialogMessage_Form.dart';

class CategoryManagement extends StatefulWidget {
  const CategoryManagement({super.key});

  @override
  State<CategoryManagement> createState() => _CategoryManagementState();
}

class _CategoryManagementState extends State<CategoryManagement> {
  List<Map<String, dynamic>>? allCategories = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  int? catelogyCount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final categoryVM =
          Provider.of<Category_ViewModel>(context, listen: false);
      List<Map<String, dynamic>>? fetchedUsers =
          await categoryVM.ShowAllCategory(_searchController.text) ?? [];
      setState(() {
        allCategories = fetchedUsers;
        catelogyCount = allCategories?.length;
        _isLoading = false;
        SearchCategories();
      });
    });
  }

  void SearchCategories() async {
    final categoryVM = Provider.of<Category_ViewModel>(context, listen: false);
    List<Map<String, dynamic>>? fetchedCategories =
        await categoryVM.ShowAllCategory(_searchController.text) ?? [];

    setState(() {
      allCategories = fetchedCategories;
      catelogyCount = allCategories?.length;
      _isLoading = false;
    });
  }

  void addCategory() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CategoryDetail();
      },
    );

    if (result == true) {
      SearchCategories();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý danh mục",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value){
                      SearchCategories();
                    },
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm danh mục...",
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Tổng số loại sản phẩm",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          catelogyCount.toString(),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(
                          child: Divider(
                              thickness: 2,
                              color: Colors.blueAccent,
                              endIndent: 10)),
                      Text(
                        "Danh sách danh mục",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D3A62)),
                      ),
                      Expanded(
                          child: Divider(
                              thickness: 2,
                              color: Colors.deepPurple,
                              indent: 10)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      itemCount: allCategories?.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final category = allCategories?[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Image.network(category?["Image"]!)),
                                const SizedBox(height: 8),
                                Text(category?["CategoryName"]!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCategory,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
