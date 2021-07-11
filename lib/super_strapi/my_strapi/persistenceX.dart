import 'dart:io';

import 'package:bapp/helpers/helper.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'defaultDataX.dart';

class PersistenceX {
  static late PersistenceX i;
  PersistenceX._i();

  factory PersistenceX() {
    final i = PersistenceX._i();
    PersistenceX.i = i;
    return i;
  }

  late final LazyBox _hiveBox;

  Future init() async {
    final path = (isMobile)
        ? (await getApplicationSupportDirectory()).path
        : Directory.current.path;
    Hive.init(path);
    _hiveBox = await Hive.openLazyBox(StorageKeys.storageBox);
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

  Future clear() async {
    _hiveBox.deleteFromDisk();
  }

  Future wait50() async {
    await Future.delayed(Duration(milliseconds: 50));
  }
}

class StorageKeys {
  static String get isFirstTimeOnDevice => "isFirstTimeOnDevice20";
  static String get selectedBusinessId => "selectedBusinessId2";
  static String get selectedEmployeeId => "selectedEmployeeId2";
  static String get storageBox => "storageBox3";
}
