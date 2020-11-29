import 'package:bapp/classes/firebase_structures/bapp_user.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:flutter/material.dart';

class BappUserTile extends StatefulWidget {
  final BappUser user;
  final Widget trailing;

  const BappUserTile({
    Key key,
    this.user,
    this.trailing,
  }) : super(key: key);
  @override
  _BappUserTileState createState() => _BappUserTileState();
}

class _BappUserTileState extends State<BappUserTile> {
  BappUser _user;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return Stack(
        alignment: Alignment.topCenter,
        children: [ListTile(), LinearProgressIndicator()],
      );
    }
    return ListTile(
      title: Text(widget.user.name ?? "no name"),
      subtitle: Text(widget.user.theNumber.internationalNumber ?? "no number"),
      leading: ListTileFirebaseImage(
        storagePathOrURL: widget.user.image ?? kTemporaryPlaceHolderImage,
      ),
      trailing: widget.trailing ?? null,
    );
  }
}
