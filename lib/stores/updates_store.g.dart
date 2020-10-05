// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updates_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UpdatesStore on _UpdatesStore, Store {
  final _$updatesAtom = Atom(name: '_UpdatesStore.updates');

  @override
  ObservableMap<String, NotificationUpdate> get updates {
    _$updatesAtom.reportRead();
    return super.updates;
  }

  @override
  set updates(ObservableMap<String, NotificationUpdate> value) {
    _$updatesAtom.reportWrite(value, super.updates, () {
      super.updates = value;
    });
  }

  final _$newsAtom = Atom(name: '_UpdatesStore.news');

  @override
  ObservableMap<String, NotificationUpdate> get news {
    _$newsAtom.reportRead();
    return super.news;
  }

  @override
  set news(ObservableMap<String, NotificationUpdate> value) {
    _$newsAtom.reportWrite(value, super.news, () {
      super.news = value;
    });
  }

  final _$viewedAtom = Atom(name: '_UpdatesStore.viewed');

  @override
  ObservableMap<String, NotificationUpdate> get viewed {
    _$viewedAtom.reportRead();
    return super.viewed;
  }

  @override
  set viewed(ObservableMap<String, NotificationUpdate> value) {
    _$viewedAtom.reportWrite(value, super.viewed, () {
      super.viewed = value;
    });
  }

  final _$removeAsyncAction = AsyncAction('_UpdatesStore.remove');

  @override
  Future<dynamic> remove(NotificationUpdate u) {
    return _$removeAsyncAction.run(() => super.remove(u));
  }

  final _$undoRemoveAsyncAction = AsyncAction('_UpdatesStore.undoRemove');

  @override
  Future<dynamic> undoRemove(NotificationUpdate u) {
    return _$undoRemoveAsyncAction.run(() => super.undoRemove(u));
  }

  final _$setViewedForUpdateAsyncAction =
      AsyncAction('_UpdatesStore.setViewedForUpdate');

  @override
  Future<dynamic> setViewedForUpdate(NotificationUpdate update) {
    return _$setViewedForUpdateAsyncAction
        .run(() => super.setViewedForUpdate(update));
  }

  final _$getUpdatesAsyncAction = AsyncAction('_UpdatesStore.getUpdates');

  @override
  Future<dynamic> getUpdates({DateTime dt}) {
    return _$getUpdatesAsyncAction.run(() => super.getUpdates(dt: dt));
  }

  @override
  String toString() {
    return '''
updates: ${updates},
news: ${news},
viewed: ${viewed}
    ''';
  }
}
