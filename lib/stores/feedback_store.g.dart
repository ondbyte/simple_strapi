// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$FeedbackStore on _FeedbackStore, Store {
  final _$messageAtom = Atom(name: '_FeedbackStore.message');

  @override
  Widget get message {
    _$messageAtom.reportRead();
    return super.message;
  }

  @override
  set message(Widget value) {
    _$messageAtom.reportWrite(value, super.message, () {
      super.message = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_FeedbackStore.init');

  @override
  Future<dynamic> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$pingAsyncAction = AsyncAction('_FeedbackStore.ping');

  @override
  Future<dynamic> ping(Widget m,
      {Duration duration = const Duration(seconds: 4)}) {
    return _$pingAsyncAction.run(() => super.ping(m, duration: duration));
  }

  @override
  String toString() {
    return '''
message: ${message}
    ''';
  }
}
