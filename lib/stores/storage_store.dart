import 'dart:io';

import 'package:bapp/helpers/constants.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';

part 'storage_store.g.dart';

class StorageStore = _StorageStore with _$StorageStore;

abstract class _StorageStore with Store {
  FirstLaunch isFirstLaunch = FirstLaunch.unsure;
  Directory directory;
  Box box;
  
  @observable
  bool loading = true;

  @action
  Future init() async {
    directory = await getApplicationSupportDirectory();
    Hive..init(directory.path);
    box = await Hive.openBox("$kAppName");
    var launched = box.get("launched",defaultValue: false);
    ///remove this
    launched = false;
    if(launched){
      isFirstLaunch = FirstLaunch.no;
    } else {
      isFirstLaunch = FirstLaunch.yes;
      await box.put("launched", true);
      ///persist
      await box.close();
      box = await Hive.openBox("$kAppName");
    }
  }
}

enum FirstLaunch{
  yes,
  no,
  unsure
}