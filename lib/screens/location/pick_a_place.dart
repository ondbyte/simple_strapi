import 'package:bapp/classes/location.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class PickAPlaceScreen extends StatelessWidget {
  final int screen;
  const PickAPlaceScreen(this.screen, {Key key}) : super(key: key);

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
      store: Provider.of<CloudStore>(context, listen: false),
      init: (cloudStore) async {
        ///initialize user data
        await cloudStore.init(context);
        await cloudStore.getActiveCountries();
      },
      builder: (_, cloudStore) {
        return Observer(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: true,
                title: Text(
                  "Pick a Country",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              body: cloudStore.activeCountriesNames != null
                  ? ListView(
                      children: <Widget>[
                        ...cloudStore.activeCountriesNames.map(
                          (e) => ListTile(
                            title: Text("$e"),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              cloudStore.getLocationsInCountry(e);
                              Navigator.of(context).pushNamed(
                                RouteManager.pickAPlace,
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
      store: Provider.of<CloudStore>(context, listen: false),
      builder: (context, cloudStore) {
        return Observer(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: true,
                title: Text(
                  "Pick a City",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              body: cloudStore.availableLocations != null &&cloudStore.availableLocations.isNotEmpty
                  ? ListView(
                      children: List.generate(
                        cloudStore.availableLocations.length,
                        (index) => _getSubLocationWidget(
                          context,
                          cloudStore.availableLocations.keys.elementAt(index),
                          cloudStore.availableLocations.values.elementAt(index),
                        ),
                      ),
                    )
                  : LoadingWidget(),
            );
          },
        );
      },
    );
  }

  Widget _getSubLocationWidget(
      BuildContext context, String city, List<Location> locations) {
    return Column(
      children: [
        ListTile(
          trailing: Icon(Icons.arrow_forward_ios),
          title: Text(
            "All of $city",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          onTap: () {
            Provider.of<CloudStore>(context, listen: false).myLocation =
                Location(
              "",
              city,
              locations[0].state,
              locations[0].country,
                  locations[0].latLong,
            );
            Navigator.of(context)
                .pushNamedAndRemoveUntil(RouteManager.home, (_) => false);
          },
        ),
        ...List.generate(
          locations.length,
          (index) => ListTile(
            trailing: Icon(Icons.arrow_forward_ios),
            title: Text(locations[index].locality,
                style: Theme.of(context).textTheme.subtitle2),
            onTap: () {
              context.read<CloudStore>().myLocation = locations[index];
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(RouteManager.home, (_) => false,);
            },
          ),
        ),
      ],
    );
  }
}
