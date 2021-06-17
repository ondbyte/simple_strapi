import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class HandPickedX {
  static late HandPickedX i;
  HandPickedX._i();

  factory HandPickedX() {
    final i = HandPickedX._i();
    HandPickedX.i = i;
    return i;
  }

  Future init() async {}

  Future<List<HandPicked>> getAll(City? city, Locality? locality) async {
    assert(city is City || locality is Locality);
    final q = StrapiCollectionQuery(
      collectionName: HandPicked.collectionName,
      requiredFields: HandPicked.fields(),
    )..whereCollectionField(
        field: HandPicked.fields.businesses,
        query: StrapiCollectionQuery(
          collectionName: Business.collectionName,
          requiredFields: Business.fields(),
        )..requireCompenentField(Business.fields.address, "{address}"),
      );
    if (locality is Locality) {
      q.whereModelField(
        field: HandPicked.fields.locality,
        query: StrapiModelQuery(
          requiredFields: Locality.fields(),
        )..whereField(
            field: Locality.fields.id,
            query: StrapiFieldQuery.equalTo,
            value: locality.id,
          ),
      );
      final data = await HandPickeds.executeQuery(q);
      return data;
    } else if (city is City) {
      q.whereModelField(
        field: HandPicked.fields.city,
        query: StrapiModelQuery(
          requiredFields: Locality.fields(),
        )..whereField(
            field: City.fields.id,
            query: StrapiFieldQuery.equalTo,
            value: city.id,
          ),
      );
      return HandPickeds.executeQuery(q);
    }
    return [];
  }
}
