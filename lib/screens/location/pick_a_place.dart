import 'package:bapp/classes/location.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class PickAPlaceScreen extends StatelessWidget {
  final Country country;
  const PickAPlaceScreen({this.country, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (country == null) {
      return _showCountries(context);
    }
    if (country != null) {
      return _showLocations(context);
    }
    throw FlutterError("only countries and location screen supported");
  }

  Widget _showCountries(BuildContext context) {
    return StoreProvider<CloudStore>(
      store: Provider.of<CloudStore>(context, listen: false),
      init: (cloudStore) async {
        ///initialize user data
        //await cloudStore.init(context);
        //await cloudStore.getActiveCountries();
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
              body: cloudStore.countries != null
                  ? ListView(
                      children: <Widget>[
                        ...cloudStore.countries.map(
                          (e) => ListTile(
                            title: Text(e.thePhoneNumber.englishName),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              //cloudStore.getLocationsInCountry(e);
                              Navigator.of(context).pushNamed(
                                RouteManager.pickAPlace,
                                arguments: e,
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
              body:Builder(
                builder: (_){
                  final cities = country.cities;
                  return ListView(
                    children: List.generate(
                      cities.length,
                          (index) => _getSubLocationWidget(
                        context,cities[index],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _getSubLocationWidget(
      BuildContext context, City city) {
    return city.enabled? Column(
      children: [
        ListTile(
          trailing: Icon(Icons.arrow_forward_ios),
          title: Text(
            "All of ${city.name}",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          onTap: () {
            Provider.of<CloudStore>(context, listen: false).myAddress =
                MyAddress(
                  city: city,
                  country: country,
                );
            Navigator.of(context)
                .pushNamedAndRemoveUntil(RouteManager.home, (_) => false);
          },
        ),
        ...List.generate(
          city.localities.length,
          (index) => ListTile(
            trailing: Icon(Icons.arrow_forward_ios),
            title: Text(city.localities[index].name,
                style: Theme.of(context).textTheme.subtitle2),
            onTap: () {
              context.read<CloudStore>().myAddress = MyAddress(country: country,city: city,locality: city.localities[index]);
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(RouteManager.home, (_) => false,);
            },
          ),
        ),
      ],
    ):SizedBox();
  }
}
