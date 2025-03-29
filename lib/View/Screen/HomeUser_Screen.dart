import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeUserScreen extends StatefulWidget {
  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildSectionTitle("Special Offers"),
          _buildSpecialOfferBanner(),
          const SizedBox(height: 20),
          _buildCategorySection(),
          const SizedBox(height: 20),
          _buildSectionTitle("Discount Guaranteed!"),
          _buildDiscountSection(),
        ],
      ),
    );
  }

  /// Ô tìm kiếm
  Widget _buildSearchBar() {
    return TextField(
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: "What are you craving?",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Tiêu đề từng section
  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {},
          child: const Text("See All", style: TextStyle(color: Color(0xFF4CAF50), fontSize: 13)),
        ),
      ],
    );
  }

  /// Banner ưu đãi đặc biệt
  Widget _buildSpecialOfferBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50), // Xanh lá
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "30%",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "DISCOUNT ONLY VALID FOR TODAY!",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          Image.asset('asset/images/logo.png', width: 80),
        ],
      ),
    );
  }

  /// Danh mục món ăn
  Widget _buildCategorySection() {
    List<Map<String, String>> categories = [
      {"name": "Hamburger", "icon": "🍔"},
      {"name": "Pizza", "icon": "🍕"},
      {"name": "Noodles", "icon": "🍜"},
      {"name": "Meat", "icon": "🥩"},
    ];

    return SizedBox(
      height: 120,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(categories[index]['icon']!, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(
                categories[index]['name']!,
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Danh sách món ăn có giảm giá
  Widget _buildDiscountSection() {
    return Row(
      children: [
        _buildPromoCard(),
        const SizedBox(width: 10),
        _buildPromoCard(),
      ],
    );
  }

  Widget _buildPromoCard() {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50), // Xanh lá
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("PROMO", style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset('asset/images/logo.png', width: 80),
            ),
          ],
        ),
      ),
    );
  }
}
