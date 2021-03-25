import 'package:bapp/classes/firebase_structures/bapp_user.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BappUserTile extends StatefulWidget {
  final User user;
  final Widget? trailing;

  const BappUserTile({
    Key? key,
    required this.user,
    this.trailing,
  }) : super(key: key);
  @override
  _BappUserTileState createState() => _BappUserTileState();
}

class _BappUserTileState extends State<BappUserTile> {
  User? _user;
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
      subtitle: Text(widget.user.username ?? "no number"),
      leading: ListTileFirebaseImage(
        ifEmpty: Initial(
          forName: widget.user.name ?? "ZZ",
        ),
      ),
      trailing: widget.trailing,
    );
  }
}
