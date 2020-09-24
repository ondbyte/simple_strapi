// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'themestore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ThemeStore on _ThemeStore, Store {
  final _$selectedThemeDataAtom = Atom(name: '_ThemeStore.selectedThemeData');

  @override
  ThemeData get selectedThemeData {
    _$selectedThemeDataAtom.reportRead();
    return super.selectedThemeData;
  }

  @override
  set selectedThemeData(ThemeData value) {
    _$selectedThemeDataAtom.reportWrite(value, super.selectedThemeData, () {
      super.selectedThemeData = value;
    });
  }

  final _$_ThemeStoreActionController = ActionController(name: '_ThemeStore');

  @override
  void flipTheme() {
    final _$actionInfo = _$_ThemeStoreActionController.startAction(
        name: '_ThemeStore.flipTheme');
    try {
      return super.flipTheme();
    } finally {
      _$_ThemeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedThemeData: ${selectedThemeData}
    ''';
  }
}
