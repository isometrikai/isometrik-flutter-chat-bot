/// Holds store category IDs from the session API (`store_categories`).
class StoreCategoryRegistry {
  static Map<String, String> _categories = const {};

  static Map<String, String> get categories => _categories;

  static void update(Map<String, String> categories) {
    _categories = Map<String, String>.from(categories);
  }

  static void clear() {
    _categories = const {};
  }

  static String? idFor(String apiKey) => _categories[apiKey];
}
