import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class PurchasePolicy extends StatelessWidget {
  final String roleAccount;

  PurchasePolicy({super.key, required this.roleAccount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          roleAccount == "Seller" ? "Chính sách dành cho người bán": "Chính sách mua hàng",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: roleAccount == "Seller" ?  _buildSellerPolicy() : _buildUserPolicy() ,
    );
  }

  Widget _buildUserPolicy() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: "1. Quy tắc đặt hàng",
          content:
          "• Vui lòng kiểm tra kỹ thông tin sản phẩm trước khi đặt.\n"
              "• Sau khi đặt hàng, bạn sẽ nhận được email xác nhận đơn hàng.\n"
              "• Chúng tôi có quyền từ chối các đơn hàng có dấu hiệu gian lận.",
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "2. Lưu ý khi thanh toán",
          content:
          "• Hỗ trợ thanh toán qua Momo, ZaloPay, chuyển khoản và tiền mặt.\n"
              "• Vui lòng kiểm tra kỹ thông tin trước khi xác nhận thanh toán.\n"
              "• Không hoàn tiền đối với các sản phẩm đã giao thành công trừ khi có lỗi sản phẩm.",
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "3. Lưu ý khi nhận hàng",
          content: "• Kiểm tra sản phẩm ngay khi nhận hàng.\n"
              "• Nếu sản phẩm bị lỗi hoặc sai, vui lòng liên hệ trong vòng 24h.\n"
              "• Chúng tôi không chịu trách nhiệm nếu người dùng không kiểm tra và phản hồi kịp thời.",
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "4. Chính sách đổi trả",
          content:
          "• Sản phẩm chỉ được đổi trả nếu còn nguyên tem, bao bì và chưa qua sử dụng.\n"
              "• Thời gian đổi trả: 3 ngày kể từ ngày nhận hàng.\n"
              "• Mọi chi phí phát sinh do lỗi của khách hàng sẽ do khách hàng chịu.",
        ),
      ],
    );
  }

  Widget _buildSellerPolicy() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: "1. Quy định về sản phẩm",
          content:
          "• Sản phẩm phải đúng với mô tả và hình ảnh đăng tải.\n"
              "• Cấm bán hàng giả, hàng nhái, hàng vi phạm bản quyền.\n"
              "• Phải cập nhật tình trạng hàng hóa thường xuyên.",
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "2. Chính sách giá cả",
          content:
          "• Giá bán phải bao gồm tất cả phí (nếu có).\n"
              "• Không được tăng giá đột ngột không có lý do chính đáng.\n"
              "• Phải thông báo trước ít nhất 3 ngày nếu có thay đổi giá.",
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "3. Quy trình xử lý đơn hàng",
          content:
          "• Phải xác nhận đơn hàng trong vòng 12 giờ.\n"
              "• Giao hàng đúng thời gian đã cam kết với khách.\n"
              "• Thông báo ngay nếu có bất kỳ trục trặc nào với đơn hàng.",
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "4. Chính sách vận chuyển",
          content:
          "• Chịu trách nhiệm đóng gói đảm bảo hàng hóa an toàn.\n"
              "• Phối hợp với đơn vị vận chuyển để giao hàng đúng hẹn.\n"
              "• Bồi thường nếu hàng hóa hư hỏng do đóng gói không đúng cách.",
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "5. Chính sách hoa hồng",
          content:
          "• Hoa hồng 5% trên mỗi đơn hàng thành công.\n"
              "• Thanh toán hoa hồng vào ngày 5 hàng tháng.\n"
              "• Không áp dụng hoa hồng với đơn hàng bị hủy/trả hàng.",
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "6. Quy định về đánh giá",
          content:
          "• Không được ép buộc khách hàng đánh giá 5 sao.\n"
              "• Không được mua/bán đánh giá giả mạo.\n"
              "• Có quyền phản hồi lại các đánh giá tiêu cực một cách chuyên nghiệp.",
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}