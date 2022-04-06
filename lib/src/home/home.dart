import 'package:flutter/material.dart';
import 'package:solitaire/src/card/card_enums.dart';
import 'package:solitaire/src/card/card_list.dart';
import 'package:solitaire/src/deck/card_deck.dart';

import '../board/board.dart';
import '../card/card_widget.dart';
import '../card/solitaire_card.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  final board = Board();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Solitaire'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: BoardBottom.maxFlex - BoardBottom.flex,
              child: BoardTop(board: board, onDoubleTapUp: onDoubleTapUp),
            ),
            Expanded(
              flex: BoardBottom.flex,
              child: BoardBottom(board: board, onDoubleTapUp: onDoubleTapUp),
            ),
          ],
        ),
      ),
    );
  }

  bool onDoubleTapUp(PlayingCard card) {
    if (board[card.suit].isEmpty) {
      if (card.type == CardType.one) {
        board[card.suit] = [...board[card.suit], card];
        return true;
      } else {
        return false;
      }
    } else if (board[card.suit].last.type.index == (card.type.index - 1)) {
      board[card.suit] = [...board[card.suit], card];
      return true;
    } else {
      return false;
    }
  }
}

class BoardTop extends StatelessWidget {
  const BoardTop({
    Key? key,
    required this.board,
    required this.onDoubleTapUp,
  }) : super(key: key);

  final Board board;
  final bool Function(PlayingCard card) onDoubleTapUp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: StreamBuilder<CardDeck>(
                initialData: board.remainingCards,
                stream: board.stream,
                builder: (context, snapshot) {
                  final remainingCards = snapshot.data!;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      stack(
                        remainingCards.where((cards) => !cards.up).toList(),
                      ),
                      stack(remainingCards.where((cards) => cards.up).toList()),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: StreamBuilder<List<CardDeck>>(
                initialData: board.finalDecks,
                stream: board.finalDecksStream,
                builder: (context, snapshot) {
                  final finalDecks = snapshot.data!;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        finalDecks.map((cards) => stack(cards, true)).toList(),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onEmpty() {
    board.remainingCards = [
      ...board.remainingCards.map((card) => card..up = false),
    ].reversed.toList();
  }

  Widget stack(List<PlayingCard> cards, [bool target = false]) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            late final double width;
            late final double height;
            const aspectRatio = PlayingCardWidget.kDefaultAspectRatio;
            if (constraints.biggest.aspectRatio < aspectRatio) {
              width = constraints.maxWidth;
              height = width / aspectRatio;
            } else {
              height = constraints.maxHeight;
              width = height * aspectRatio;
            }
            final size = Size(width, height);
            if (cards.isNotEmpty) {
              return Stack(
                children: [
                  for (final card in cards)
                    Builder(
                      builder: (context) {
                        final child = PlayingCardWidget(
                          playingCard: card,
                          size: size,
                        );
                        if (card.up) {
                          return Draggable<CardDeck>(
                            data: [card],
                            onDragStarted: () {
                              board.remainingCards = board.remainingCards
                                ..remove(card);
                            },
                            onDraggableCanceled: (_, __) {
                              board.remainingCards = board.remainingCards
                                ..add(card);
                            },
                            onDragCompleted: () {
                              board.remainingCards = board.remainingCards
                                ..remove(card);
                            },
                            childWhenDragging: SizedBox.fromSize(size: size),
                            feedback: child,
                            child: target
                                ? DragTarget<CardDeck>(
                                    onWillAccept: onWillAccept,
                                    onAccept: onAccept,
                                    builder: (context, _, __) =>
                                        GestureDetector(
                                      onDoubleTap: () {
                                        if (onDoubleTapUp(card)) {
                                          board.remainingCards = board
                                              .remainingCards
                                            ..remove(card);
                                        }
                                      },
                                      child: child,
                                    ),
                                  )
                                : GestureDetector(
                                    onDoubleTap: () {
                                      if (onDoubleTapUp(card)) {
                                        board.remainingCards =
                                            board.remainingCards..remove(card);
                                      }
                                    },
                                    child: child,
                                  ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              board.remainingCards = board.remainingCards
                                ..remove(card)
                                ..add(card..up = !card.up);
                            },
                            child: child,
                          );
                        }
                      },
                    ),
                ],
              );
            } else {
              if (target) {
                return DragTarget<CardDeck>(
                  onWillAccept: onWillAccept,
                  onAccept: onAccept,
                  builder: (context, _, __) => GestureDetector(
                    onTap: onEmpty,
                    child: BaseCard.placeHolder(
                      height: size.height,
                      width: size.width,
                    ),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: onEmpty,
                  child: BaseCard.placeHolder(
                    height: size.height,
                    width: size.width,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void onAccept(List<PlayingCard> card) {
    board[card.single.suit] = [
      ...board[card.single.suit],
      ...card,
    ];
  }

  bool onWillAccept(CardDeck? data) {
    if ((data != null) && (data.length == 1)) {
      if (board[data.single.suit].isEmpty) {
        if (data.single.type == CardType.one) {
          board[data.single.suit] = [...board[data.single.suit], ...data];
          return true;
        } else {
          return false;
        }
      } else if (board[data.single.suit].last.type.index ==
          (data.single.type.index - 1)) {
        board[data.single.suit] = [...board[data.single.suit], ...data];
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
