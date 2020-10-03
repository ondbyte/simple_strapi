// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$FeedbackStore on _FeedbackStore, Store {
  final _$feedBackAtom = Atom(name: '_FeedbackStore.feedBack');

  @override
  TheFeedBack<dynamic> get feedBack {
    _$feedBackAtom.reportRead();
    return super.feedBack;
  }

  @override
  set feedBack(TheFeedBack<dynamic> value) {
    _$feedBackAtom.reportWrite(value, super.feedBack, () {
      super.feedBack = value;
    });
  }

  final _$customWidgetAtom = Atom(name: '_FeedbackStore.customWidget');

  @override
  Widget get customWidget {
    _$customWidgetAtom.reportRead();
    return super.customWidget;
  }

  @override
  set customWidget(Widget value) {
    _$customWidgetAtom.reportWrite(value, super.customWidget, () {
      super.customWidget = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_FeedbackStore.init');

  @override
  Future<dynamic> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$pingAsyncAction = AsyncAction('_FeedbackStore.ping');

  @override
  Future<dynamic> ping(TheFeedBack<dynamic> feedBack,
      {String description,
      Duration duration = const Duration(seconds: 4),
      Widget customWidget}) {
    return _$pingAsyncAction.run(() => super.ping(feedBack,
        description: description,
        duration: duration,
        customWidget: customWidget));
  }

  @override
  String toString() {
    return '''
feedBack: ${feedBack},
customWidget: ${customWidget}
    ''';
  }
}
