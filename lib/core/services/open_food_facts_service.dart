import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_fitness_assistant/core/models/meal.dart';

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  /// 🔍 Tìm kiếm sản phẩm theo barcode
  static Future<Meal?> searchByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$_baseUrl/product/$barcode.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Kiểm tra sản phẩm có tồn tại không
        if (data['status'] == 1 && data['product'] != null) {
          return _parseProduct(data['product'], barcode);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error fetching from Open Food Facts: $e');
      return null;
    }
  }

  /// 📦 Parse dữ liệu từ API sang Meal model
  static Meal _parseProduct(Map<String, dynamic> product, String barcode) {
    // Lấy thông tin dinh dưỡng (per 100g)
    final nutriments = product['nutriments'] ?? {};

    return Meal(
      id: barcode, // Sử dụng barcode làm ID tạm
      name: product['product_name'] ?? 'Unknown Product',
      calories: (nutriments['energy-kcal_100g'] ?? 0).toInt(),
      servingSizeG: (product['serving_quantity'] ?? 100).toInt(),
      fatG: (nutriments['fat_100g'] ?? 0).toDouble(),
      proteinG: (nutriments['proteins_100g'] ?? 0).toDouble(),
      carbsG: (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
      fiberG: (nutriments['fiber_100g'] ?? 0).toDouble(),
      cholesterolMg: ((nutriments['cholesterol_100g'] ?? 0) * 1000).toDouble(),
      isVerified: true, // Từ Open Food Facts
      imageUrl: product['image_url'],
      barcode: barcode,
    );
  }

  /// 🔍 Tìm kiếm theo tên sản phẩm
  static Future<List<Meal>> searchByName(String query) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search?search_terms=$query&page_size=20&json=true',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List? ?? [];

        return products
            .where((p) => p['code'] != null)
            .map((p) => _parseProduct(p, p['code']))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error searching Open Food Facts: $e');
      return [];
    }
  }
}
