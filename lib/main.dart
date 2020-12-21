import 'package:bapp/config/constants.dart';

import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/app/bapp_provider_initializer.dart';
import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///all the error should go to through us
  FlutterError.onError = (e) {
    FlutterError.dumpErrorToConsole(e);
  };
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BappReboot(
      child: BappProviderInitializerWidget(
        child: BappThemedApp(
          child: BappNavigator(),
        ),
      ),
    );
  }
}

class BappReboot extends StatefulWidget {
  final Widget child;

  const BappReboot({Key key, this.child}) : super(key: key);
  @override
  _BappRebootState createState() => _BappRebootState();
}

class _BappRebootState extends State<BappReboot> {
  var _key = UniqueKey();

  @override
  void initState() {
    _listenForReboot();
    super.initState();
  }

  void _listenForReboot() {
    kBus.on<AppEvents>().listen((event) {
      if (event == AppEvents.reboot) {
        setState(() {
          _key = UniqueKey();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}


class MultiDialog extends StatefulWidget {
  final Widget child;

  const MultiDialog({Key key, this.child}) : super(key: key);
  @override
  _MultiDialogState createState() => _MultiDialogState();

  static void addDialog(
      {@required BuildContext context, @required Widget dialog}) {
    assert(context != null, "the context cannot be null");
    assert(dialog != null, "the dialog cannot be null");
    context.findAncestorStateOfType<_MultiDialogState>()._addDialog(dialog);
  }

  static void remove({@required BuildContext context}) {
    assert(context != null, "the context cannot be null");
    context.findAncestorStateOfType<_MultiDialogState>()._remove();
  }
}

class _MultiDialogState extends State<MultiDialog> {
  final _allDialogs = <Widget>[];

  void _addDialog<T>(Widget dialog) {
    assert(dialog != null, "The dialog cannot be null");
    setState(() {
      _allDialogs.add(dialog);
    });
  }

  void _remove() {
    if (_allDialogs.isEmpty) {
      print("No dialogs to remove");
      return;
    }
    setState(() {
      _allDialogs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_allDialogs.isNotEmpty) _allDialogs.last,
      ],
    );
  }
}

class Temp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiDialog(
      child: Center(
        child: FlatButton(
          child: Text("press"),
          onPressed: () {
            MultiDialog.addDialog(
              dialog: AlertDialog(
                actions: [
                  FlatButton(
                    onPressed: () {
                      MultiDialog.addDialog(
                        dialog: AlertDialog(
                          actions: [
                            FlatButton(
                              onPressed: () {

                              },
                              child: Text("Add"),
                            ),
                            FlatButton(
                              onPressed: () {
                                MultiDialog.remove(context: context);
                              },
                              child: Text("no"),
                            ),
                          ],
                          title: Text(
                            DateTime.now().minute.toString(),
                          ),
                        ),
                        context: context,
                      );
                    },
                    child: Text("Add"),
                  ),
                  FlatButton(
                    onPressed: () {
                      MultiDialog.remove(context: context);
                    },
                    child: Text("no"),
                  ),
                ],
                title: Text(
                  DateTime.now().minute.toString(),
                ),
              ),
              context: context,
            );
          },
        ),
      ),
    );
  }
}

