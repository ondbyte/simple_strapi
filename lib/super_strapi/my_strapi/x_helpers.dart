import 'package:bapp/helpers/helper.dart';
import 'package:geocoder/geocoder.dart' as g;
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

String? placeName({Locality? locality, City? city}) {
  print("placeName: $locality\n$city");

  return locality?.name ?? city?.name;
}

g.Coordinates geocoderCordinates(Coordinates coordinates) {
  return g.Coordinates(coordinates.latitude, coordinates.longitude);
}

Future<T>? runNullAware<T>(dynamic mayBeNull, Future<T> Function(dynamic) run,
    {ifNull}) {
  if (mayBeNull != null) {
    return run(mayBeNull);
  }
  if (ifNull != null) {
    return Future.value(ifNull);
  }
}
