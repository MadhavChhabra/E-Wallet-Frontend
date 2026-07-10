import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/utils/app_events.dart';

class CardService {
  CardService._();
  static final CardService instance = CardService._();

  Future<bool> deleteCard(int id) async {
    final response = await HttpService.deleteWithAuth('/cards/$id');
    if (response['message'] == 'Success') {
      AppEvents.instance.notifyCardsChanged();
      return true;
    }
    return false;
  }
}
