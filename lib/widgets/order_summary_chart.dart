import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../controllers/dashboard_controller.dart';
import '../screens/admin/order/all_orders_screen.dart';
import '../utils/app_textstyles.dart';

class OrderStatus {
  final String status;
  final double percent;
  final Color color;

  OrderStatus(this.status, this.percent, this.color);
}

class OrderStatusChart extends StatelessWidget {
  OrderStatusChart({super.key});
  final dashboardController = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = [
        OrderStatus('Paid', dashboardController.paid.value, Colors.deepOrange),
        OrderStatus(
          'Processing',
          dashboardController.processing.value,
          Colors.orangeAccent,
        ),
        OrderStatus(
          'Shipped',
          dashboardController.shipped.value,
          Colors.purple,
        ),
        OrderStatus(
          'Delivered',
          dashboardController.delivered.value,
          Colors.lightBlue,
        ),
        OrderStatus(
          'Cancelled',
          dashboardController.cancelled.value,
          Colors.redAccent,
        ),
      ];

      return Row(
        children: [
          // Pie Chart
          Expanded(
            child: SfCircularChart(
              margin: EdgeInsets.zero,

              series: <CircularSeries<OrderStatus, String>>[
                PieSeries<OrderStatus, String>(
                  dataSource: data,
                  xValueMapper: (OrderStatus os, _) => os.status,
                  yValueMapper: (OrderStatus os, _) => os.percent,
                  pointColorMapper: (OrderStatus os, _) => os.color,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(color: Colors.white, fontSize: 12),
                  ),

                  explode: true,

                  explodeOffset: '0%',
                  strokeWidth: 0,

                  onPointTap: (pointInteractionDetails) {
                    Get.to(() => AllOrdersScreen());
                  },
                ),
              ],
            ),
          ),

          // Legend Labels
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((os) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: os.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${os.status} - ${os.percent.toInt()}%',
                      style: AppTextStyle.regularTextstyle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
