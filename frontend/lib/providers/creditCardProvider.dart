import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/model/creditCard.dart';

CreditCard card = CreditCard(
  name: "",
  cardNumber: "",
);

class CreditCardNotifier extends StateNotifier<CreditCard> {
  CreditCardNotifier() : super(card);

  void addCreditCard(CreditCard card) {
    state = card;
  }

  void deleteCreditCard() {
    state = CreditCard(
      name: "",
      cardNumber: "",
    );
  }
}

final creditCardProvider =
    StateNotifierProvider<CreditCardNotifier, CreditCard>((ref) {
  return CreditCardNotifier();
});
