// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AuthStore on _AuthStore, Store {
  final _$statusAtom = Atom(name: '_AuthStore.status');

  @override
  AuthStatus get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(AuthStatus value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  final _$userAtom = Atom(name: '_AuthStore.user');

  @override
  User get user {
    _$userAtom.reportRead();
    return super.user;
  }

  @override
  set user(User value) {
    _$userAtom.reportWrite(value, super.user, () {
      super.user = value;
    });
  }

  final _$loadingForOTPAtom = Atom(name: '_AuthStore.loadingForOTP');

  @override
  bool get loadingForOTP {
    _$loadingForOTPAtom.reportRead();
    return super.loadingForOTP;
  }

  @override
  set loadingForOTP(bool value) {
    _$loadingForOTPAtom.reportWrite(value, super.loadingForOTP, () {
      super.loadingForOTP = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_AuthStore.init');

  @override
  Future<dynamic> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$signOutAsyncAction = AsyncAction('_AuthStore.signOut');

  @override
  Future<dynamic> signOut() {
    return _$signOutAsyncAction.run(() => super.signOut());
  }

  @override
  String toString() {
    return '''
status: ${status},
user: ${user},
loadingForOTP: ${loadingForOTP}
    ''';
  }
}
