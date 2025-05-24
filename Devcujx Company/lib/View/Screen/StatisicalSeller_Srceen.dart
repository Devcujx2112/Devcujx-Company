import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/View/Widget/ListHistoryOrderSeller.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Order_ViewModel.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisicalSellerScreen extends StatefulWidget {
  const StatisicalSellerScreen({super.key});

  @override
  _StatisicalSellerScreen createState() => _StatisicalSellerScreen();
}

class _StatisicalSellerScreen extends State<StatisicalSellerScreen> {
  String _timeRange = 'Tuần';

  int completedOrder = 0;
  double totalAmount = 0.0;
  bool _isLoadingDataOrder = true;
  String time = (DateFormat("dd/MM/yyyy").format(DateTime.now())).toString();

  List<Map<String, dynamic>?> _orders = [];
  List<ChartData>? dataChart;

  String _formatAmount(double amount) {
    final _currencyFormat = NumberFormat.currency(
        locale: 'vi_VN',
        symbol: '₫',
        decimalDigits: 0
    );

    if (amount >= 1000000) {
      double millions = amount / 1000000;
      return '${millions.toStringAsFixed(millions.truncateToDouble() == millions ? 0 : 1)}M';
    }
    return _currencyFormat.format(amount);
  }

  List<ChartData>? get _chartData {
    switch (_timeRange) {
      case 'Ngày':
        return [
          ChartData(time, totalAmount),
        ];
      case 'Tuần':
        return dataChart;
      case 'Tháng':
        return List.generate(12, (index) {
          final monthKey = 'T${index + 1}';
          final monthData = dataChart?.firstWhere(
                (item) => item.x == monthKey,
            orElse: () => ChartData(monthKey, 0),
          );
          return monthData!;
        });
      case 'Năm':
        return dataChart;
      default:
        return [];
    }
  }

  @override
  void initState() {
    super.initState();
    ShowAllData();
  }

  void ShowAllData() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final orderDetailVM = Provider.of<Order_ViewModel>(context, listen: false);

    if (authVM.uid!.isEmpty) return;

    setState(() => _isLoadingDataOrder = true);

    try {
      List<Map<String, dynamic>>? dataOrder;
      String? errorMessage;

      switch (_timeRange) {
        case "Ngày":
          dataOrder = await orderDetailVM.StatisticalSellerDay(authVM.uid!);
          break;
        case "Tuần":
          dataOrder = await orderDetailVM.StatisticalSellerWeek(authVM.uid!);
          Map<String,dynamic>? dataWeek = await orderDetailVM.ChartSellerWeek(authVM.uid!);
          dataChart = dataWeek?.entries.map((e) => ChartData(e.key, e.value.toDouble())).toList();
          break;
        case "Tháng":
          dataOrder = await orderDetailVM.StatisticalSellerMonth(authVM.uid!);
          Map<String,dynamic>? dataMonth = await orderDetailVM.ChartSellerMonth(authVM.uid!);
          dataChart = dataMonth?.entries.map((e) => ChartData(e.key, e.value.toDouble())).toList();
          break;
        case "Năm":
          dataOrder = await orderDetailVM.StatisticalSellerYear(authVM.uid!);
          Map<String,dynamic>? dataYear = await orderDetailVM.ChartSellerYear(authVM.uid!);
          dataChart = dataYear?.entries.map((e) => ChartData(e.key, e.value.toDouble())).toList();
          print('UI data $dataChart');
          break;
        default:
          errorMessage = "Khoảng thời gian không hợp lệ";
      }

      if (dataOrder == null || dataOrder.isEmpty) {
        setState(() {
          _isLoadingDataOrder = false;
          _orders = [];
          totalAmount = 0;
          completedOrder = 0;
        });
        showDialogMessage(
            context,
            errorMessage ?? "Không có đơn hàng nào trong khoảng thời gian này",
            DialogType.warning
        );
        return;
      }

      final data = dataOrder.where((item) => !item.containsKey("Summary")).toList();
      final summary = dataOrder.firstWhere(
            (item) => item['Summary'] == true,
        orElse: () => {'TotalSpending': 0, 'OrderCount': 0},
      );

      setState(() {
        _orders = data;
        totalAmount = (summary["TotalSpending"] as num).toDouble();
        completedOrder = summary["OrderCount"] as int;
        _isLoadingDataOrder = false;
      });

    } catch (e) {
      setState(() => _isLoadingDataOrder = false);
      showDialogMessage(
          context,
          "Đã xảy ra lỗi khi tải dữ liệu: ${e.toString()}",
          DialogType.error
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text(
          'Thống Kê',
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
            onPressed: () => _showTimeRangePicker(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Thống kê tổng quan
            _buildStatsCard(theme, completedOrder, totalAmount),
            const SizedBox(height: 20),

            // Biểu đồ
            _buildChartSection(theme),
            const SizedBox(height: 20),

            // Lịch sử đơn hàng
            _buildOrderHistorySection(_orders!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
      ThemeData theme, int completedOrders, double totalRevenue) {
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
              value: _formatAmount(totalRevenue),
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
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 16),
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
              'Doanh thu trong $_timeRange',
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
                primaryXAxis: CategoryAxis(
                  // interval: 1, // Hiển thị tất cả các nhãn
                  // autoScrollingDelta: 12,
                ),
                primaryYAxis: NumericAxis(
                  numberFormat:
                      NumberFormat.currency(locale: 'vi_VN', symbol: '₫'),
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

  Widget _buildOrderHistorySection(List<Map<String,dynamic>?> dataOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử đơn hàng',
          style: TextStyle(
            fontSize: 17,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingDataOrder)
          Center(
            child: LoadingAnimationWidget.inkDrop(
              color: Colors.green,
              size: 35,
            ),
          )
        else if (dataOrder.isEmpty)
          SizedBox(
            height: 30,
            child: const Center(
              child: Text(
                "Chưa có đơn hàng",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
          )
        else
          if(dataOrder.isNotEmpty)
          SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                return HistoryOrderSeller(
                    dataOrder: dataOrder[index]!,
                    loading: () {
                      if (mounted) {
                        setState(() => _isLoadingDataOrder = false);
                      }
                    });
              }),
        ),
      ],
    );
  }

  void _showTimeRangePicker() {
    final theme = Theme.of(context);
    final options = ['Ngày', 'Tuần', 'Tháng', 'Năm'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn khoảng thời gian',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.green,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.green,
              ),

              const SizedBox(height: 8),

              ...options.map((option) {
                final isSelected = _timeRange == option;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _timeRange = option;
                      _isLoadingDataOrder = true;
                    });
                    ShowAllData();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? Colors.green : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
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
