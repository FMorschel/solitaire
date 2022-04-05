import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Solitaire',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Solitaire'),
      ),
      body: Center(
        child: Row(
          children: const [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CardColumn(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CardColumn(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CardColumn(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CardColumn(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CardColumn(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardColumn extends StatelessWidget {
  const CardColumn({Key? key}) : super(key: key);

  static final random = Random();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int amount = random.nextInt(4) + 1;
        final width = constraints.maxWidth;
        final height = width * 1.77;
        return StatefulBuilder(
          builder: (context, setState) {
            return DragTarget<int>(
              onWillAccept: (data) => data != null,
              onAccept: (_) {
                setState(() => amount++);
              },
              builder: (context, _, __) => Column(
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        for (int i = 0; i < amount; i++)
                          i < (amount - 1)
                              ? card(height, width, i, () {})
                              : card(height, width, i, () {
                                  if (amount > 0) setState(() => amount--);
                                }, false),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Positioned card(
      double height, double width, int i, VoidCallback onDragCompleted,
      [bool ignore = true]) {
    return Positioned(
      top: height * 0.1 * i,
      left: 0,
      width: width,
      child: Builder(
        builder: (context) {
          final child = Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(),
              color: Theme.of(context).primaryColor,
            ),
          );
          if (ignore) {
            return child;
          } else {
            return Draggable<int>(
              data: i,
              onDragCompleted: onDragCompleted,
              feedback: child,
              childWhenDragging: SizedBox(
                width: width,
                height: height,
              ),
              child: child,
            );
          }
        },
      ),
    );
  }
}
