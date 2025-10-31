import 'package:uuid/uuid.dart';
class SRGenerator {
  static String generateSR(int productId,int poID) {
    // Validate that productId is an integer
    if (productId < 0) {
      throw ArgumentError('Product ID must be a non-negative integer');
    }
    // Convert productId to string for formatting
    String pidStr = productId.toString();
    String poidStr = poID.toString();
    // Generate a UUID and take first 8 chars for brevity
    String uniquePart = const Uuid().v4().replaceAll('-', '').substring(0, 8);
    return 'SR-$pidStr-$poidStr-$uniquePart';
  }
}