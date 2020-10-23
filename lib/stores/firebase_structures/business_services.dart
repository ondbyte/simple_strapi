import 'package:bapp/config/config.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/stores/firebase_structures/business_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';

class BusinessServices {
  final CollectionReference myCollec;
  final all = ObservableList<BusinessService>();
  final allCategories = ObservableList<BusinessServiceCategory>();

  BusinessServices({this.myCollec}) {
    _getServices(myCollec);
  }

  Future _getServices(CollectionReference myCollec) async {
    final snaps = await myCollec.get();
    if (snaps.docs.isNotEmpty) {
      snaps.docs.toList().forEach(
        (snap) {
          final data = snap.data();
          if (data.containsKey("serviceName")) {
            all.add(BusinessService.fromJson(
                myDoc: snap.reference, j: data["serviceName"]));
          } else if (data.containsKey("categoryName")) {
            allCategories.add(
              BusinessServiceCategory.fromJson(
                myDoc: snap.reference,
                j: data["categoryName"],
              ),
            );
          }
        },
      );
    }
  }

  Future addAServices({
    String serviceName,
    double price,
    Duration duration,
    String description,
    BusinessServiceCategory category,
    Map<String, bool> images,
  }) async {
    final image =
        (await uploadImagesToStorageAndReturnStringList(images)).first;
    final service = BusinessService(myDoc: myCollec.doc(kUUIDGen.v1()))
      ..category.value = category
      ..serviceName.value = serviceName
      ..price.value = price
      ..duration.value = duration
      ..image.value = image;

    all.add(service);
    await service.saveService();
  }

  Future removeService(BusinessService service) async {
    all.remove(service);
    await service.delete();
  }
}

class BusinessService {
  final serviceName = Observable<String>("");
  final price = Observable<double>(0.0);
  final duration = Observable<Duration>(Duration.zero);
  final description = Observable<String>("");
  final category = Observable<BusinessServiceCategory>(null);
  final image = Observable<String>("");
  final DocumentReference myDoc;

  BusinessService({this.myDoc});

  BusinessService.fromJson({this.myDoc, Map<String, dynamic> j}) {
    serviceName.value = j["serviceName"];
    price.value = j["price"];
    duration.value = Duration(milliseconds: j["duration"]);
    description.value = j["description"];
    category.value = BusinessServiceCategory(myDoc: j["category"]);
    image.value = j["image"];
  }

  Future saveService() async {
    await myDoc.set(toMap());
  }

  Future delete() async {
    await myDoc.delete();
  }

  toMap() {
    return {
      "name": serviceName.value,
      "price": price.value,
      "duration": duration.value.inMilliseconds,
      "description": description.value,
      "category": category.value,
      "image": image.value,
    };
  }
}

class BusinessServiceCategory {
  final name = Observable<String>("");
  final description = Observable<String>("");
  final image = Observable<String>("");
  final DocumentReference myDoc;

  BusinessServiceCategory({this.myDoc});

  BusinessServiceCategory.fromJson({this.myDoc, Map<String, dynamic> j}) {
    this.name.value = j["name"];
    this.description.value = j["description"];
    this.image.value = j["image"];
  }

  Future saveServiceCategory() async {
    await myDoc.set(toMap());
  }

  toMap() {
    return {
      "name": name.value,
      "description": description.value,
      "image": image.value,
      "myDoc": myDoc
    };
  }
}
