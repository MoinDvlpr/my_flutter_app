import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/dashboard_controller.dart';
import '../model/profitdatamodel.dart';
import '../utils/app_colors.dart';
import '../utils/app_textstyles.dart';

class ProfitLossChart extends GetView<DashboardController> {
  const ProfitLossChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chartData = controller.chartData; // reactive list

      if (chartData.isEmpty) {}

      return Container(
        height: 400,

        padding: const EdgeInsets.all(0.0),
        child: SfCartesianChart(
          title: ChartTitle(
            text: 'Profit and Loss Over Date Range',
            textStyle: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 14),
          ),
          primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat('MMM dd'),
            majorGridLines: const MajorGridLines(width: 0),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(
              text: 'Amount',
              textStyle: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 14),
            ),
            majorGridLines: const MajorGridLines(width: 0),
          ),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <LineSeries<ProfitLossData, DateTime>>[
            LineSeries<ProfitLossData, DateTime>(
              dataSource: chartData,
              xValueMapper: (ProfitLossData data, _) => data.date,
              yValueMapper: (ProfitLossData data, _) => data.profit,
              name: 'Profit',

              color: success,
              width: 2,
            ),
            LineSeries<ProfitLossData, DateTime>(
              dataSource: chartData,
              xValueMapper: (ProfitLossData data, _) => data.date,
              yValueMapper: (ProfitLossData data, _) => data.loss,
              name: 'Loss',
              color: primary,
              width: 2,
            ),
          ],
          legend: const Legend(
            isVisible: true,
            position: LegendPosition.bottom,
          ),
        ),
      );
    });
  }
}
