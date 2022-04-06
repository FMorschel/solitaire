import 'package:flutter/material.dart';

import 'solitaire_card.dart';

class PlayingCardWidget extends StatelessWidget {
  const PlayingCardWidget({
    Key? key,
    required this.playingCard,
    this.size,
  }) : super(key: key);

  static const double kDefaultAspectRatio = BaseCard.kDefaultAspectRatio;
  static const double kPercentage = 0.14;
  static const double kTopPadding = 0.04;

  /// The card model to display.
  final PlayingCard playingCard;

  final Size? size;

  @override
  Widget build(BuildContext context) {
    if (playingCard.up) {
      return BaseCard(
        aspectRatio: kDefaultAspectRatio,
        width: size?.width,
        height: size?.height,
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: SizedBox(
                    height: constraints.maxHeight * 0.3,
                    child: CardFilling(playingCard: playingCard),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(
                      constraints.maxHeight * kTopPadding,
                    ),
                    child: SizedBox(
                      height:
                          constraints.maxHeight * (kPercentage - kTopPadding),
                      child: CardFilling(
                        playingCard: playingCard,
                        main: false,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else {
      return BaseCard(
        color: Colors.blue,
        aspectRatio: kDefaultAspectRatio,
        width: size?.width,
        height: size?.height,
      );
    }
  }
}

class CardFilling extends StatelessWidget {
  const CardFilling({
    Key? key,
    required this.playingCard,
    this.main = true,
  }) : super(key: key);

  final PlayingCard playingCard;
  final bool main;

  @override
  Widget build(BuildContext context) {
    final textWidget = Column(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(playingCard.card),
          ),
        ),
      ],
    );
    final image = Padding(
      padding: const EdgeInsets.all(1.0),
      child: playingCard.image,
    );
    return Row(
      mainAxisSize: main ? MainAxisSize.max : MainAxisSize.min,
      children: [
        main ? Expanded(child: textWidget) : textWidget,
        const SizedBox(width: 2),
        main ? Expanded(child: image) : image,
      ],
    );
  }
}

class BaseCard extends StatelessWidget {
  const BaseCard({
    Key? key,
    this.elevation,
    this.aspectRatio,
    this.borderRadius,
    this.border,
    this.child,
    this.height,
    this.width,
    this.margin,
    this.color,
  }) : super(key: key);

  factory BaseCard.placeHolder({
    Key? key,
    Widget? child,
    double? height,
    double? width,
    double? margin,
    double? aspectRatio,
    BorderRadiusGeometry? borderRadius,
  }) {
    return BaseCard.noBorder(
      key: key,
      elevation: 0.0,
      child: child,
      borderRadius: borderRadius,
      height: height,
      width: width,
      margin: margin,
      aspectRatio: aspectRatio,
      color: Colors.transparent,
    );
  }

  factory BaseCard.noBorder({
    Key? key,
    BorderRadiusGeometry? borderRadius,
    Widget? child,
    double? elevation,
    double? height,
    double? width,
    double? margin,
    double? aspectRatio,
    Color? color,
  }) {
    return BaseCard(
      border: Border.all(
        width: 1.0,
        style: BorderStyle.none,
        color: Colors.transparent,
      ),
      key: key,
      elevation: elevation,
      borderRadius: borderRadius,
      child: child,
      height: height,
      width: width,
      margin: margin,
      aspectRatio: aspectRatio,
      color: color,
    );
  }

  final double? elevation;
  final double? aspectRatio;
  final double? height;
  final double? width;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final double? margin;
  final Widget? child;
  final Color? color;

  static const double kDefaultAspectRatio = (1 / 1.77);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: AspectRatio(
        aspectRatio: aspectRatio ?? kDefaultAspectRatio,
        child: Card(
          color: Colors.transparent,
          elevation: elevation,
          margin: margin != null ? EdgeInsets.all(margin!) : EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(10),
              border: border ?? Border.all(),
              color: color ?? Colors.transparent,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
