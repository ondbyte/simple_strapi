import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'feedback_store.g.dart';

class FeedbackStore = _FeedbackStore with _$FeedbackStore;

abstract class _FeedbackStore with Store {
  @observable
  TheFeedBack feedBack;
  @observable
  Widget customWidget;


  @action
  Future init()async {

  }

  @action
  Future ping(TheFeedBack feedBack,{String description,Duration duration=const Duration(seconds: 4),Widget customWidget}) async {
    this.feedBack = feedBack;
    this.customWidget = customWidget;
    Future.delayed(duration,(){
      this.feedBack = null;
      this.customWidget = null;
    });
  }
}

class TheFeedBack<T>{
  final TheFeedBackType type;
  final String message;
  final String description;
  String buttonLabel;
  final T variable;
  final dynamic Function(T) doFirst;
  final dynamic Function(T) doOnOkay;
  final dynamic Function(T) doOnUndo;

  TheFeedBack( {this.variable,this.type=TheFeedBackType.normal, this.message="", this.description="", this.buttonLabel="", this.doFirst,this.doOnOkay,this.doOnUndo}){
    if(buttonLabel==""){
      if(doOnUndo!=null){
        buttonLabel = "Undo";
      } else if(doOnOkay !=null){
        buttonLabel = "Okay";
      }
    }
  }
}

enum TheFeedBackType{
  error,
  normal
}
