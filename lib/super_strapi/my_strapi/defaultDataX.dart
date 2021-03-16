import 'dart:io';

import 'package:bapp/helpers/helper.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_strapi/simple_strapi.dart'
    hide DefaultData, Locality, City;

import '../super_strapi.dart';

class DefaultDataX {
  static final i = DefaultDataX._x();

  DefaultDataX._x();

  DefaultData defaultData;

  LazyBox hiveBox;

  bool isFirstTimeOnDevice = true;

  Future<DefaultData> init() async {
    final path = (isMobile)
        ? (await getApplicationSupportDirectory()).path
        : Directory.current.path;
    Hive.init(path);
    hiveBox = await Hive.openLazyBox("default_data");
    final info = DeviceInfoPlugin();
    final id = Platform.isLinux
        ? "xyz"
        : (Platform.isAndroid
            ? (await info.androidInfo).androidId
            : (await info.iosInfo).identifierForVendor);

    defaultData = await () async {
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
          (await DefaultDatas.create(DefaultData.fresh(null, id, null)));
    }();
    if (defaultData != null && defaultData.synced) {
      hiveBox.put("$id", defaultData?.toMap());
    }
    await _doOtherStorageStuffs();
    return defaultData;
  }

  Future _doOtherStorageStuffs() async {
    isFirstTimeOnDevice =
        await getValue("isFirstTimeOnDevice", defaultValue: true);
    if (isFirstTimeOnDevice) {
      await saveValue("isFirstTimeOnDevice", false);
    }
  }

  Future<DefaultData> _getDefaultDataFromServer(String id) async {
    final multiple = await StrapiCollectionQuery(
      collectionName: DefaultDatas.collectionName,
      limit: 1,
      requiredFields: DefaultData.fields(),
    );
  }

  Future setLocalityOrCity(Locality locality, City city) async {
    defaultData = await DefaultDatas.update(
      defaultData.copyWIth(
        locality: locality,
        city: city,
      ),
    );
  }

  Future saveValue(String key, value) async {
    await hiveBox.put(key, value);
  }

  Future getValue(String key, {defaultValue}) async {
    return await hiveBox.get(key, defaultValue: defaultValue);
  }
}
