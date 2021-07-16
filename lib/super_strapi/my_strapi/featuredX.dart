import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class FeaturedX {
  static late FeaturedX i;
  FeaturedX._i();

  factory FeaturedX() {
    final i = FeaturedX._i();
    FeaturedX.i = i;
    return i;
  }

  Future<List<Featured>> getFeatured(location) async {
    final city = location is City ? location : null;
    final locality = location is Locality ? location : null;

    if (city is! City && locality is! Locality) {
      return [];
    }
    final q = StrapiCollectionQuery(
      collectionName: Featured.collectionName,
      requiredFields: Featured.fields(),
    )..whereCollectionField(
        field: Featured.fields.businesses,
        query: StrapiCollectionQuery(
          collectionName: Business.collectionName,
          requiredFields: Business.fields(),
        )..requireCompenentField(Business.fields.address, "{address}"),
      );
    if (locality is Locality) {
      q.whereModelField(
        field: Featured.fields.locality,
        query: StrapiModelQuery(
          requiredFields: Locality.fields(),
        )..whereField(
            field: Locality.fields.id,
            query: StrapiFieldQuery.equalTo,
            value: locality.id,
          ),
      );
      final data = await Featureds.executeQuery(q);
      return data;
    } else if (city is City) {
      q.whereModelField(
        field: Featured.fields.city,
        query: StrapiModelQuery(
          requiredFields: City.fields(),
        )..whereField(
            field: City.fields.id,
            query: StrapiFieldQuery.equalTo,
            value: city.id,
          ),
      );
      return Featureds.executeQuery(q);
    }
    return [];
  }
}
