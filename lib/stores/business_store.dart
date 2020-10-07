import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'business_store.g.dart';

class BusinessStore = _BusinessStore with _$BusinessStore;

abstract class _BusinessStore with Store {
  final _fireStore = FirebaseFirestore.instance;
  @observable
  ObservableList<BusinessCategory> categories = ObservableList();

  Future init() async {

  }

  @action
  Future getCategories() async {
    final categorySnaps = await _fireStore.collection("categories").get();
    categories.clear();
    categorySnaps.docs.forEach((element) {
      categories.add(BusinessCategory(name: element.id,normalName: element.id.replaceAll("_", " ")));
    });
  }
}

class BusinessApplication{
  final BusinessCategory category;
  final String businessName;
  final String contactNumber;
  final String address;
  final GeoPoint latLon;

  BusinessApplication(this.category, this.businessName, this.contactNumber, this.address, this.latLon);
}

class BusinessCategory{
  final String name;
  final String normalName;

  BusinessCategory({this.normalName, this.name});
}