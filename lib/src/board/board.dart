import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:solitaire/src/card/card_list.dart';
import 'package:solitaire/src/card/card_enums.dart';

import '../card/solitaire_card.dart';

class Board {
  Board() {
    reset();
  }

  void reset() {
    final allCards = Deck.fullDeck;
    final seed = DateTime.now().millisecondsSinceEpoch;
    allCards.shuffle(Random(seed));
    for (final list in cardColumns) {
      list.clear();
    }
    remainingCards = [];
    for (final deck in finalDecks) {
      deck.clear();
    }
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < (i + 1); j++) {
        cardColumns[i].add(allCards.first);
        allCards.removeAt(0);
      }
      cardColumns[i].last.up = true;
    }
    remainingCards = allCards..last.up = true;
  }

  // Stores the cards on the seven columns
  final _cardColumns = ValueNotifier<List<CardDeck>>(List.from(
    [
      <PlayingCard>[],
      <PlayingCard>[],
      <PlayingCard>[],
      <PlayingCard>[],
      <PlayingCard>[],
      <PlayingCard>[],
      <PlayingCard>[],
    ],
    growable: false,
  ));
  late final _cardColumnsController = StreamController<List<CardDeck>>()
    ..sink.add(_cardColumns.value);
  late final _cardColumnsStream =
      _cardColumnsController.stream.asBroadcastStream();

  Stream<List<CardDeck>> get cardColumnsStream => _cardColumnsStream;
  List<CardDeck> get cardColumns => _cardColumns.value;
  set cardColumns(List<CardDeck> newCards) {
    _cardColumns.value = newCards;
    _cardColumnsController.sink.add(newCards);
  }

  void update(int index, CardDeck newCards) {
    final List<CardDeck> newList = [];
    for (int i = 0; i < cardColumns.length; i++) {
      newList.add([]);
      if (i == index) {
        newList.last.addAll(newCards);
      } else {
        newList.last.addAll(cardColumns[i]);
      }
    }
    _cardColumns.value = newList;
    _cardColumnsController.sink.add(newList);
  }

  // Stores the remaining card deck
  final _remainingCards = ValueNotifier<CardDeck>([]);
  late final _controller = StreamController<CardDeck>()
    ..sink.add(_remainingCards.value);
  late final _stream = _controller.stream.asBroadcastStream();

  Stream<CardDeck> get stream => _stream;
  CardDeck get remainingCards => _remainingCards.value;
  set remainingCards(CardDeck newCards) {
    _remainingCards.value = newCards;
    _controller.sink.add(newCards);
  }

  // Stores the remaining card deck
  final _finalDecks = ValueNotifier<List<CardDeck>>(List.from(
    [
      <PlayingCard>[],
      <PlayingCard>[],
      <PlayingCard>[],
      <PlayingCard>[],
    ],
    growable: false,
  ));
  late final _finalDecksController = StreamController<List<CardDeck>>()
    ..sink.add(_finalDecks.value);
  late final _finalDecksStream =
      _finalDecksController.stream.asBroadcastStream();

  Stream<List<CardDeck>> get finalDecksStream => _finalDecksStream;
  List<CardDeck> get finalDecks => _finalDecks.value;
  set finalDecks(List<CardDeck> newCards) {
    _finalDecks.value = newCards;
    _finalDecksController.sink.add(newCards);
  }

  CardDeck operator [](CardSuit suit) => finalDecks[suit.index];
  void operator []=(CardSuit selectedSuit, CardDeck newCards) {
    final List<CardDeck> newList = [];
    for (final suit in CardSuit.values) {
      newList.add([]);
      if (suit == selectedSuit) {
        newList.last.addAll(newCards);
      } else {
        newList.last.addAll(this[suit]);
      }
    }
    finalDecks = newList;
  }
}
