import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

Future main() async {
  print(someMethod());
}

someMethod() async {
  final query = StrapiCollectionQuery(
    collectionName: Business.collectionName,
    requiredFields: Business.fields(),
  );

  query.whereModelField(
    field: Business.fields.partner,
    query: StrapiModelQuery(
      requiredFields: Partner.fields(),
    )..whereField(
        field: Partner.fields.id,
        query: StrapiFieldQuery.equalTo,
        value: "some id",
      ),
  );
/* 
  query.whereCollectionField(
    field: Business.fields.employees,
    query: StrapiCollectionQuery(
      collectionName: Employee.collectionName,
      requiredFields: Employee.fields(),
    ),
  ); */

  final ps = await Partners.executeQuery(query);
}
