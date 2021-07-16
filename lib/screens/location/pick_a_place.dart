import 'package:bapp/classes/firebase_structures/bapp_user.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/localityX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/my_strapi/x_helpers.dart';
import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/loading.dart';
import 'package:bapp/widgets/tiles/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class PickAPlaceScreen extends StatefulWidget {
  final Country? country;
  const PickAPlaceScreen({this.country, Key? key}) : super(key: key);

  @override
  _PickAPlaceScreenState createState() => _PickAPlaceScreenState();
}

class _PickAPlaceScreenState extends State<PickAPlaceScreen> {
  ValueKey getCountriesKey = ValueKey(DateTime.now());

  final loading = Rx(false);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (loading()) {
        return LoadingWidget();
      }
      if (widget.country == null) {
        return _showCountries(context);
      }
      if (widget.country != null) {
        return _showLocations(context);
      }
      throw FlutterError("only countries and location screen supported");
    });
  }

  Widget _showCountries(BuildContext context) {
    return TapToReFetch<List<Country>>(
      fetcher: () {
        return LocalityX.i.getCountries();
      },
      onLoadBuilder: (_) {
        return LoadingWidget();
      },
      onErrorBuilder: (_, e, s) {
        return ErrorTile(message: "tap to refresh");
      },
      onSucessBuilder: (_, countries) {
        final data = countries;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(
              "Pick a Country",
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          body: ListView(
            children: <Widget>[
              ...data.map(
                (e) => ListTile(
                  title: Text(e.name ?? "no name inform yadu"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final data = await Get.to(
                      PickAPlaceScreen(
                        country: e,
                      ),
                      preventDuplicates: false,
                    );
                    if (data != null) {
                      Get.back(result: data);
                    }
                  },
                ),
              ),
            ],
          ),
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
          widget.country,
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
                    Get.back(result: city);
                  }),
              ...List.generate(
                city.localities?.length ?? 0,
                (index) => ListTile(
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: Text(city.localities?[index].name ?? "",
                        style: Theme.of(context).textTheme.subtitle2),
                    onTap: () async {
                      Get.back(result: city.localities?[index]);
                    }),
              ),
            ],
          )
        : SizedBox();
  }
}
