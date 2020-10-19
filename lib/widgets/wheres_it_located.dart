import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:flutter/material.dart';

import '../route_manager.dart';

class WheresItLocatedTileWidget extends StatefulWidget {
  final Function(PickedLocation) onPickLocation;

  WheresItLocatedTileWidget({Key key, this.onPickLocation}) : super(key: key);

  @override
  _WheresItLocatedTileWidgetState createState() =>
      _WheresItLocatedTileWidgetState();
}

class _WheresItLocatedTileWidgetState extends State<WheresItLocatedTileWidget> {
  PickedLocation _pickedLocation;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        final tmp =
            await Navigator.of(context).pushNamed(RouteManager.pickALocation);
        if (tmp != null) {
          setState(() {
            _pickedLocation = tmp;
          });
          widget.onPickLocation(tmp);
        }
      },
      contentPadding: EdgeInsets.only(left: 0),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).primaryColorDark,
      ),
      title: Text(
        "Where is your business located",
        style: Theme.of(context).textTheme.subtitle1,
      ),
      subtitle: Text(
        _pickedLocation == null ? "Pick an Address" : _pickedLocation.address,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
