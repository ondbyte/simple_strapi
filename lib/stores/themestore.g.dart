// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'themestore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ThemeStore on _ThemeStore, Store {
  Computed<ThemeData> _$selectedThemeDataComputed;

  @override
  ThemeData get selectedThemeData => (_$selectedThemeDataComputed ??=
          Computed<ThemeData>(() => super.selectedThemeData,
              name: '_ThemeStore.selectedThemeData'))
      .value;

  final _$brightnessAtom = Atom(name: '_ThemeStore.brightness');

  @override
  Brightness get brightness {
    _$brightnessAtom.reportRead();
    return super.brightness;
  }

  @override
  set brightness(Brightness value) {
    _$brightnessAtom.reportWrite(value, super.brightness, () {
      super.brightness = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_ThemeStore.init');

  @override
  Future<dynamic> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  @override
  String toString() {
    return '''
brightness: ${brightness},
selectedThemeData: ${selectedThemeData}
    ''';
  }
}
