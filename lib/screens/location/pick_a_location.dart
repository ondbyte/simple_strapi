import 'dart:async';

import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/location/search_a_place.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart' as g;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class PickAPlaceLocationScreen extends StatefulWidget {
  @override
  _PickAPlaceLocationScreenState createState() =>
      _PickAPlaceLocationScreenState();
}

class _PickAPlaceLocationScreenState extends State<PickAPlaceLocationScreen> {
  PickedLocation? _pickedLocation;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool _loading = false;
  final GooglePlace _googlePlace = GooglePlace(kMapsKey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick a Location"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Get.back(result: null);
          },
        ),
        actions: [
          FlatButton(
            onPressed: !_loading || _pickedLocation != null
                ? () async {
                    if (!mounted) {
                      return;
                    }
                    setState(
                      () {
                        _loading = !_loading;
                      },
                    );
                    final point = g.Coordinates(
                      _pickedLocation?.latLong?.latitude,
                      _pickedLocation?.latLong?.longitude,
                    );

                    ///print(point);
                    final adr = await g.Geocoder.google(kMapsKey)
                        .findAddressesFromCoordinates(
                      point,
                    );
                    _pickedLocation = PickedLocation(
                      Coordinates(
                        latitude: _pickedLocation?.latLong?.latitude,
                        longitude: _pickedLocation?.latLong?.longitude,
                      ),
                      Helper.stringifyAddresse(
                        adr[0],
                      ),
                    );

                    Get.back(result: _pickedLocation);
                  }
                : null,
            child: Text(
              "OK",
            ),
            textTheme: ButtonTextTheme.primary,
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Builder(
            builder: (_) {
              final latLong = UserX.i.user()?.locality?.coordinates;
              return GoogleMap(
                myLocationButtonEnabled: false,
                buildingsEnabled: true,
                trafficEnabled: true,
                initialCameraPosition: CameraPosition(
                  zoom: 18,
                  target: LatLng(
                    latLong?.latitude ?? 0,
                    latLong?.longitude ?? 0,
                  ),
                ),
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _pickedLocation = PickedLocation(latLong, "");
                  if (!_controller.isCompleted) {
                    _controller.complete(controller);
                  }
                },
                onCameraMove: (cp) {
                  _pickedLocation = PickedLocation(
                      Coordinates(
                          latitude: cp.target.latitude,
                          longitude: cp.target.longitude),
                      "");
                },
              );
            },
          ),
          Center(
            child: Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
              size: 40,
            ),
          ),
          SearchAPlaceScreen(
            googlePlace: _googlePlace,
            onSelected: (p) async {
              _pickedLocation = p;
              final tmp = await _controller.future;
              tmp.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    zoom: 18,
                    target: Helper.alternateLatLong(p.latLong),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PickedLocation {
  final Coordinates? latLong;
  final String? address;

  PickedLocation(this.latLong, this.address);
}
