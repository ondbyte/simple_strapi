import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContextualMessageScreen extends StatefulWidget {
  final Function init;
  final String message;
  final String buttonText;
  final Function(BuildContext) onButtonPressed;
  final String svgAssetToDisplay;
  final String secondarybuttonText;
  final Function(BuildContext) secondaryButtonPressed;

  const ContextualMessageScreen(
      {Key key,
      this.init,
      this.message,
      this.buttonText = "Back to Home",
      this.onButtonPressed,
      this.svgAssetToDisplay,
      this.secondarybuttonText,
      this.secondaryButtonPressed})
      : super(key: key);
  @override
  _ContextualMessageScreenState createState() =>
      _ContextualMessageScreenState();
}

class _ContextualMessageScreenState extends State<ContextualMessageScreen> {
  bool loading = true, _inited = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: InitWidget(
          initializer: () async {
            if (widget.init != null && !_inited) {
              await widget.init();
            }
            _inited = true;
          },
          onInitComplete: () {
            setState(() {
              loading = false;
            });
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  widget.svgAssetToDisplay ?? "assets/svg/messages.svg",
                  width: 256,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "${widget.message}",
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  onPressed: loading
                      ? null
                      : () {
                          if (widget.onButtonPressed != null) {
                            widget.onButtonPressed(context);
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                RouteManager.home, (route) => false);
                          }
                        },
                  child: Text(widget.buttonText),
                ),
                if (widget.secondarybuttonText != null)
                  FlatButton(
                    onPressed: loading
                        ? null
                        : () {
                            if (widget.secondaryButtonPressed != null) {
                              widget.secondaryButtonPressed(context);
                            }
                          },
                    child: Text(widget.secondarybuttonText),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
