import 'package:bapp/classes/location.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class PickALocationScreen extends StatelessWidget {
  final int screen;
  const PickALocationScreen(this.screen, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (screen == 0) {
      return _showCountries(context);
    }
    if (screen == 1) {
      return _showLocations(context);
    }
    throw FlutterError("only countries and location screen supported");
  }

  Widget _showCountries(BuildContext context) {
    return StoreProvider<CloudStore>(
      init: (cloudStore) {
        cloudStore.getActiveCountries();
      },
      store: Provider.of<CloudStore>(context),
      builder: (_, cloudStore) {
        return Observer(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Pick a Country"),
              ),
              body: cloudStore.activeCountries != null
                  ? ListView(
                      children: <Widget>[
                        ...cloudStore.activeCountries.map(
                          (e) => ListTile(
                            title: Text("$e"),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              cloudStore.getLocationsInCountry(e);
                              Navigator.of(context).pushReplacementNamed(
                                "/pickaplace",
                                arguments: 1,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : LoadingWidget(),
            );
          },
        );
      },
    );
  }

  Widget _showLocations(BuildContext context) {
    return StoreProvider<CloudStore>(
      store: context.watch<CloudStore>(),
      builder: (context, cloudStore) {
        return Observer(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Pick a City"),
              ),
              body: cloudStore.availableLocations!=null?ListView(
                children: List.generate(
                  cloudStore.availableLocations.length,
                      (index) => _getSubLocationWidget(
                    context,
                    cloudStore.availableLocations.keys.elementAt(index),
                    cloudStore.availableLocations.values.elementAt(index),
                  ),
                ),
              ):LoadingWidget(),
            );
          },
        );
      },
    );
  }

  Widget _getSubLocationWidget(
      BuildContext context, String state, List<Location> locations) {
    return Column(
      children: [
        ListTile(
          title: Text(
            "$state",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
        ...List.generate(
          locations.length,
          (index) => ListTile(
            title: Text(locations[index].locality,
                style: Theme.of(context).textTheme.bodyText1),
                onTap: (){
                  context.read<CloudStore>().myLocation = locations[index];
                  Navigator.of(context).pushReplacementNamed("/home");
                },
          ),
        ),
      ],
    );
  }
}
