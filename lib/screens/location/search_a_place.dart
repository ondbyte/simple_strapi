import 'package:bapp/config/constants.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class SearchAPlaceScreen extends StatefulWidget {
  final GooglePlace googlePlace;
  final Function(PickedLocation) onSelected;

  const SearchAPlaceScreen(
      {Key key, @required this.googlePlace, this.onSelected})
      : super(key: key);

  @override
  _SearchAPlaceScreenState createState() => _SearchAPlaceScreenState();
}

class _SearchAPlaceScreenState extends State<SearchAPlaceScreen> {
  List<AutocompletePrediction> predictions = [];
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(6)),
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Google your place..",
              fillColor: Theme.of(context).primaryColorLight,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
            onChanged: (s) {
              if (s.isNotEmpty) {
                _search(s);
              }
            },
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              ...List.generate(
                predictions.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Theme.of(context).primaryColorLight),
                  padding: EdgeInsets.all(16),
                  child: ListTile(
                    onTap: () {
                      setState(
                        () {
                          FocusScope.of(context).unfocus();
                          _controller.text = "";
                          _callOnSelectedWithDeets(predictions[index]);
                          predictions.clear();
                        },
                      );
                    },
                    title: Text(predictions[index].description),
                    trailing: Icon(Icons.location_on),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  _callOnSelectedWithDeets(AutocompletePrediction p) async {
    final tmp = await widget.googlePlace.details.get(p.placeId);
    widget.onSelected(
      PickedLocation(
        GeoPoint(
            tmp.result.geometry.location.lat, tmp.result.geometry.location.lng),
        tmp.result.formattedAddress,
      ),
    );
  }

  Future _search(s) async {
    final result = await widget.googlePlace.autocomplete.get(s);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions;
      });
    }
  }
}
