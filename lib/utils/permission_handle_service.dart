import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<void> requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    if (await Permission.photos.isDenied) {
      await Permission.photos.request();
    }

    if (await Permission.camera.isDenied) {
      await Permission.camera.request();
    }
  }
}
