
import 'package:mobx/mobx.dart';

part 'storage_store.g.dart';

class StorageStore = _StorageStore with _$StorageStore;

abstract class _StorageStore with Store {
  //Directory directory;
  //LazyBox box;
  //List<ReactionDisposer> _disposers = [];

  //@observable
  //FirstLaunch isFirstLaunch = FirstLaunch.unsure;

  @action
  Future init() async {
/*    _setupAutoRun();
    directory = await getApplicationSupportDirectory();
    Hive..init(directory.path);
    box = await Hive.openLazyBox("$kAppName");
    var launched = await box.get("launched", defaultValue: false);

    ///remove this
    launched = false;
    //////

    if (launched) {
      isFirstLaunch = FirstLaunch.no;
    } else {
      isFirstLaunch = FirstLaunch.yes;
    }*/
  }

  void _setupAutoRun() {
/*    ///write first launch
    _disposers.add(
      when(
            (_) => isFirstLaunch == FirstLaunch.yes,
            () async {
          await box.put("launched", true);
        },
      ),
    );*/
  }
}
