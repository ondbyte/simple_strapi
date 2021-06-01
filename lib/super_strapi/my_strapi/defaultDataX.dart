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

  Rx<DefaultData?> defaultData = Rx<DefaultData?>(null);

  late final StrapiObjectListener _updateListener;

  Future<DefaultData?> init() async {
    defaultData.value = await getDefaultDataFromServer();
    _updateListener = _listenForUpdate();
    return defaultData.value;
  }

  StrapiObjectListener _listenForUpdate() {
    final id = defaultData.value?.id;
    final data = defaultData.value?.toMap();
    if (id is String && data is Map) {
      return StrapiObjectListener(
        id: id,
        initailData: data as Map<String, dynamic>,
        listener: (map, losding) {
          final newDefaultData = DefaultData.fromSyncedMap(map);
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

    final response = await StrapiCollection.customEndpoint(
        collection: DefaultData.collectionName,
        endPoint: "customCreate",
        method: "POST",
        params: {
          "customId": "$id",
        });
    if (response.isNotEmpty) {
      final map = response[0];
      return DefaultData.fromSyncedMap(map);
    }
    throw BappImpossibleException(
      "this api should create or give already existing collection object, no other chances",
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

  @override
  Future dispose() async {
    _updateListener.stopListening();
    super.dispose();
  }
}
