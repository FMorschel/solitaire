import 'card_enums.dart';
import 'solitaire_card.dart';

typedef CardDeck = List<PlayingCard>;

extension Deck on List<PlayingCard> {
  static List<PlayingCard> get fullDeck {
    final List<PlayingCard> fullDeck = [];
    final suitDecks = CardSuit.values.map<List<PlayingCard>>((suit) {
      return CardType.values.map<PlayingCard>((type) {
        return PlayingCard(suit: suit, type: type);
      }).toList();
    }).toList();
    for (final cards in suitDecks) {
      fullDeck.addAll(cards);
    }
    return fullDeck;
  }

  List<CardSuit> get suits {
    List<CardSuit> list = [];
    if (isNotEmpty) {
      list = map<CardSuit>((card) => card.suit).toList()
        ..sort()
        ..toSet();
    }
    return list;
  }

  List<CardType> get numbers {
    List<CardType> list = [];
    if (isNotEmpty) {
      list = map<CardType>((card) => card.type).toList()
        ..sort()
        ..toSet();
    }
    return list;
  }

  bool get allDifferent {
    final list = [...this]..sort();
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        if (list.first == list.last) return false;
      } else {
        if (list[i] == list[i - 1]) return false;
      }
    }
    return true;
  }
}
