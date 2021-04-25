![header](https://raw.githubusercontent.com/ondbyte/simple_strapi/main/template.png)

A Strapi library for Dart developers. with which you can make basic find, findOne, count.. etc queries, as well as complex graph queries. this is the basic package, I highly reccommend using this in conjunction with [super_strapi](https://github.com/ondbyte/super_strapi) which supports dart clas generation from strapi models.


# Usage

## Configure.

```dart
  Strapi.i.host = "strapi.example.com";
  Strapi.i.shouldUseHttps = true;
  Strapi.i.verbose = false;
  Strapi.i.maxListenersForAnObject = 8;
```

## Login/register
  to use `authenticateWithFirebaseUid` method first you need to add a custom provider for strapi with Firebase SDK enabled otherwise you'll recieve "This provider is disabled." response, go here https://yadunandan.xyz/authenticateWithFirebaseForStrapi to know how to add firebase as a authentication method, as of now it is the only method which is supported in authenticating with strapi
 (as our project required only that, other providers will be supported in later releases)
 
 ```dart
final response = await Strapi.i.authenticateWithFirebaseUid(
  firebaseUid: firebaseToken,
  email: email,
  name: name,
);
if (response.failed) {
  print("login failed");
  print(response);
} else{
  ///obtain token
  final jwt = response.body.first["jwt"]
}
```
> 📝 NOTE: once logged in library will include the jwt in its future requests automatically, but jwt token doesn't persist after app restarts, you are incharge of doing so and loading it in next app start like this
```dart
Strapi.i.strapiToken = "<your_saved_jwt>";

```
## Basic queries
Basic queries of strapi like find, findOne, count, delete, update, create etc are supported by `StrapiCollection`
```dart
final restaraunts = await StrapiCollection.findMultiple(collection:"restaraunts",limit:20);
```
## Complex graph queries
This should be whole new topic, but here we go.

graph query against strapi collection or List of references (think of repeatable references in strapi) in Strapi data structure, you can nest it according to the reference fields that exists in the data structure of the collection model, [collectionName] is required only for the root query, any [collectionName] passed to additional queries of a root query are ignored because query will be made against the field name, pass [requiredFields] to be in the response, [limit] is the maximum number of documents in the response, [start] can be used to paginate the queries,

if you have a collections like the fallowing,

A with model
```json
{
  "id":"<value>",
  "name": "<value>",
  "single_reference_for_B": "<id>",
  "repeatable_reference_for_C": ["<id>","<id>",...],
}
```
B with model
```json
{
  "id":"<value>",
  "dob": "<value>",
}
```
C with model
```json
{
  "id":"<value>",
  "place": "<value>",
}
```
for above collection models, if you are making graph query against collection A, required fields are passed like this
```dart
final query = StrapiCollectionQuery(
collectionName: "A",
requiredFields: [
    StrapiLeafField("id"),
    StrapiLeafField("name"),
  ],
);

///and [StrapiLeafField]s are filtered like this, this query returns objects contining the id (must return only one)
///check out [StrapiFieldQuery] to see all the filter posibilities
query.whereField(
   field: StrapiLeafField("id"),
   query: StrapiFieldQuery.equalTo,
   value: "<value>",
 );
```
you cannot require the `fields single_reference_for_B` and `repeatable_reference_for_C` as they are references, if you want to require them you have to nest the query against them like this,

lets modify the last query
```dart
///use [StrapiModelQuery] if the reference is single
query.whereModelField(
field: StrapiModelField("single_reference_for_B"),
    query: StrapiModelQuery(
    requiredFields: [
      StrapiLeafField("id"),
      StrapiLeafField("dob"),
    ],
  ),
);

///use [StrapiCollectionQuery] if the reference is repeatable i.e list of references as mentioned earlier
query.whereCollectionField(
field: StrapiCollectionField("repeatable_reference_for_C"),
query: StrapiCollectionQuery(
    collectionName: "C",
    requiredFields: [
      StrapiLeafField("id"),
      StrapiLeafField("place"),
    ],
  ),
);
```
and the query is executed like this
```dart
final strapiResponse = Strapi.i.graphRequest(queryString:query.query,);
```
> 📝 NOTE: as of now strapi supports nesting graph queries upto 20 level.

> 📝 NOTE: as of now strapi doesn't support querying components, it isn't supported by strapi as of now

so to include them in the response you have to explicitly pass the field names as String, for example
```dart
requireCompenentField(
  field: StrapiComponentField("someField"),
  fields: "{ componentFieldA,componentFieldB,componentFieldC }",
);
```