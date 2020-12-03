import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

class BusinessServices {
  final BusinessBranch branch;
  final all = ObservableList<BusinessService>();
  final allCategories = ObservableList<BusinessServiceCategory>();

  BusinessServices.empty({this.branch});

  BusinessServices.fromJson(Map<String,dynamic> j, {@required this.branch}) {
    assert(branch != null);
    j.forEach((key, value) {
      final item = value as Map<String,dynamic>;
      if (item.keys.contains("serviceName")) {
        all.add(BusinessService.fromJson(item));
      } else if (item.keys.contains("categoryName")) {
        allCategories.add(BusinessServiceCategory.fromJson(item));
      }
    });
  }

  bool anyServiceDependsOn(BusinessServiceCategory category) {
    return all.any((s) =>
        s.category.value.categoryName.value == category.categoryName.value);
  }

  Future save({BusinessService service}) async {
    final oldImgs = service.images;
    final imgs = await uploadImagesToStorageAndReturnStringList(oldImgs);
    service.images.clear();
    service.images.addAll(imgs);


    all.removeWhere((element) => element.serviceName==service.serviceName);
    all.add(service);
    await branch.myDoc.value.update(
      {
        "businessServices": {
          service.serviceName.value: service.toMap(),
        },
      },
    );
  }

  Future removeService(BusinessService service) async {
    all.remove(service);
    await branch.myDoc.value.update(
        {"businessServices.${service.serviceName}": FieldValue.delete()});
  }

  Future addACategory({
    String categoryName,
    String description,
    Map<String, bool> images,
  }) async {
    final imgs = await uploadImagesToStorageAndReturnStringList(images);
    final category = BusinessServiceCategory.empty()
      ..categoryName.value = categoryName
      ..description.value = description
      ..images.clear()
      ..images.addAll(imgs);

    allCategories.add(category);
    await branch.myDoc.value.update({
      "businessServices": FieldValue.arrayUnion([category.toMap()])
    });
  }

  Future removeCategory(BusinessServiceCategory category) async {
    allCategories.remove(category);
    await branch.myDoc.value.update({
      "businessServices": FieldValue.arrayRemove([category.toMap()])
    });
  }

  Map<String,dynamic> toMap() {
    final map = <String, dynamic>{};
    all.forEach((element) {
      map.addAll({element.serviceName.value: element.toMap()});
    });
    allCategories.forEach((element) {
      map.addAll({element.categoryName.value: element.toMap()});
    });
    return map;
  }
}

class BusinessService {
  final serviceName = Observable<String>("");
  final price = Observable<double>(0.0);
  final duration = Observable<Duration>(Duration.zero);
  final description = Observable<String>("");
  final category = Observable<BusinessServiceCategory>(null);
  final images = ObservableMap<String, bool>();
  final enabled = Observable(true);

  BusinessService.empty();

  BusinessService.fromJson(Map<String, dynamic> j) {
    serviceName.value = j["serviceName"] ?? "";
    price.value = double.parse(j["price"]) ?? 0.0;
    duration.value = Duration(minutes: j["duration"] ?? 0);
    description.value = j["description"] ?? "";
    category.value = BusinessServiceCategory.fromJson(j["category"]);
    final tmp = Map.fromIterable(j["images"],
        key: (s) => s as String, value: (_) => true);
    images.addAll(tmp);
    enabled.value = j["enabled"] ?? true;
  }

  toMap() {
    return {
      "serviceName": serviceName.value,
      "price": price.value.toStringAsPrecision(2),
      "duration": duration.value.inMinutes,
      "description": description.value,
      "category": category.value?.toMap() ?? {},
      "images": images.keys.toList(),
      "enabled": enabled.value,
    };
  }

  @override
  int get hashCode => (serviceName.value +
          price.value.toString() +
          category.value.categoryName.value)
      .hashCode;

  @override
  bool operator ==(Object other) {
    if (other is BusinessService) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}

class BusinessServiceCategory {
  final categoryName = Observable<String>("");
  final description = Observable<String>("");
  final images = ObservableMap<String, bool>();

  BusinessServiceCategory.empty();

  BusinessServiceCategory.fromJson(Map<String, dynamic> j) {
    _fromJson(j);
  }

  _fromJson(Map<String, dynamic> j) {
    this.categoryName.value = j["categoryName"] ?? "";
    this.description.value = j["description"] ?? "";
    final tmp = Map.fromIterable(j["images"],
        key: (s) => s as String, value: (_) => true);
    this.images.addAll(tmp);
  }

  toMap() {
    return {
      "categoryName": categoryName.value,
      "description": description.value,
      "images": images.keys.toList(),
    };
  }
}
