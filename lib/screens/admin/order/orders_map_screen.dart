import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_app/controllers/dashboard_controller.dart';

class OrdersMapScreen extends StatelessWidget {
  OrdersMapScreen({super.key});
  final controller = Get.find<DashboardController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Order Locations')),
      body: GoogleMap(
        markers: controller.markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(20.5937, 78.9629),
          zoom: 6,
        ),
        mapType: MapType.normal,
        myLocationEnabled: true, // Optional: Show user location
        myLocationButtonEnabled: true, // Optional: Location button
        onMapCreated: controller.onMapCreated,
      ),
    );
  }
}
