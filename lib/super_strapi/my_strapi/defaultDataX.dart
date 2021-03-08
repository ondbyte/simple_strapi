import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'package:hive/hive.dart';
import 'package:simple_strapi/simple_strapi.dart';

import '../super_strapi.dart';

class DefaultDataX {
  static final i = DefaultDataX._x();

  DefaultDataX._x();

  DefaultData _defaultData;

  LazyBox hiveBox;

  Future<DefaultData> init() async {
    Hive.init(Directory.current.path);
    print(Directory.current.path);
    hiveBox = await Hive.openLazyBox("default_data");
    final info = DeviceInfoPlugin();
    final id = Platform.isLinux
        ? "xyz"
        : (Platform.isAndroid
            ? (await info.androidInfo).androidId
            : (await info.iosInfo).identifierForVendor);

    _defaultData = await () async {
      final data = Map.castFrom<dynamic, dynamic, String, dynamic>(
          await hiveBox.get(id));
      if (data is Map<String, dynamic>) {
        try {
          print(data);
          return DefaultData.fromMap(data);
        } catch (e) {
          print(e);
        }
      }
      return (await _getDefaultDataFromServer(id)) ??
          (await DefaultDatas.create(DefaultData.fresh(null, id)));
    }();
    if (_defaultData != null && _defaultData.synced) {
      hiveBox.put("$id", _defaultData?.toMap());
    }
    return _defaultData;
  }

  Future<DefaultData> _getDefaultDataFromServer(String id) async {
    final multiple = await DefaultDatas.findMultiple(
      query: StrapiQuery()
        ..where("deviceId", StrapiQueryOperation.equalTo, "$id"),
    );
    if (multiple != null && multiple.isNotEmpty) {
      return multiple.first;
    }
  }

  Future setLocality(Locality locality) async {
    _defaultData =
        await DefaultDatas.update(_defaultData.copyWIth(locality: locality));
  }

  Future saveValue(String key, value) async {
    await hiveBox.put(key, value);
  }

  Future getValue(String key, {defaultValue}) async {
    return await hiveBox.get(key, defaultValue: defaultValue);
  }
}
