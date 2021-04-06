import 'package:bapp/classes/firebase_structures/bapp_user.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/localityX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_helpers.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class PickAPlaceScreen extends StatelessWidget {
  final Country? country;
  const PickAPlaceScreen({this.country, Key? key}) : super(key: key);

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
    return FutureBuilder<List<Country>>(
      future: LocalityX.i.getCountries(),
      builder: (_, snap) {
        final data = snap.data ?? [];
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(
              "Pick a Country",
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          body: snap.connectionState == ConnectionState.done
              ? ListView(
                  children: <Widget>[
                    ...data.map(
                      (e) => ListTile(
                        title: Text(e.name ?? "no name inform yadu"),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          //cloudStore.getLocationsInCountry(e);
                          BappNavigator.push(
                            context,
                            PickAPlaceScreen(
                              country: e,
                            ),
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
  }

  Widget _showLocations(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "Pick a City",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: FutureBuilder<List<City>>(
        future: runNullAware<List<City>>(
          country,
          (c) => LocalityX.i.getCitiesOfCountry(c),
          ifNull: [],
        ),
        builder: (_, snap) {
          final data = snap.data ?? [];
          return snap.hasData
              ? ListView(
                  children: List.generate(
                    data.length,
                    (index) => _getSubLocationWidget(
                      context,
                      data[index],
                    ),
                  ),
                )
              : LoadingWidget();
        },
      ),
    );
  }

  Widget _getSubLocationWidget(BuildContext context, City city) {
    return city.enabled ?? false
        ? Column(
            children: [
              ListTile(
                trailing: Icon(Icons.arrow_forward_ios),
                title: Text(
                  "All of ${city.name}",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                onTap: () async {
                  if (UserX.i.userPresent) {
                    final copied = UserX.i.user()?.copyWIth(city: city);
                    if (copied is User) {
                      await Users.update(copied);
                    }
                  } else {
                    final copied = DefaultDataX.i.defaultData()?.copyWIth(
                          city: city,
                        );
                    if (copied is DefaultData) {
                      await DefaultDatas.update(copied);
                    }
                  }
                  BappNavigator.pushAndRemoveAll(context, Bapp());
                },
              ),
              ...List.generate(
                city.localities?.length ?? 0,
                (index) => ListTile(
                  trailing: Icon(Icons.arrow_forward_ios),
                  title: Text(city.localities?[index].name ?? "",
                      style: Theme.of(context).textTheme.subtitle2),
                  onTap: () async {
                    if (UserX.i.userPresent) {
                      final copied = UserX.i
                          .user()
                          ?.copyWIth(locality: city.localities?[index]);
                      if (copied is User) {
                        await Users.update(copied);
                      }
                    } else {
                      final copied = DefaultDataX.i.defaultData()?.copyWIth(
                            locality: city.localities?[index],
                          );
                      if (copied is DefaultData) {
                        await DefaultDatas.update(copied);
                      } else {
                        bPrint("fail");
                      }
                    }
                    BappNavigator.pushAndRemoveAll(context, Bapp());
                  },
                ),
              ),
            ],
          )
        : SizedBox();
  }
}
