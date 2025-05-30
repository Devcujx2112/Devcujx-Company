🍔 Devcujx Food App

Devcujx Food App là ứng dụng đặt đồ ăn trực tuyến được phát triển bằng Flutter. Hệ thống bao gồm giao diện dành cho người dùng, nhà bán và admin, hỗ trợ theo dõi món ăn, đơn hàng, giao hàng và thanh toán.

✨ Tính năng chính

🍽️ Đặt đồ ăn trực tuyến

🛍️ Quản lý thông tin món ăn, đơn hàng

🚚 Theo dõi giao hàng theo thời gian thực (sắp triển)

⭐️ Đánh giá, phản hồi, gợi ý món ăn (AI - sắp triển)

🚀 Hướng dẫn chạy ứng dụng

✅ Bước 1: Cài đặt ngrok

Cách 1: Dùng Chocolatey (Windows)

choco install ngrok

Cách 2: Tải trực tiếp

Vào https://ngrok.com/downloads

Tải bản phù hợp hệ điều hành

Thêm ngrok vào PATH (nếu cần)

📂 Bước 2: Tạo tunnel tới backend

Truy cập thư mục backend:

cd flutter_app_be

Chạy ngrok:

ngrok http 3030

Lấy URL tunnel hiện ra, ví dụ:

https://abc1234.ngrok-free.app

🛠️ Bước 3: Cập nhật BASE_URL trong file .env

Mở thư mục Devcujx Company

Đổi tên file .env.example (nếu có) thành .env

Mở file .env và thay dòng BASE_URL:

BASE_URL=https://abc1234.ngrok-free.app

▶️ Bước 4: Chạy frontend Flutter

cd flutter_app_fe
flutter pub get
flutter run

🚀 Kết quả

Frontend sẽ kết nối với backend qua ngrok

Truy cập ứng dụng tại localhost:xxxx hoặc thiết bị di động
