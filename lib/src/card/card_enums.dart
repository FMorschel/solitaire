import 'dart:math';

import 'solitaire_card.dart';

enum CardSuit {
  spades,
  hearts,
  diamonds,
  clubs,
}

enum CardType {
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
}

enum CardColor {
  red,
  black,
}

extension CardSuitExt on CardSuit {
  PlayingCard card(
    int index, {
    bool up = false,
  }) =>
      PlayingCard.fromNumber(
        index,
        suit: this,
      );

  static CardSuit random([Random? random]) {
    random ??= Random(DateTime.now().microsecondsSinceEpoch);
    return CardSuit.values[random.nextInt(CardSuit.values.length)];
  }
}

extension CardTypeExt on CardType {
  static CardType random([Random? random]) {
    random ??= Random(DateTime.now().microsecondsSinceEpoch);
    return CardType.values[random.nextInt(CardType.values.length)];
  }
}