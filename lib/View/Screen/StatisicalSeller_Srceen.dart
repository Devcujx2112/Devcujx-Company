import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisicalSellerScreen extends StatefulWidget {
  const StatisicalSellerScreen({super.key});

  @override
  _StatisicalSellerScreen createState() => _StatisicalSellerScreen();
}

class _StatisicalSellerScreen extends State<StatisicalSellerScreen> {
  String _timeRange = 'Tuần'; // Ngày/Tuần/Tháng/Năm
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  // Dữ liệu mẫu
  final List<Order> _orders = [
    Order(
      id: 'DH001',
      productName: 'Bánh xèo Quảng Ngãi',
      imageUrl: 'https://i-giadinh.vnecdn.net/2023/09/19/Bc10Thnhphm11-1695107510-2493-1695107555.jpg',
      customer: 'Vũ Tùng Dương',
      date: DateTime.now().subtract(const Duration(days: 1)),
      amount: 35000,
      status: 'Thành công',
    ),
    Order(
      id: 'DH002',
      productName: 'Phở bò tài gầu 2 trứng',
      imageUrl: 'https://cdn2.fptshop.com.vn/unsafe/1920x0/filters:format(webp):quality(75)/cach_nau_pho_bo_nam_dinh_0_1d94be153c.png',
      customer: 'Trần Thị B',
      date: DateTime.now().subtract(const Duration(days: 2)),
      amount: 70000,
      status: 'Đang xử lý',
    ),
    Order(
      id: 'DH003',
      productName: 'AirPods Pro 2',
      imageUrl: 'https://example.com/airpods.jpg',
      customer: 'Lê Văn C',
      date: DateTime.now().subtract(const Duration(days: 3)),
      amount: 5990000,
      status: 'Đã hủy',
      failureReason: 'Khách đổi ý',
    ),
  ];

  // Dữ liệu biểu đồ
  List<ChartData> get _chartData {
    switch (_timeRange) {
      case 'Ngày':
        return [
          ChartData('8h', 1200000),
          ChartData('12h', 2500000),
          ChartData('16h', 1800000),
          ChartData('20h', 3000000),
        ];
      case 'Tuần':
        return [
          ChartData('T2', 5000000),
          ChartData('T3', 7500000),
          ChartData('T4', 6200000),
          ChartData('T5', 9300000),
          ChartData('T6', 8700000),
          ChartData('T7', 11000000),
          ChartData('CN', 6800000),
        ];
      case 'Tháng':
        return [
          ChartData('Tuần 1', 25000000),
          ChartData('Tuần 2', 32000000),
          ChartData('Tuần 3', 28000000),
          ChartData('Tuần 4', 41000000),
        ];
      case 'Năm':
        return [
          ChartData('Q1', 95000000),
          ChartData('Q2', 120000000),
          ChartData('Q3', 110000000),
          ChartData('Q4', 150000000),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedOrders = _orders.where((o) => o.status == 'Thành công').length;
    final totalRevenue = _orders.where((o) => o.status == 'Thành công').fold<double>(0, (sum, o) => sum + o.amount);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text('Thống Kê Bán Hàng',style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today,color: Colors.white,),
            onPressed: () => _showTimeRangePicker(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Thống kê tổng quan
            _buildStatsCard(theme, completedOrders, totalRevenue),
            const SizedBox(height: 20),

            // Biểu đồ
            _buildChartSection(theme),
            const SizedBox(height: 20),

            // Lịch sử đơn hàng
            _buildOrderHistorySection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme, int completedOrders, double totalRevenue) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatItem(
              icon: Icons.check_circle,
              value: completedOrders.toString(),
              label: 'Đơn thành công',
              color: Colors.green,
            ),
            const SizedBox(width: 16),
            _buildStatItem(
              icon: Icons.attach_money,
              value: _currencyFormat.format(totalRevenue),
              label: 'Tổng doanh thu',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey[700],fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doanh thu theo $_timeRange',
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.currency(locale: 'vi_VN', symbol: '₫'),
                ),
                series: <CartesianSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>(
                    dataSource: _chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(4),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: false,
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử đơn hàng gần đây',
          style: TextStyle(
            fontSize: 20,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._orders.map((order) => _buildOrderItem(order, theme)),
      ],
    );
  }

  Widget _buildOrderItem(Order order, ThemeData theme) {
    final isSuccess = order.status == 'Thành công';
    final isFailed = order.status == 'Đã hủy';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${order.id}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? Colors.green.withOpacity(0.1)
                        : isFailed
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSuccess
                          ? Colors.green
                          : isFailed
                          ? Colors.red
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customer,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm dd/MM/yyyy').format(order.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currencyFormat.format(order.amount),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red
                      ),
                    ),
                    if (isFailed) ...[
                      const SizedBox(height: 4),
                      Text(
                        order.failureReason ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeRangePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn khoảng thời gian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...['Ngày', 'Tuần', 'Tháng', 'Năm'].map((option) {
                return ListTile(
                  title: Text(option),
                  trailing: _timeRange == option ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() => _timeRange = option);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}

class Order {
  final String id;
  final String productName;
  final String imageUrl;
  final String customer;
  final DateTime date;
  final double amount;
  final String status;
  final String? failureReason;

  Order({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.customer,
    required this.date,
    required this.amount,
    required this.status,
    this.failureReason,
  });
}