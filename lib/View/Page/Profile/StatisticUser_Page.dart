import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:order_food/View/Widget/DialogMessage_Form.dart';
import 'package:order_food/ViewModels/Auth_ViewModel.dart';
import 'package:order_food/ViewModels/Order_ViewModel.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Widget/ListHistoryOrder.dart';

class StatisticUserPage extends StatefulWidget {
  const StatisticUserPage({super.key});

  @override
  State<StatisticUserPage> createState() => _StatisticUserPageState();
}

class _StatisticUserPageState extends State<StatisticUserPage> {
  bool _isLoading = true;
  String _selectedTimeRange = 'Tháng';
  int _totalOrders = 24;
  double _totalSpending = 5840000;

  List<Map<String,dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    ShowAllDataOrder();
  }

  void ShowAllDataOrder() async{
    final orderVM = Provider.of<Order_ViewModel>(context,listen: false);
    final authVM = Provider.of<AuthViewModel>(context,listen: false);
    if(authVM.uid!.isNotEmpty){
      List<Map<String,dynamic>>? dataOrder = await orderVM.ShowAllDataOrderDoneAndFail(authVM.uid!);
      if(dataOrder != null){
        setState(() {
          orders = dataOrder;
        });
      }
      else{
        showDialogMessage(context, "Bạn chưa có đơn hàng nào hoàn thành hoặc bị hủy", DialogType.warning);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  final List<ChartData> _monthlyData = [
    ChartData('T1', 1200000),
    ChartData('T2', 800000),
    ChartData('T3', 1500000),
    ChartData('T4', 900000),
    ChartData('T5', 240000),
    ChartData('T6', 144000),
    ChartData('T7', 1240000),
    ChartData('T8', 1140000),
    ChartData('T9', 100000),
    ChartData('T10', 1440000),
    ChartData('T11', 1440000),
    ChartData('T12', 1500000),
  ];

  final List<ChartData> _yearlyData = [
    ChartData('2020', 8500000),
    ChartData('2021', 10200000),
    ChartData('2022', 12500000),
    ChartData('2023', 15800000),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
      LoadingAnimationWidget.inkDrop(color: Colors.green, size: 50),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Thống kê chi tiêu",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lựa chọn khoảng thời gian
              _buildTimeRangeSelector(theme),
              const SizedBox(height: 24),

              // Thống kê tổng quan
              _buildSummaryCards(theme),
              const SizedBox(height: 24),

              // Biểu đồ thống kê
              _buildChartSection(theme),
              const SizedBox(height: 24),

              // Chi tiết đơn hàng
              Divider(color: Colors.grey[400],indent: 10,endIndent: 10,thickness: 1),
              SizedBox(height: 10),
              _buildOrderDetailsSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeRangeButton('Tháng', theme),
          _buildTimeRangeButton('Năm', theme),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(String title, ThemeData theme) {
    final isSelected = _selectedTimeRange == title;
    return Flexible(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTimeRange = title),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.shopping_bag_outlined,
            value: '$_totalOrders',
            label: 'Tổng đơn hàng',
            color: Colors.blue,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            icon: Icons.monetization_on_outlined,
            value: '${(_totalSpending / 1000000).toStringAsFixed(1)}M',
            label: 'Tổng chi phí',
            color: Colors.green,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,

              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                fontSize: 13
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biểu đồ chi tiêu theo $_selectedTimeRange',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green,
              fontSize: 19
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: '₫',
                  decimalDigits: 0,
                ),
              ),
              series: <CartesianSeries<ChartData, String>>[
                ColumnSeries<ChartData, String>(
                  dataSource: _selectedTimeRange == 'Tháng' ? _monthlyData : _yearlyData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: false,
                    labelAlignment: ChartDataLabelAlignment.top,
                    textStyle: TextStyle(fontSize: 10),
                    builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                      return Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
                            .format(point.y),
                      );
                    },
                  ),
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                  return Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      '${point.x}: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(point.y)}',
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết lịch sử đơn hàng ',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.green,
            fontSize: 17
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return HistoryOrder(dataOrder: orders[index]);
          },
        ),
      ],
    );
  }

}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}