import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/services/hawksearch_service.dart';

class RestaurantRepository {
  const RestaurantRepository();

  Future<List<Store>> fetchStores({String keyword = '', String storeCategoryName = ''}) {
    return HawkSearchService.instance.fetchStoresGroupedByStoreId(
      keyword: keyword,
      storeCategoryName: storeCategoryName,
    );
  }
}


