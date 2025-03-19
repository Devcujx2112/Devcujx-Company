import 'package:flutter/material.dart';

class UserOrSellerPage extends StatefulWidget {
  const UserOrSellerPage({super.key});

  @override
  State<UserOrSellerPage> createState() => _UserOrSellerPageState();
}

class _UserOrSellerPageState extends State<UserOrSellerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh nền phủ toàn màn hình
          Positioned.fill(
            child: Image.asset(
              'asset/images/backgrUserSeller.png',
              fit: BoxFit.cover,
            ),
          ),

          // Đưa nội dung xuống cuối màn hình
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50), // Khoảng cách từ đáy màn hình
              child: Column(
                mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian cần thiết
                children: [
                  // Nút "Bạn là người mua hàng?"
                  OutlinedButton(
                    onPressed: () {
                      // Xử lý khi chọn "người mua hàng"
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 40),
                      side: const BorderSide(color: Colors.red, width: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Bạn là người mua hàng?",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                          fontFamily: "Outfit"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Chữ "or"
                  const Text(
                    "or",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Outfit"),
                  ),

                  const SizedBox(height: 10),

                  // Nút "Bạn là người bán hàng?"
                  ElevatedButton(
                    onPressed: () {
                      // Xử lý khi chọn "người bán hàng"
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Bạn là người bán hàng..?",
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
