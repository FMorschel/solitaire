import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'card_enums.dart';

// Simple playing card model
class PlayingCard extends Equatable implements Comparable<PlayingCard> {
  PlayingCard._({
    required this.suit,
    required this.type,
    required this.color,
    bool up = false,
  }) {
    this.up = up;
  }

  final _controller = StreamController<bool>();
  late final _stream = _controller.stream.asBroadcastStream();
  final _up = ValueNotifier<bool>(false);

  Stream<bool> get stream => _stream;

  bool get up => _up.value;
  set up(bool newValue) {
    _up.value = newValue;
    _controller.sink.add(newValue);
  }

  factory PlayingCard({
    required CardSuit suit,
    required CardType type,
  }) {
    late final CardColor color;
    if (suit == CardSuit.hearts || suit == CardSuit.diamonds) {
      color = CardColor.red;
    } else {
      color = CardColor.black;
    }
    return PlayingCard._(
      suit: suit,
      type: type,
      color: color,
    );
  }

  factory PlayingCard.fromNumber(
    int index, {
    required CardSuit suit,
  }) {
    index -= 1;
    assert((index >= CardType.one.index) && (index <= CardType.king.index));
    final type = CardType.values[index];
    return PlayingCard(
      suit: suit,
      type: type,
    );
  }

  factory PlayingCard.random([Random? random]) {
    random ??= Random(DateTime.now().microsecondsSinceEpoch);
    return PlayingCard.fromNumber(
      CardTypeExt.random(random).index,
      suit: CardSuitExt.random(random),
    );
  }

  final CardSuit suit;
  final CardType type;
  final CardColor color;

  int get value => type.index + 1;

  Image get image {
    switch (suit) {
      case CardSuit.hearts:
        return Image.asset('assets/images/hearts.png');
      case CardSuit.diamonds:
        return Image.asset('assets/images/diamonds.png');
      case CardSuit.clubs:
        return Image.asset('assets/images/clubs.png');
      case CardSuit.spades:
        return Image.asset('assets/images/spades.png');
    }
  }

  String get card {
    switch (type) {
      case CardType.one:
        return "A";
      case CardType.two:
        return "2";
      case CardType.three:
        return "3";
      case CardType.four:
        return "4";
      case CardType.five:
        return "5";
      case CardType.six:
        return "6";
      case CardType.seven:
        return "7";
      case CardType.eight:
        return "8";
      case CardType.nine:
        return "9";
      case CardType.ten:
        return "10";
      case CardType.jack:
        return "J";
      case CardType.queen:
        return "Q";
      case CardType.king:
        return "K";
      default:
        return "";
    }
  }

  @override
  String toString() {
    return 'PlayingCard('
        'suit: $suit,'
        'type: $type,'
        ')';
  }

  @override
  List<Object?> get props => [suit, type];

  bool operator >(PlayingCard other) {
    return compareTo(other) > 0;
  }

  bool operator <(PlayingCard other) {
    return compareTo(other) < 0;
  }

  bool operator >=(PlayingCard other) {
    return compareTo(other) >= 0;
  }

  bool operator <=(PlayingCard other) {
    return compareTo(other) <= 0;
  }

  PlayingCard get nextCard {
    if (type == CardType.values.last) {
      return PlayingCard(
        suit: suit,
        type: CardType.values.first,
      );
    } else {
      return PlayingCard(
        suit: suit,
        type: CardType.values[type.index + 1],
      );
    }
  }

  @override
  int compareTo(PlayingCard other) {
    if (suit == other.suit) {
      return value - other.value;
    }
    return suit.index - other.suit.index;
  }
}
