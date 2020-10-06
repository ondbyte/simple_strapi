import 'package:bapp/classes/location.dart';
import 'package:bapp/stores/auth_store.dart';
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
    return WillPopScope(child: Builder(builder: (_) {
      if (screen == 0) {
        return _showCountries(context);
      }
      if (screen == 1) {
        return _showLocations(context);
      }
      throw FlutterError("only countries and location screen supported");
    }), onWillPop: () async {
      if (screen == 1) {
        Navigator.of(context).pushReplacementNamed("/pickaplace", arguments: 0);
      }
      return false;
    });
  }

  Widget _showCountries(BuildContext context) {
    return StoreProvider<CloudStore>(
      store: Provider.of<CloudStore>(context, listen: false),
      init: (cloudStore) async {
        ///initialize user data
        await cloudStore.init(Provider.of<AuthStore>(context, listen: false));
        await cloudStore.getActiveCountries();
      },
      builder: (_, cloudStore) {
        return Observer(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
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
      store: Provider.of<CloudStore>(context,listen: false),
      builder: (context, cloudStore) {
        return Observer(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text(
                  "Pick a City",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              body: cloudStore.availableLocations != null
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
      BuildContext context, String state, List<Location> locations) {
    return Column(
      children: [
        ListTile(
          trailing: Icon(Icons.arrow_forward_ios),
          title: Text(
            "All of $state",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          onTap: (){
            Provider.of<CloudStore>(context,listen: false).myLocation = Location("", "", state, locations[0].country);
            Navigator.of(context).pushNamedAndRemoveUntil("/home",(_)=>false);
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
              Navigator.of(context).pushNamedAndRemoveUntil("/home",(_)=>false);
            },
          ),
        ),
      ],
    );
  }
}
