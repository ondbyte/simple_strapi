import 'dart:io';

import 'package:bapp/helpers/exceptions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_strapi/simple_strapi.dart'
    hide DefaultData, Locality, City;

import 'package:super_strapi_generated/super_strapi_generated.dart';

class DefaultDataX extends X {
  static final i = DefaultDataX._x();

  DefaultDataX._x();

  Rx<DefaultData> defaultData = Rx<DefaultData>();

  LazyBox? _hiveBox;

  bool isFirstTimeOnDevice = true;

  late final StrapiObjectListener _updateListener;

  Future<DefaultData?> init() async {
    final path = (isMobile)
        ? (await getApplicationSupportDirectory()).path
        : Directory.current.path;
    Hive.init(path);
    _hiveBox = await Hive.openLazyBox("default_data");

    defaultData.value = await () async {
      return (await getDefaultDataFromServer());
    }();
    if ((defaultData()?.synced ?? false)) {
      _hiveBox?.put(DefaultDataKeys.defaultdata, defaultData()?.toMap() ?? {});
    }
    await _doOtherStorageStuffs();
    _updateListener = _listenForUpdate();
    print(defaultData());
    return defaultData.value;
  }

  Future _doOtherStorageStuffs() async {
    isFirstTimeOnDevice =
        await getValue(DefaultDataKeys.isFirstTimeOnDevice, defaultValue: true);
    if (isFirstTimeOnDevice) {
      await saveValue(
        DefaultDataKeys.isFirstTimeOnDevice,
        false,
      );
    }
  }

  StrapiObjectListener _listenForUpdate() {
    final id = defaultData.value?.id;
    if (id is String) {
      return StrapiObjectListener(
        id: id,
        listener: (map) {
          final newDefaultData = DefaultData.fromSyncedMap(map);
          _hiveBox?.put(DefaultDataKeys.defaultdata, newDefaultData.toMap());
          defaultData(newDefaultData);
        },
      );
    } else {
      throw BappException(msg: "cannot listen for strapi object");
    }
  }

  Future<DefaultData?> getDefaultDataFromServer() async {
    final info = DeviceInfoPlugin();
    final id = Platform.isLinux
        ? "xyz"
        : (Platform.isAndroid
            ? (await info.androidInfo).androidId
            : (await info.iosInfo).identifierForVendor);
    final query = StrapiCollectionQuery(
      collectionName: DefaultDatas.collectionName,
      limit: 1,
      requiredFields: DefaultData.fields(),
    )
      ..whereField(
        field: DefaultData.fields.deviceId,
        query: StrapiFieldQuery.equalTo,
        value: "$id",
      )
      ..whereModelField(
        field: DefaultData.fields.city,
        query: StrapiModelQuery(
          requiredFields: City.fields(),
        ),
      )
      ..whereModelField(
        field: DefaultData.fields.locality,
        query: StrapiModelQuery(
          requiredFields: Locality.fields(),
        ),
      );

    final response = await DefaultDatas.executeQuery(query);
    if (response.isNotEmpty) {
      return response.first;
    } else {
      return DefaultDatas.create(
        DefaultData.fresh(deviceId: id),
      );
    }
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

  @override
  Future dispose() async {
    _updateListener.stopListening();
    super.dispose();
  }
}

class DefaultDataKeys {
  static String get lastBooking => "lastBooking";
  static String get defaultdata => "defaultdata1";
  static String get isFirstTimeOnDevice => "isFirstTimeOnDevice6";
}
