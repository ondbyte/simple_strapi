import 'package:bapp/config/constants.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class SearchAPlaceScreen extends StatefulWidget {
  final GooglePlace googlePlace;
  final Function(PickedLocation) onSelected;

  const SearchAPlaceScreen({
    Key? key,
    required this.googlePlace,
    required this.onSelected,
  }) : super(key: key);

  @override
  _SearchAPlaceScreenState createState() => _SearchAPlaceScreenState();
}

class _SearchAPlaceScreenState extends State<SearchAPlaceScreen> {
  List<AutocompletePrediction> predictions = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(6)),
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Google your place..",
              fillColor: Theme.of(context).indicatorColor,
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
        ...List.generate(
          predictions.length,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Theme.of(context).backgroundColor),
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
              title: Text(predictions[index].description ?? "inform yadu"),
              trailing: Icon(Icons.location_on),
            ),
          ),
        )
      ],
    );
  }

  _callOnSelectedWithDeets(AutocompletePrediction p) async {
    final id = p.placeId;
    if (id is String) {
      final tmp = await widget.googlePlace.details.get(id);
      if (tmp is DetailsResponse) {
        widget.onSelected(
          PickedLocation(
            Coordinates(
              latitude: tmp.result?.geometry?.location?.lat,
              longitude: tmp.result?.geometry?.location?.lng,
            ),
            tmp.result?.formattedAddress,
          ),
        );
      }
    }
  }

  Future _search(s) async {
    final result = await widget.googlePlace.autocomplete.get(s);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions ?? [];
      });
    }
  }
}
