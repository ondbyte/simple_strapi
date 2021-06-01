import 'dart:io';

import 'package:bapp/helpers/helper.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'defaultDataX.dart';

class PersistenceX {
  static final i = PersistenceX._x();
  PersistenceX._x();

  late final LazyBox _hiveBox;

  bool isFirstTimeOnDevice = true;

  Future init() async {
    final path = (isMobile)
        ? (await getApplicationSupportDirectory()).path
        : Directory.current.path;
    Hive.init(path);
    _hiveBox = await Hive.openLazyBox("default_data");
    await _doOtherStorageStuffs();
  }

  Future _doOtherStorageStuffs() async {
    isFirstTimeOnDevice =
        await getValue(StorageKeys.isFirstTimeOnDevice, defaultValue: true);
    if (isFirstTimeOnDevice) {
      await saveValue(
        StorageKeys.isFirstTimeOnDevice,
        false,
      );
    }
  }

  Future saveValue(String key, value) async {
    if (_hiveBox is! LazyBox) {
      await wait50();
      return saveValue(key, value);
    }
    await _hiveBox.put(key, value);
  }

  Future getValue(String key, {defaultValue}) async {
    return await _hiveBox.get(key, defaultValue: defaultValue);
  }

  Future delete(String key, {defaultValue}) async {
    final value = await _hiveBox.get(key, defaultValue: defaultValue);
    await _hiveBox.delete(key);
    return value;
  }

  Future wait50() async {
    await Future.delayed(Duration(milliseconds: 50));
  }
}

class StorageKeys {
  static String get isFirstTimeOnDevice => "isFirstTimeOnDevice6";
  static String get selectedBusinessId => "selectedBusinessId2";
  static String get selectedEmployeeId => "selectedEmployeeId2";
}
