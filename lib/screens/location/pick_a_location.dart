import 'package:bapp/config/constants.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class PickAPlaceLocationScreen extends StatefulWidget {
  @override
  _PickAPlaceLocationScreenState createState() =>
      _PickAPlaceLocationScreenState();
}

class _PickAPlaceLocationScreenState extends State<PickAPlaceLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick a Location"),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: (){
            _showDialogue(context);
          },)
        ],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
      ),
      body: StoreProvider<CloudStore>(
        store: Provider.of<CloudStore>(context, listen: false),
        init: (cloudStore) {},
        builder: (_, cloudStore) {
          if (cloudStore.myLocation == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              zoom: 18,
              target: LatLng(
                cloudStore.myLocation.latLong.latitude,
                cloudStore.myLocation.latLong.longitude,
              ),
            ),
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
          );
        },
      ),
    );
  }

  var a = PlacesAutocomplete();
  _showDialogue(BuildContext context){
    return showDialog(context: context,
    builder: (_){
      return Dialog(
        child: PlacesAutocompleteWidget(
          apiKey: kMapsKey,
          onError: (e){
            print(e.errorMessage);
          },
        ),
      );
    });
  }
}

class PickedLocation {
  final GeoPoint latLong;
  final String address;

  PickedLocation(this.latLong, this.address);
}
