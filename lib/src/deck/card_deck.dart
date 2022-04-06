import 'package:flutter/material.dart';
import 'package:solitaire/src/card/card_list.dart';
import 'package:solitaire/src/card/card_widget.dart';

import '../board/board.dart';
import '../card/solitaire_card.dart';

class BoardBottom extends StatelessWidget {
  const BoardBottom({
    Key? key,
    required this.board,
    required this.onDoubleTapUp,
  }) : super(key: key);

  final Board board;
  final bool Function(PlayingCard card) onDoubleTapUp;

  static int get flex => toInt(1 + 18 * PlayingCardWidget.kPercentage);
  static int get maxFlex => toInt(2 + 18 * PlayingCardWidget.kPercentage);

  static int toInt(num value) {
    if (value.toInt() == value) {
      return value.toInt();
    } else {
      return toInt(value * 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < board.cardColumns.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  late final double width;
                  late final double height;
                  if (constraints.biggest.aspectRatio <
                      (PlayingCardWidget.kDefaultAspectRatio *
                          (1 + 18 * PlayingCardWidget.kPercentage))) {
                    height = constraints.maxHeight /
                        (1 + 18 * PlayingCardWidget.kPercentage);
                    width = height * PlayingCardWidget.kDefaultAspectRatio;
                  } else {
                    width = constraints.maxWidth;
                    height = width / PlayingCardWidget.kDefaultAspectRatio;
                  }
                  return SizedBox(
                    height: constraints.maxHeight,
                    width: width,
                    child: _DeckCards(
                      initialData: board.cardColumns[i],
                      stream:
                          board.cardColumnsStream.map((columns) => columns[i]),
                      size: Size(width, height),
                      constraints: constraints,
                      add: (newCards) {
                        board.update(i, board.cardColumns[i]..addAll(newCards));
                      },
                      remove: (cardsToRemove) {
                        board.update(
                          i,
                          board.cardColumns[i]
                            ..removeWhere(cardsToRemove.contains),
                        );
                      },
                      turn: (card) {
                        board.update(
                          i,
                          board.cardColumns[i]
                            ..remove(card)
                            ..add(card..up = true),
                        );
                      },
                      onDoubleTapUp: onDoubleTapUp,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _DeckCards extends StatelessWidget {
  const _DeckCards({
    Key? key,
    required this.size,
    required this.constraints,
    required this.add,
    required this.remove,
    required this.turn,
    required this.onDoubleTapUp,
    required this.initialData,
    required this.stream,
  }) : super(key: key);

  final Size size;
  final BoxConstraints constraints;
  final void Function(CardDeck deck) add;
  final void Function(CardDeck deck) remove;
  final void Function(PlayingCard card) turn;
  final bool Function(PlayingCard card) onDoubleTapUp;
  final CardDeck initialData;
  final Stream<CardDeck> stream;

  static bool _canAccept(PlayingCard first, PlayingCard second) {
    if ((first.color != second.color) &&
        ((second.type.index - first.type.index) == -1)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CardDeck>(
      initialData: initialData,
      stream: stream,
      builder: (context, snapshot) {
        final cards = snapshot.data!;
        return DragTarget<CardDeck>(
          onWillAccept: (data) {
            if (data != null) {
              if (cards.isNotEmpty) {
                return _canAccept(cards.last, data.first);
              } else {
                return true;
              }
            } else {
              return false;
            }
          },
          onAccept: add,
          builder: (context, _, __) => Stack(
            fit: StackFit.expand,
            children: [
              for (int index = 0; index < cards.length; index++)
                _DeckCard(
                  cards: cards.sublist(index),
                  stream: stream,
                  add: add,
                  initialData: cards,
                  remove: (cardsToRemove) {
                    if (cards.indexOf(cardsToRemove.first) != 0) {
                      turn(cards[cards.indexOf(cardsToRemove.first) - 1]);
                    }
                    remove(cardsToRemove);
                  },
                  turn: turn,
                  distanceFromTop:
                      size.height * PlayingCardWidget.kPercentage * index,
                  constraints: constraints,
                  height: size.height,
                  width: size.width,
                  onDoubleTap: onDoubleTapUp,
                  onDragCompleted: () {
                    if (cards.isNotEmpty) {
                      turn(cards.last);
                    }
                  },
                  onDragStarted: remove,
                  onDragCanceled: add,
                )
            ],
          ),
        );
      },
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({
    Key? key,
    required this.constraints,
    required this.height,
    required this.width,
    required this.cards,
    required this.onDoubleTap,
    required this.distanceFromTop,
    required this.onDragCompleted,
    required this.onDragStarted,
    required this.onDragCanceled,
    required this.add,
    required this.remove,
    required this.turn,
    required this.initialData,
    required this.stream,
  }) : super(key: key);

  final double distanceFromTop;
  final BoxConstraints constraints;
  final double height;
  final double width;
  final CardDeck cards;
  final VoidCallback onDragCompleted;
  final bool Function(PlayingCard card) onDoubleTap;
  final void Function(CardDeck cards) onDragStarted;
  final void Function(CardDeck cards) onDragCanceled;
  final void Function(CardDeck deck) add;
  final void Function(CardDeck deck) remove;
  final void Function(PlayingCard card) turn;
  final CardDeck initialData;
  final Stream<CardDeck> stream;

  @override
  Widget build(BuildContext context) {
    final child = PlayingCardWidget(
      size: Size(width, height),
      playingCard: cards.first,
    );
    return Positioned(
      left: 0,
      top: distanceFromTop,
      width: width,
      child: StreamBuilder<bool>(
        initialData: cards.first.up,
        stream: cards.first.stream,
        builder: (context, snapshot) {
          final up = snapshot.data!;
          if (!up) {
            return child;
          } else {
            return Draggable<CardDeck>(
              onDragCompleted: onDragCompleted,
              onDragStarted: () {
                onDragStarted(cards);
              },
              onDraggableCanceled: (_, __) => onDragCanceled(cards),
              data: cards,
              feedback: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: _DeckCards(
                  initialData: cards,
                  stream: stream.map((streamedCards) {
                    return streamedCards.where(cards.contains).toList();
                  }),
                  size: Size(width, height),
                  constraints: constraints,
                  add: add,
                  remove: remove,
                  turn: turn,
                  onDoubleTapUp: onDoubleTap,
                ),
              ),
              child: GestureDetector(
                onDoubleTap: () {
                  if ((cards.length == 1) && (onDoubleTap(cards.first))) {
                    remove(cards);
                  }
                },
                child: child,
              ),
              childWhenDragging: SizedBox(
                width: width,
                height: height,
              ),
            );
          }
        },
      ),
    );
  }
}
