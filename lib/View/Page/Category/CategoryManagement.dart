import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        return CategoryDetail(
          category: null,
        );
      },
    );
    if (result == true) {
      SearchCategories();
    }
  }

  void OnClickItemCategories(Map<String, dynamic> user) async {
    final shouldReload = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return CategoryDetail(
            category: user,
          );
        });
    if (shouldReload == true) {
      SearchCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "Quản lý danh mục",
          style: GoogleFonts.montserrat(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF003366),
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
          children: [
            TextField(
              style: TextStyle(fontSize: 13, color: Color(0xFF003366)),
              controller: _searchController,
              onChanged: (value) => SearchCategories(),
              decoration: InputDecoration(
                hintText: "Tìm kiếm danh mục...",
                hintStyle: GoogleFonts.montserrat(fontSize: 13),
                prefixIcon:
                const Icon(Icons.search, color: Color(0xFF003366)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF003366).withOpacity(0.6),
                    Color(0xFF003366)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF003366).withOpacity(0.8),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Tổng số loại sản phẩm",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    catelogyCount.toString(),
                    style: GoogleFonts.montserrat(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                    child: Divider(
                        thickness: 2,
                        color: Colors.blueAccent,
                        endIndent: 10)),
                Text(
                  "Danh sách danh mục",
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                const Expanded(
                    child: Divider(
                        thickness: 2,
                        color: Colors.blueAccent,
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
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: InkWell(
                      onTap: () {
                        OnClickItemCategories(allCategories![index]);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                category?["Image"]!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category?["CategoryName"]!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
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
        backgroundColor: const Color(0xFF003366),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
