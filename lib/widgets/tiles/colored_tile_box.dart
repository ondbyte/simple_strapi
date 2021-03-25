import 'package:bapp/config/config.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColoredTileBox extends StatefulWidget {
  final double heightWidth;
  final String title, subTitle;

  const ColoredTileBox(
      {Key? key,
      this.heightWidth = 80,
      required this.title,
      required this.subTitle})
      : super(key: key);
  @override
  _ColoredTileBoxState createState() => _ColoredTileBoxState();
}

class _ColoredTileBoxState extends State<ColoredTileBox> {
  @override
  Widget build(BuildContext context) {
    return RRShape(
      child: Container(
        height: widget.heightWidth,
        width: widget.heightWidth,
        color: CardsColor.next(uid: widget.title),
        padding: EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.apply(color: Theme.of(context).colorScheme.onPrimary),
              ),
              Text(
                widget.subTitle,
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    ?.apply(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
