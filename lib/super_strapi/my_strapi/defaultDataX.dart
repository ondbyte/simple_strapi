import 'dart:io';

import 'package:bapp/helpers/helper.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_strapi/simple_strapi.dart'
    hide DefaultData, Locality, City;

import 'package:super_strapi_generated/super_strapi_generated.dart';

class DefaultDataX {
  static final i = DefaultDataX._x();

  DefaultDataX._x();

  Rx<DefaultData> defaultData = Rx<DefaultData>();

  LazyBox? _hiveBox;

  bool isFirstTimeOnDevice = true;

  Future<DefaultData?> init() async {
    final path = (isMobile)
        ? (await getApplicationSupportDirectory()).path
        : Directory.current.path;
    Hive.init(path);
    _hiveBox = await Hive.openLazyBox("default_data");
    final info = DeviceInfoPlugin();
    final id = Platform.isLinux
        ? "xyz"
        : (Platform.isAndroid
            ? (await info.androidInfo).androidId
            : (await info.iosInfo).identifierForVendor);

    defaultData.value = await () async {
      final data = Map.castFrom<dynamic, dynamic, String, dynamic>(
          await _hiveBox?.get(id));
      if (data is Map<String, dynamic>) {
        try {
          print(data);
          return DefaultData.fromMap(data);
        } catch (e) {
          print(e);
        }
      }
      return (await _getDefaultDataFromServer(id)) ??
          (await DefaultDatas.create(DefaultData.fresh(deviceId: id)));
    }();
    if (defaultData != null && (defaultData()?.synced ?? false)) {
      _hiveBox?.put("$id", defaultData()?.toMap() ?? {});
    }
    await _doOtherStorageStuffs();
    return defaultData.value;
  }

  Future _doOtherStorageStuffs() async {
    isFirstTimeOnDevice =
        await getValue(DefaultDataKeys.isFirstTimeOnDevice, defaultValue: true);
    if (isFirstTimeOnDevice) {
      await saveValue(DefaultDataKeys.isFirstTimeOnDevice, false);
    }
  }

  Future<DefaultData?> _getDefaultDataFromServer(String id) async {
    final multiple = await StrapiCollectionQuery(
      collectionName: DefaultDatas.collectionName,
      limit: 1,
      requiredFields: DefaultData.fields(),
    );
  }

  Future setLocalityOrCity({Locality? locality, City? city}) async {
    final updated = defaultData()?.copyWIth(
      locality: locality,
      city: city,
    );
    if (updated is DefaultData) {
      defaultData.value = await DefaultDatas.update(updated);
    }
  }

  Future saveValue(String key, value) async {
    if (_hiveBox is! LazyBox) {
      await wait50();
      return saveValue(key, value);
    }
    await _hiveBox?.put(key, value);
  }

  Future getValue(String key, {defaultValue}) async {
    if (_hiveBox is! LazyBox) {
      await wait50();
      return getValue(key, defaultValue: defaultData);
    }
    return await _hiveBox?.get(key, defaultValue: defaultValue);
  }

  Future delete(String key, {defaultValue}) async {
    final value = await _hiveBox?.get(key, defaultValue: defaultValue);
    await _hiveBox?.delete(key);
    return value;
  }

  Future wait50() async {
    await Future.delayed(Duration(milliseconds: 50));
  }
}

class DefaultDataKeys {
  static String get lastBooking => "lastBooking";
  static String get isFirstTimeOnDevice => "isFirstTimeOnDevice6";
}
