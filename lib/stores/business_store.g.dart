// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$BusinessStore on _BusinessStore, Store {
  final _$categoriesAtom = Atom(name: '_BusinessStore.categories');

  @override
  ObservableList<BusinessCategory> get categories {
    _$categoriesAtom.reportRead();
    return super.categories;
  }

  @override
  set categories(ObservableList<BusinessCategory> value) {
    _$categoriesAtom.reportWrite(value, super.categories, () {
      super.categories = value;
    });
  }

  final _$getCategoriesAsyncAction =
      AsyncAction('_BusinessStore.getCategories');

  @override
  Future<dynamic> getCategories() {
    return _$getCategoriesAsyncAction.run(() => super.getCategories());
  }

  @override
  String toString() {
    return '''
categories: ${categories}
    ''';
  }
}
