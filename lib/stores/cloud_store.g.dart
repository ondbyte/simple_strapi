// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$CloudStore on _CloudStore, Store {
  final _$myLocationAtom = Atom(name: '_CloudStore.myLocation');

  @override
  Location get myLocation {
    _$myLocationAtom.reportRead();
    return super.myLocation;
  }

  @override
  set myLocation(Location value) {
    _$myLocationAtom.reportWrite(value, super.myLocation, () {
      super.myLocation = value;
    });
  }

  final _$activeCountriesAtom = Atom(name: '_CloudStore.activeCountries');

  @override
  List<String> get activeCountries {
    _$activeCountriesAtom.reportRead();
    return super.activeCountries;
  }

  @override
  set activeCountries(List<String> value) {
    _$activeCountriesAtom.reportWrite(value, super.activeCountries, () {
      super.activeCountries = value;
    });
  }

  final _$availableLocationsAtom = Atom(name: '_CloudStore.availableLocations');

  @override
  Map<String, List<Location>> get availableLocations {
    _$availableLocationsAtom.reportRead();
    return super.availableLocations;
  }

  @override
  set availableLocations(Map<String, List<Location>> value) {
    _$availableLocationsAtom.reportWrite(value, super.availableLocations, () {
      super.availableLocations = value;
    });
  }

  final _$userTypeAtom = Atom(name: '_CloudStore.userType');

  @override
  UserType get userType {
    _$userTypeAtom.reportRead();
    return super.userType;
  }

  @override
  set userType(UserType value) {
    _$userTypeAtom.reportWrite(value, super.userType, () {
      super.userType = value;
    });
  }

  final _$alterEgoAtom = Atom(name: '_CloudStore.alterEgo');

  @override
  UserType get alterEgo {
    _$alterEgoAtom.reportRead();
    return super.alterEgo;
  }

  @override
  set alterEgo(UserType value) {
    _$alterEgoAtom.reportWrite(value, super.alterEgo, () {
      super.alterEgo = value;
    });
  }

  final _$getMyRolesAsyncAction = AsyncAction('_CloudStore.getMyRoles');

  @override
  Future<dynamic> getMyRoles() {
    return _$getMyRolesAsyncAction.run(() => super.getMyRoles());
  }

  final _$getMytLocationAsyncAction = AsyncAction('_CloudStore.getMytLocation');

  @override
  Future<dynamic> getMytLocation() {
    return _$getMytLocationAsyncAction.run(() => super.getMytLocation());
  }

  final _$getActiveCountriesAsyncAction =
      AsyncAction('_CloudStore.getActiveCountries');

  @override
  Future<dynamic> getActiveCountries() {
    return _$getActiveCountriesAsyncAction
        .run(() => super.getActiveCountries());
  }

  final _$getLocationsInCountryAsyncAction =
      AsyncAction('_CloudStore.getLocationsInCountry');

  @override
  Future<dynamic> getLocationsInCountry(String country) {
    return _$getLocationsInCountryAsyncAction
        .run(() => super.getLocationsInCountry(country));
  }

  @override
  String toString() {
    return '''
myLocation: ${myLocation},
activeCountries: ${activeCountries},
availableLocations: ${availableLocations},
userType: ${userType},
alterEgo: ${alterEgo}
    ''';
  }
}
