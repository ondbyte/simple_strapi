import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'feedback_store.g.dart';

class FeedbackStore = _FeedbackStore with _$FeedbackStore;

abstract class _FeedbackStore with Store {
  @observable
  Widget message = SizedBox();

  @action
  Future init()async {

  }

  @action
  Future ping(Widget m,{Duration duration=const Duration(seconds: 4)}) async {
    message = m;
    Future.delayed(duration,(){
      message = SizedBox();
    });
  }

}