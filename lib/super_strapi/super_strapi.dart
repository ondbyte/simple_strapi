import 'package:simple_strapi/simple_strapi.dart';

class City {
  City.fromID(this.id)
      : _synced = false,
        name = null,
        enabled = null,
        createdAt = null,
        updatedAt = null;

  City.fresh(this.name, this.enabled)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  City._synced(this.name, this.enabled, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  City._unsynced(
      this.name, this.enabled, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final bool? enabled;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  City copyWIth(String? name, bool? enabled) => City._unsynced(
      name ?? this.name,
      enabled ?? this.enabled,
      this.createdAt,
      this.updatedAt,
      this.id);
  Map<String, dynamic> toMap() => {"name": name, "enabled": enabled};
  static City fromSyncedMap(Map<String, dynamic> map) => City._synced(
      map["f.name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
  static City fromMap(Map<String, dynamic> map) => City._unsynced(
      map["f.name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
}

class Cities {
  static const collectionName = "cities";

  static List<City> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => City.fromID(id)).toList();
  }

  static Future<City?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return City.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<City>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => City.fromSyncedMap(map)).toList();
    }
  }

  static Future<City?> create(City city) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: city.toMap(),
    );
    if (map.isNotEmpty) {
      return City.fromSyncedMap(map);
    }
  }

  static Future<City?> update(City city) async {
    final id = city.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: city.toMap(),
      );
      if (map.isNotEmpty) {
        return City.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<City?> delete(City city) async {
    final id = city.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return City.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class Employee {
  Employee.fromID(this.id)
      : _synced = false,
        name = null,
        enabled = null,
        createdAt = null,
        updatedAt = null;

  Employee.fresh(this.name, this.enabled)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Employee._synced(
      this.name, this.enabled, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Employee._unsynced(
      this.name, this.enabled, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final bool? enabled;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  Employee copyWIth(String? name, bool? enabled) => Employee._unsynced(
      name ?? this.name,
      enabled ?? this.enabled,
      this.createdAt,
      this.updatedAt,
      this.id);
  Map<String, dynamic> toMap() => {"name": name, "enabled": enabled};
  static Employee fromSyncedMap(Map<String, dynamic> map) => Employee._synced(
      map["f.name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
  static Employee fromMap(Map<String, dynamic> map) => Employee._unsynced(
      map["f.name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
}

class Employees {
  static const collectionName = "employees";

  static List<Employee> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Employee.fromID(id)).toList();
  }

  static Future<Employee?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Employee.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Employee>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => Employee.fromSyncedMap(map)).toList();
    }
  }

  static Future<Employee?> create(Employee employee) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: employee.toMap(),
    );
    if (map.isNotEmpty) {
      return Employee.fromSyncedMap(map);
    }
  }

  static Future<Employee?> update(Employee employee) async {
    final id = employee.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: employee.toMap(),
      );
      if (map.isNotEmpty) {
        return Employee.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Employee?> delete(Employee employee) async {
    final id = employee.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Employee.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class Booking {
  Booking.fromID(this.id)
      : _synced = false,
        bookedOn = null,
        bookingStartTime = null,
        bookingEndTime = null,
        packages = null,
        products = null,
        createdAt = null,
        updatedAt = null;

  Booking.fresh(this.bookedOn, this.bookingStartTime, this.bookingEndTime,
      this.packages, this.products)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Booking._synced(this.bookedOn, this.bookingStartTime, this.bookingEndTime,
      this.packages, this.products, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Booking._unsynced(this.bookedOn, this.bookingStartTime, this.bookingEndTime,
      this.packages, this.products, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final DateTime? bookedOn;

  final DateTime? bookingStartTime;

  final DateTime? bookingEndTime;

  final List<Package>? packages;

  final List<MenuItem>? products;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  Booking copyWIth(
          DateTime? bookedOn,
          DateTime? bookingStartTime,
          DateTime? bookingEndTime,
          List<Package>? packages,
          List<MenuItem>? products) =>
      Booking._unsynced(
          bookedOn ?? this.bookedOn,
          bookingStartTime ?? this.bookingStartTime,
          bookingEndTime ?? this.bookingEndTime,
          packages ?? this.packages,
          products ?? this.products,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "bookedOn": bookedOn?.toIso8601String(),
        "bookingStartTime": bookingStartTime?.toIso8601String(),
        "bookingEndTime": bookingEndTime?.toIso8601String(),
        "packages": packages?.map((e) => e.toMap()),
        "products": products?.map((e) => e.toMap())
      };
  static Booking fromSyncedMap(Map<String, dynamic> map) => Booking._synced(
      StrapiUtils.parseDateTime(map["bookedOn"]),
      StrapiUtils.parseDateTime(map["bookingStartTime"]),
      StrapiUtils.parseDateTime(map["bookingEndTime"]),
      map["packages"].map((e) => Package.fromMap(e)).tiList(),
      map["products"].map((e) => MenuItem.fromMap(e)).tiList(),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
  static Booking fromMap(Map<String, dynamic> map) => Booking._unsynced(
      StrapiUtils.parseDateTime(map["bookedOn"]),
      StrapiUtils.parseDateTime(map["bookingStartTime"]),
      StrapiUtils.parseDateTime(map["bookingEndTime"]),
      map["packages"].map((e) => Package.fromMap(e)).tiList(),
      map["products"].map((e) => MenuItem.fromMap(e)).tiList(),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
}

class Bookings {
  static const collectionName = "bookings";

  static List<Booking> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Booking.fromID(id)).toList();
  }

  static Future<Booking?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Booking.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Booking>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => Booking.fromSyncedMap(map)).toList();
    }
  }

  static Future<Booking?> create(Booking booking) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: booking.toMap(),
    );
    if (map.isNotEmpty) {
      return Booking.fromSyncedMap(map);
    }
  }

  static Future<Booking?> update(Booking booking) async {
    final id = booking.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: booking.toMap(),
      );
      if (map.isNotEmpty) {
        return Booking.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Booking?> delete(Booking booking) async {
    final id = booking.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Booking.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class Locality {
  Locality.fromID(this.id)
      : _synced = false,
        name = null,
        enabled = null,
        coordinates = null,
        createdAt = null,
        updatedAt = null;

  Locality.fresh(this.name, this.enabled, this.coordinates)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Locality._synced(this.name, this.enabled, this.coordinates, this.createdAt,
      this.updatedAt, this.id)
      : _synced = true;

  Locality._unsynced(this.name, this.enabled, this.coordinates, this.createdAt,
      this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final bool? enabled;

  final Coordinates? coordinates;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  Locality copyWIth(String? name, bool? enabled, Coordinates? coordinates) =>
      Locality._unsynced(
          name ?? this.name,
          enabled ?? this.enabled,
          coordinates ?? this.coordinates,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() =>
      {"name": name, "enabled": enabled, "coordinates": coordinates?.toMap()};
  static Locality fromSyncedMap(Map<String, dynamic> map) => Locality._synced(
      map["f.name"],
      StrapiUtils.parseBool(map["enabled"]),
      Coordinates.fromMap(map["coordinates"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
  static Locality fromMap(Map<String, dynamic> map) => Locality._unsynced(
      map["f.name"],
      StrapiUtils.parseBool(map["enabled"]),
      Coordinates.fromMap(map["coordinates"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
}

class Localities {
  static const collectionName = "localities";

  static List<Locality> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Locality.fromID(id)).toList();
  }

  static Future<Locality?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Locality.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Locality>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => Locality.fromSyncedMap(map)).toList();
    }
  }

  static Future<Locality?> create(Locality locality) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: locality.toMap(),
    );
    if (map.isNotEmpty) {
      return Locality.fromSyncedMap(map);
    }
  }

  static Future<Locality?> update(Locality locality) async {
    final id = locality.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: locality.toMap(),
      );
      if (map.isNotEmpty) {
        return Locality.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Locality?> delete(Locality locality) async {
    final id = locality.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Locality.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class PushNotification {
  PushNotification.fromID(this.id)
      : _synced = false,
        pushed_on = null,
        createdAt = null,
        updatedAt = null;

  PushNotification.fresh(this.pushed_on)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  PushNotification._synced(
      this.pushed_on, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  PushNotification._unsynced(
      this.pushed_on, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final DateTime? pushed_on;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  PushNotification copyWIth(DateTime? pushed_on) => PushNotification._unsynced(
      pushed_on ?? this.pushed_on, this.createdAt, this.updatedAt, this.id);
  Map<String, dynamic> toMap() => {"pushed_on": pushed_on?.toIso8601String()};
  static PushNotification fromSyncedMap(Map<String, dynamic> map) =>
      PushNotification._synced(
          StrapiUtils.parseDateTime(map["pushed_on"]),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["f.name"]);
  static PushNotification fromMap(Map<String, dynamic> map) =>
      PushNotification._unsynced(
          StrapiUtils.parseDateTime(map["pushed_on"]),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["f.name"]);
}

class PushNotifications {
  static const collectionName = "pushnotifications";

  static List<PushNotification> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => PushNotification.fromID(id)).toList();
  }

  static Future<PushNotification?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return PushNotification.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<PushNotification>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => PushNotification.fromSyncedMap(map)).toList();
    }
  }

  static Future<PushNotification?> create(
      PushNotification pushNotification) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: pushNotification.toMap(),
    );
    if (map.isNotEmpty) {
      return PushNotification.fromSyncedMap(map);
    }
  }

  static Future<PushNotification?> update(
      PushNotification pushNotification) async {
    final id = pushNotification.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: pushNotification.toMap(),
      );
      if (map.isNotEmpty) {
        return PushNotification.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<PushNotification?> delete(
      PushNotification pushNotification) async {
    final id = pushNotification.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return PushNotification.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class Country {
  Country.fromID(this.id)
      : _synced = false,
        name = null,
        iso2Code = null,
        englishCurrencySymbol = null,
        flagUrl = null,
        enabled = null,
        localCurrencySymbol = null,
        localName = null,
        createdAt = null,
        updatedAt = null;

  Country.fresh(this.name, this.iso2Code, this.englishCurrencySymbol,
      this.flagUrl, this.enabled, this.localCurrencySymbol, this.localName)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Country._synced(
      this.name,
      this.iso2Code,
      this.englishCurrencySymbol,
      this.flagUrl,
      this.enabled,
      this.localCurrencySymbol,
      this.localName,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  Country._unsynced(
      this.name,
      this.iso2Code,
      this.englishCurrencySymbol,
      this.flagUrl,
      this.enabled,
      this.localCurrencySymbol,
      this.localName,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final String? iso2Code;

  final String? englishCurrencySymbol;

  final String? flagUrl;

  final bool? enabled;

  final String? localCurrencySymbol;

  final String? localName;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  Country copyWIth(
          String? name,
          String? iso2Code,
          String? englishCurrencySymbol,
          String? flagUrl,
          bool? enabled,
          String? localCurrencySymbol,
          String? localName) =>
      Country._unsynced(
          name ?? this.name,
          iso2Code ?? this.iso2Code,
          englishCurrencySymbol ?? this.englishCurrencySymbol,
          flagUrl ?? this.flagUrl,
          enabled ?? this.enabled,
          localCurrencySymbol ?? this.localCurrencySymbol,
          localName ?? this.localName,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "name": name,
        "iso2Code": iso2Code,
        "englishCurrencySymbol": englishCurrencySymbol,
        "flagUrl": flagUrl,
        "enabled": enabled,
        "localCurrencySymbol": localCurrencySymbol,
        "localName": localName
      };
  static Country fromSyncedMap(Map<String, dynamic> map) => Country._synced(
      map["f.name"],
      map["f.name"],
      map["f.name"],
      map["f.name"],
      StrapiUtils.parseBool(map["enabled"]),
      map["f.name"],
      map["f.name"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
  static Country fromMap(Map<String, dynamic> map) => Country._unsynced(
      map["f.name"],
      map["f.name"],
      map["f.name"],
      map["f.name"],
      StrapiUtils.parseBool(map["enabled"]),
      map["f.name"],
      map["f.name"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
}

class Countries {
  static const collectionName = "countries";

  static List<Country> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Country.fromID(id)).toList();
  }

  static Future<Country?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Country.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Country>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => Country.fromSyncedMap(map)).toList();
    }
  }

  static Future<Country?> create(Country country) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: country.toMap(),
    );
    if (map.isNotEmpty) {
      return Country.fromSyncedMap(map);
    }
  }

  static Future<Country?> update(Country country) async {
    final id = country.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: country.toMap(),
      );
      if (map.isNotEmpty) {
        return Country.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Country?> delete(Country country) async {
    final id = country.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Country.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class Business {
  Business.fromID(this.id)
      : _synced = false,
        name = null,
        address = null,
        enabled = null,
        catalogue = null,
        packages = null,
        createdAt = null,
        updatedAt = null;

  Business.fresh(
      this.name, this.address, this.enabled, this.catalogue, this.packages)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Business._synced(this.name, this.address, this.enabled, this.catalogue,
      this.packages, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Business._unsynced(this.name, this.address, this.enabled, this.catalogue,
      this.packages, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final Address? address;

  final bool? enabled;

  final List<MenuCategories>? catalogue;

  final List<Package>? packages;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  Business copyWIth(String? name, Address? address, bool? enabled,
          List<MenuCategories>? catalogue, List<Package>? packages) =>
      Business._unsynced(
          name ?? this.name,
          address ?? this.address,
          enabled ?? this.enabled,
          catalogue ?? this.catalogue,
          packages ?? this.packages,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "name": name,
        "address": address?.toMap(),
        "enabled": enabled,
        "catalogue": catalogue?.map((e) => e.toMap()),
        "packages": packages?.map((e) => e.toMap())
      };
  static Business fromSyncedMap(Map<String, dynamic> map) => Business._synced(
      map["f.name"],
      Address.fromMap(map["address"]),
      StrapiUtils.parseBool(map["enabled"]),
      map["catalogue"].map((e) => MenuCategories.fromMap(e)).tiList(),
      map["packages"].map((e) => Package.fromMap(e)).tiList(),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
  static Business fromMap(Map<String, dynamic> map) => Business._unsynced(
      map["f.name"],
      Address.fromMap(map["address"]),
      StrapiUtils.parseBool(map["enabled"]),
      map["catalogue"].map((e) => MenuCategories.fromMap(e)).tiList(),
      map["packages"].map((e) => Package.fromMap(e)).tiList(),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
}

class Businesses {
  static const collectionName = "businesses";

  static List<Business> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Business.fromID(id)).toList();
  }

  static Future<Business?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Business.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Business>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => Business.fromSyncedMap(map)).toList();
    }
  }

  static Future<Business?> create(Business business) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: business.toMap(),
    );
    if (map.isNotEmpty) {
      return Business.fromSyncedMap(map);
    }
  }

  static Future<Business?> update(Business business) async {
    final id = business.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: business.toMap(),
      );
      if (map.isNotEmpty) {
        return Business.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Business?> delete(Business business) async {
    final id = business.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Business.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class Partner {
  Partner.fromID(this.id)
      : _synced = false,
        name = null,
        enabled = null,
        createdAt = null,
        updatedAt = null;

  Partner.fresh(this.name, this.enabled)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Partner._synced(
      this.name, this.enabled, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Partner._unsynced(
      this.name, this.enabled, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final bool? enabled;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  Partner copyWIth(String? name, bool? enabled) => Partner._unsynced(
      name ?? this.name,
      enabled ?? this.enabled,
      this.createdAt,
      this.updatedAt,
      this.id);
  Map<String, dynamic> toMap() => {"name": name, "enabled": enabled};
  static Partner fromSyncedMap(Map<String, dynamic> map) => Partner._synced(
      map["f.name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
  static Partner fromMap(Map<String, dynamic> map) => Partner._unsynced(
      map["f.name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
}

class Partners {
  static const collectionName = "partners";

  static List<Partner> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Partner.fromID(id)).toList();
  }

  static Future<Partner?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Partner.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Partner>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => Partner.fromSyncedMap(map)).toList();
    }
  }

  static Future<Partner?> create(Partner partner) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: partner.toMap(),
    );
    if (map.isNotEmpty) {
      return Partner.fromSyncedMap(map);
    }
  }

  static Future<Partner?> update(Partner partner) async {
    final id = partner.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: partner.toMap(),
      );
      if (map.isNotEmpty) {
        return Partner.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Partner?> delete(Partner partner) async {
    final id = partner.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Partner.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class BusinessFeature {
  BusinessFeature.fromID(this.id)
      : _synced = false,
        startDate = null,
        endDate = null,
        createdAt = null,
        updatedAt = null;

  BusinessFeature.fresh(this.startDate, this.endDate)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  BusinessFeature._synced(
      this.startDate, this.endDate, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  BusinessFeature._unsynced(
      this.startDate, this.endDate, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final DateTime? startDate;

  final DateTime? endDate;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  BusinessFeature copyWIth(DateTime? startDate, DateTime? endDate) =>
      BusinessFeature._unsynced(startDate ?? this.startDate,
          endDate ?? this.endDate, this.createdAt, this.updatedAt, this.id);
  Map<String, dynamic> toMap() => {
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String()
      };
  static BusinessFeature fromSyncedMap(Map<String, dynamic> map) =>
      BusinessFeature._synced(
          StrapiUtils.parseDateTime(map["startDate"]),
          StrapiUtils.parseDateTime(map["endDate"]),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["f.name"]);
  static BusinessFeature fromMap(Map<String, dynamic> map) =>
      BusinessFeature._unsynced(
          StrapiUtils.parseDateTime(map["startDate"]),
          StrapiUtils.parseDateTime(map["endDate"]),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["f.name"]);
}

class BusinessFeatures {
  static const collectionName = "businessfeatures";

  static List<BusinessFeature> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => BusinessFeature.fromID(id)).toList();
  }

  static Future<BusinessFeature?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return BusinessFeature.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<BusinessFeature>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => BusinessFeature.fromSyncedMap(map)).toList();
    }
  }

  static Future<BusinessFeature?> create(
      BusinessFeature businessFeature) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: businessFeature.toMap(),
    );
    if (map.isNotEmpty) {
      return BusinessFeature.fromSyncedMap(map);
    }
  }

  static Future<BusinessFeature?> update(
      BusinessFeature businessFeature) async {
    final id = businessFeature.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: businessFeature.toMap(),
      );
      if (map.isNotEmpty) {
        return BusinessFeature.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<BusinessFeature?> delete(
      BusinessFeature businessFeature) async {
    final id = businessFeature.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return BusinessFeature.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class Role {
  Role.fromID(this.id)
      : _synced = false,
        name = null,
        description = null,
        type = null,
        createdAt = null,
        updatedAt = null;

  Role.fresh(this.name, this.description, this.type)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Role._synced(this.name, this.description, this.type, this.createdAt,
      this.updatedAt, this.id)
      : _synced = true;

  Role._unsynced(this.name, this.description, this.type, this.createdAt,
      this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String? name;

  final String? description;

  final String? type;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  Role copyWIth(String? name, String? description, String? type) =>
      Role._unsynced(name ?? this.name, description ?? this.description,
          type ?? this.type, this.createdAt, this.updatedAt, this.id);
  Map<String, dynamic> toMap() =>
      {"name": name, "description": description, "type": type};
  static Role fromSyncedMap(Map<String, dynamic> map) => Role._synced(
      map["f.name"],
      map["f.name"],
      map["f.name"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
  static Role fromMap(Map<String, dynamic> map) => Role._unsynced(
      map["f.name"],
      map["f.name"],
      map["f.name"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
}

class Roles {
  static const collectionName = "roles";

  static List<Role> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Role.fromID(id)).toList();
  }

  static Future<Role?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Role.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Role>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => Role.fromSyncedMap(map)).toList();
    }
  }

  static Future<Role?> create(Role role) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: role.toMap(),
    );
    if (map.isNotEmpty) {
      return Role.fromSyncedMap(map);
    }
  }

  static Future<Role?> update(Role role) async {
    final id = role.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: role.toMap(),
      );
      if (map.isNotEmpty) {
        return Role.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Role?> delete(Role role) async {
    final id = role.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Role.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class User {
  User.fromID(this.id)
      : _synced = false,
        username = null,
        email = null,
        provider = null,
        resetPasswordToken = null,
        confirmationToken = null,
        confirmed = null,
        blocked = null,
        favourites = null,
        name = null,
        createdAt = null,
        updatedAt = null;

  User.fresh(
      this.username,
      this.email,
      this.provider,
      this.resetPasswordToken,
      this.confirmationToken,
      this.confirmed,
      this.blocked,
      this.favourites,
      this.name)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  User._synced(
      this.username,
      this.email,
      this.provider,
      this.resetPasswordToken,
      this.confirmationToken,
      this.confirmed,
      this.blocked,
      this.favourites,
      this.name,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  User._unsynced(
      this.username,
      this.email,
      this.provider,
      this.resetPasswordToken,
      this.confirmationToken,
      this.confirmed,
      this.blocked,
      this.favourites,
      this.name,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String? username;

  final String? email;

  final String? provider;

  final String? resetPasswordToken;

  final String? confirmationToken;

  final bool? confirmed;

  final bool? blocked;

  final List<Favourites>? favourites;

  final String? name;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final String? id;

  bool get synced => _synced;
  User copyWIth(
          String? username,
          String? email,
          String? provider,
          String? resetPasswordToken,
          String? confirmationToken,
          bool? confirmed,
          bool? blocked,
          List<Favourites>? favourites,
          String? name) =>
      User._unsynced(
          username ?? this.username,
          email ?? this.email,
          provider ?? this.provider,
          resetPasswordToken ?? this.resetPasswordToken,
          confirmationToken ?? this.confirmationToken,
          confirmed ?? this.confirmed,
          blocked ?? this.blocked,
          favourites ?? this.favourites,
          name ?? this.name,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "username": username,
        "email": email,
        "provider": provider,
        "resetPasswordToken": resetPasswordToken,
        "confirmationToken": confirmationToken,
        "confirmed": confirmed,
        "blocked": blocked,
        "favourites": favourites?.map((e) => e.toMap()),
        "name": name
      };
  static User fromSyncedMap(Map<String, dynamic> map) => User._synced(
      map["f.name"],
      map["f.name"],
      map["f.name"],
      map["f.name"],
      map["f.name"],
      StrapiUtils.parseBool(map["confirmed"]),
      StrapiUtils.parseBool(map["blocked"]),
      map["favourites"].map((e) => Favourites.fromMap(e)).tiList(),
      map["f.name"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
  static User fromMap(Map<String, dynamic> map) => User._unsynced(
      map["f.name"],
      map["f.name"],
      map["f.name"],
      map["f.name"],
      map["f.name"],
      StrapiUtils.parseBool(map["confirmed"]),
      StrapiUtils.parseBool(map["blocked"]),
      map["favourites"].map((e) => Favourites.fromMap(e)).tiList(),
      map["f.name"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["f.name"]);
}

class Users {
  static const collectionName = "users";

  static List<User> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => User.fromID(id)).toList();
  }

  static Future<User?> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return User.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<User>?> findMultiple({int limit = 8}) async {
    final list =
        await StrapiCollection.findMultiple(collection: collectionName);
    if (list.isNotEmpty) {
      return list.map((map) => User.fromSyncedMap(map)).toList();
    }
  }

  static Future<User?> create(User user) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: user.toMap(),
    );
    if (map.isNotEmpty) {
      return User.fromSyncedMap(map);
    }
  }

  static Future<User?> update(User user) async {
    final id = user.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: user.toMap(),
      );
      if (map.isNotEmpty) {
        return User.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<User?> delete(User user) async {
    final id = user.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return User.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }
}

class MenuCategories {
  MenuCategories._unsynced(
      this.name, this.enabled, this.description, this.catalogueItems);

  final String? name;

  final bool? enabled;

  final String? description;

  final List<MenuItem>? catalogueItems;

  Map<String, dynamic> toMap() => {
        "name": name,
        "enabled": enabled,
        "description": description,
        "catalogueItems": catalogueItems?.map((e) => e.toMap())
      };
  static MenuCategories fromMap(Map<String, dynamic> map) =>
      MenuCategories._unsynced(
          map["f.name"],
          StrapiUtils.parseBool(map["enabled"]),
          map["f.name"],
          map["catalogueItems"].map((e) => MenuItem.fromMap(e)).tiList());
}

class Address {
  Address._unsynced(this.address, this.coordinates);

  final String? address;

  final Coordinates? coordinates;

  Map<String, dynamic> toMap() =>
      {"address": address, "coordinates": coordinates?.toMap()};
  static Address fromMap(Map<String, dynamic> map) =>
      Address._unsynced(map["f.name"], Coordinates.fromMap(map["coordinates"]));
}

class Package {
  Package._unsynced(this.name, this.products, this.startDate, this.endDate,
      this.enabled, this.priceBefore, this.priceAfter);

  final String? name;

  final List<MenuItem>? products;

  final DateTime? startDate;

  final DateTime? endDate;

  final bool? enabled;

  final double? priceBefore;

  final double? priceAfter;

  Map<String, dynamic> toMap() => {
        "name": name,
        "products": products?.map((e) => e.toMap()),
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "enabled": enabled,
        "priceBefore": priceBefore,
        "priceAfter": priceAfter
      };
  static Package fromMap(Map<String, dynamic> map) => Package._unsynced(
      map["f.name"],
      map["products"].map((e) => MenuItem.fromMap(e)).tiList(),
      StrapiUtils.parseDateTime(map["startDate"]),
      StrapiUtils.parseDateTime(map["endDate"]),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.parseDouble(map["priceBefore"]),
      StrapiUtils.parseDouble(map["priceAfter"]));
}

class MenuItem {
  MenuItem._unsynced(this.price, this.duration, this.enabled, this.nameOverride,
      this.descriptionOverride);

  final double? price;

  final int? duration;

  final bool? enabled;

  final String? nameOverride;

  final String? descriptionOverride;

  Map<String, dynamic> toMap() => {
        "price": price,
        "duration": duration,
        "enabled": enabled,
        "nameOverride": nameOverride,
        "descriptionOverride": descriptionOverride
      };
  static MenuItem fromMap(Map<String, dynamic> map) => MenuItem._unsynced(
      StrapiUtils.parseDouble(map["price"]),
      StrapiUtils.parseInt(map["duration"]),
      StrapiUtils.parseBool(map["enabled"]),
      map["f.name"],
      map["f.name"]);
}

class Favourites {
  Favourites._unsynced(this.addedOn);

  final DateTime? addedOn;

  Map<String, dynamic> toMap() => {"addedOn": addedOn?.toIso8601String()};
  static Favourites fromMap(Map<String, dynamic> map) =>
      Favourites._unsynced(StrapiUtils.parseDateTime(map["addedOn"]));
}

class Coordinates {
  Coordinates._unsynced(this.latitude, this.longitude);

  final double? latitude;

  final double? longitude;

  Map<String, dynamic> toMap() =>
      {"latitude": latitude, "longitude": longitude};
  static Coordinates fromMap(Map<String, dynamic> map) => Coordinates._unsynced(
      StrapiUtils.parseDouble(map["latitude"]),
      StrapiUtils.parseDouble(map["longitude"]));
}

class Demo {
  Demo._unsynced(this.b);

  final bool? b;

  Map<String, dynamic> toMap() => {"b": b};
  static Demo fromMap(Map<String, dynamic> map) =>
      Demo._unsynced(StrapiUtils.parseBool(map["b"]));
}
