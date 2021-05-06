// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

Future<void> main() async {
  /*test("countries", () async {
    final i = StrapiSettings.i;
    final cs = await LocalityX.i.getCountries();
    if (cs.isNotEmpty) {
      final c = cs.first;
      Helper.bPrint((await LocalityX.i.getCitiesOfCountry(c)));
    }
  });
  test("login and jwt", () async {
    await StrapiSettings.i.init();

    await DefaultDataX.i.init();
    final token = await DefaultDataX.i.getValue("token", defaultValue: "");
    final user = await UserX.i.init();
    sPrint(user);
    expect(UserX.i.userPresent, token != "");
    await UserX.i.loginWithFirebase(
        "4aUW91LyzxYGyPHNocl4BqQWwXG2", "iam@iam.com", "yadu");
    expect(UserX.i.userPresent, true);
  });
  final f = City.fields;

  final list = await Bookings.executeQuery(
    StrapiCollectionQuery(
      collectionName: Locality.collectionName,
      requiredFields: Locality.fields(),
    )..whereField(
        field: Locality.fields.name,
        query: StrapiFieldQuery.equalTo,
        value: "Al Barsha",
      ),
  ); */

  /* test(
    "graph query",
    () async {
      final q = StrapiCollectionQuery(
        collectionName: City.collectionName,
        requiredFields: City.fields(),
      );

      final response = await Cities.executeQuery(q);
      print(response);
    },
  ); */
  test(
    "default data test",
    () async {
      await StrapiSettings.i.init();
      final dd = await DefaultDatas.findOne("605ccfad19ddf7000e3ed9c0");
      if (dd is DefaultData) {
        final newDd = dd.copyWIth(
          locality: Locality.fromID("5ffb4e8f7c2625000eb3b516"),
        );
        await DefaultDatas.update(newDd);
      }
    },
  );
}
