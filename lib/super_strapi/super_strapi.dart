import 'package:simple_strapi/simple_strapi.dart';
import 'dart:convert';

class City {
  City.fromID(this.id)
      : _synced = false,
        name = null,
        enabled = null,
        country = null,
        localities = null,
        createdAt = null,
        updatedAt = null;

  City.fresh(this.name, this.enabled, this.country, this.localities)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  City._synced(this.name, this.enabled, this.country, this.localities,
      this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  City._unsynced(this.name, this.enabled, this.country, this.localities,
      this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String name;

  final bool enabled;

  final Country country;

  final List<Locality> localities;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  City copyWIth(
          {String name,
          bool enabled,
          Country country,
          List<Locality> localities}) =>
      City._unsynced(
          name ?? this.name,
          enabled ?? this.enabled,
          country ?? this.country,
          localities ?? this.localities,
          this.createdAt,
          this.updatedAt,
          this.id);
  City setNull(
          {bool name = false,
          bool enabled = false,
          bool country = false,
          bool localities = false}) =>
      City._unsynced(
          name ? null : this.name,
          enabled ? null : this.enabled,
          country ? null : this.country,
          localities ? null : this.localities,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "name": name,
        "enabled": enabled,
        "country": country?.toMap(),
        "localities": localities?.map((e) => e.toMap()),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static City fromSyncedMap(Map<String, dynamic> map) => City._synced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<Country>(
          map["country"], (e) => Countries.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Locality>(
          map["localities"], (e) => Localities.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static City fromMap(Map<String, dynamic> map) => City._unsynced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<Country>(
          map["country"], (e) => Countries.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Locality>(
          map["localities"], (e) => Localities.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class Cities {
  static const collectionName = "cities";

  static List<City> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => City.fromID(id)).toList();
  }

  static Future<City> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return City.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<City>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => City.fromSyncedMap(map)).toList();
    }
  }

  static Future<City> create(City city) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: city.toMap(),
    );
    if (map.isNotEmpty) {
      return City.fromSyncedMap(map);
    }
  }

  static Future<City> update(City city) async {
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

  static Future<City> delete(City city) async {
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

  static List<City> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => City.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => City.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static City fromIDorData(idOrData) {
    if (idOrData is String) {
      return City.fromID(idOrData);
    }
    if (idOrData is Map) {
      return City.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<City>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => City.fromSyncedMap(map)).toList();
    }
  }
}

class Employee {
  Employee.fromID(this.id)
      : _synced = false,
        name = null,
        image = null,
        enabled = null,
        user = null,
        bookings = null,
        businesses = null,
        createdAt = null,
        updatedAt = null;

  Employee.fresh(this.name, this.image, this.enabled, this.user, this.bookings,
      this.businesses)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Employee._synced(this.name, this.image, this.enabled, this.user,
      this.bookings, this.businesses, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Employee._unsynced(this.name, this.image, this.enabled, this.user,
      this.bookings, this.businesses, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String name;

  final List<StrapiFile> image;

  final bool enabled;

  final User user;

  final List<Booking> bookings;

  final List<Business> businesses;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  Employee copyWIth(
          {String name,
          List<StrapiFile> image,
          bool enabled,
          User user,
          List<Booking> bookings,
          List<Business> businesses}) =>
      Employee._unsynced(
          name ?? this.name,
          image ?? this.image,
          enabled ?? this.enabled,
          user ?? this.user,
          bookings ?? this.bookings,
          businesses ?? this.businesses,
          this.createdAt,
          this.updatedAt,
          this.id);
  Employee setNull(
          {bool name = false,
          bool image = false,
          bool enabled = false,
          bool user = false,
          bool bookings = false,
          bool businesses = false}) =>
      Employee._unsynced(
          name ? null : this.name,
          image ? null : this.image,
          enabled ? null : this.enabled,
          user ? null : this.user,
          bookings ? null : this.bookings,
          businesses ? null : this.businesses,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "name": name,
        "image": image?.map((e) => e.toMap()),
        "enabled": enabled,
        "user": user?.toMap(),
        "bookings": bookings?.map((e) => e.toMap()),
        "businesses": businesses?.map((e) => e.toMap()),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static Employee fromSyncedMap(Map<String, dynamic> map) => Employee._synced(
      map["name"],
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["image"], (e) => StrapiFiles.fromIDorData(e)),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<User>(map["user"], (e) => Users.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Business>(
          map["businesses"], (e) => Businesses.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Employee fromMap(Map<String, dynamic> map) => Employee._unsynced(
      map["name"],
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["image"], (e) => StrapiFiles.fromIDorData(e)),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<User>(map["user"], (e) => Users.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Business>(
          map["businesses"], (e) => Businesses.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class Employees {
  static const collectionName = "employees";

  static List<Employee> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Employee.fromID(id)).toList();
  }

  static Future<Employee> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Employee.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Employee>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Employee.fromSyncedMap(map)).toList();
    }
  }

  static Future<Employee> create(Employee employee) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: employee.toMap(),
    );
    if (map.isNotEmpty) {
      return Employee.fromSyncedMap(map);
    }
  }

  static Future<Employee> update(Employee employee) async {
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

  static Future<Employee> delete(Employee employee) async {
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

  static List<Employee> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => Employee.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => Employee.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static Employee fromIDorData(idOrData) {
    if (idOrData is String) {
      return Employee.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Employee.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Employee>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Employee.fromSyncedMap(map)).toList();
    }
  }
}

class Booking {
  Booking.fromID(this.id)
      : _synced = false,
        business = null,
        bookedOn = null,
        bookingStartTime = null,
        bookingEndTime = null,
        packages = null,
        products = null,
        employee = null,
        user = null,
        createdAt = null,
        updatedAt = null;

  Booking.fresh(
      this.business,
      this.bookedOn,
      this.bookingStartTime,
      this.bookingEndTime,
      this.packages,
      this.products,
      this.employee,
      this.user)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Booking._synced(
      this.business,
      this.bookedOn,
      this.bookingStartTime,
      this.bookingEndTime,
      this.packages,
      this.products,
      this.employee,
      this.user,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  Booking._unsynced(
      this.business,
      this.bookedOn,
      this.bookingStartTime,
      this.bookingEndTime,
      this.packages,
      this.products,
      this.employee,
      this.user,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final Business business;

  final DateTime bookedOn;

  final DateTime bookingStartTime;

  final DateTime bookingEndTime;

  final List<Package> packages;

  final List<MenuItem> products;

  final Employee employee;

  final User user;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  Booking copyWIth(
          {Business business,
          DateTime bookedOn,
          DateTime bookingStartTime,
          DateTime bookingEndTime,
          List<Package> packages,
          List<MenuItem> products,
          Employee employee,
          User user}) =>
      Booking._unsynced(
          business ?? this.business,
          bookedOn ?? this.bookedOn,
          bookingStartTime ?? this.bookingStartTime,
          bookingEndTime ?? this.bookingEndTime,
          packages ?? this.packages,
          products ?? this.products,
          employee ?? this.employee,
          user ?? this.user,
          this.createdAt,
          this.updatedAt,
          this.id);
  Booking setNull(
          {bool business = false,
          bool bookedOn = false,
          bool bookingStartTime = false,
          bool bookingEndTime = false,
          bool packages = false,
          bool products = false,
          bool employee = false,
          bool user = false}) =>
      Booking._unsynced(
          business ? null : this.business,
          bookedOn ? null : this.bookedOn,
          bookingStartTime ? null : this.bookingStartTime,
          bookingEndTime ? null : this.bookingEndTime,
          packages ? null : this.packages,
          products ? null : this.products,
          employee ? null : this.employee,
          user ? null : this.user,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "business": business?.toMap(),
        "bookedOn": bookedOn?.toIso8601String(),
        "bookingStartTime": bookingStartTime?.toIso8601String(),
        "bookingEndTime": bookingEndTime?.toIso8601String(),
        "packages": packages?.map((e) => e.toMap()),
        "products": products?.map((e) => e.toMap()),
        "employee": employee?.toMap(),
        "user": user?.toMap(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static Booking fromSyncedMap(Map<String, dynamic> map) => Booking._synced(
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["bookedOn"]),
      StrapiUtils.parseDateTime(map["bookingStartTime"]),
      StrapiUtils.parseDateTime(map["bookingEndTime"]),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<MenuItem>(
          map["products"], (e) => MenuItem.fromMap(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees.fromIDorData(e)),
      StrapiUtils.objFromMap<User>(map["user"], (e) => Users.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Booking fromMap(Map<String, dynamic> map) => Booking._unsynced(
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["bookedOn"]),
      StrapiUtils.parseDateTime(map["bookingStartTime"]),
      StrapiUtils.parseDateTime(map["bookingEndTime"]),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<MenuItem>(
          map["products"], (e) => MenuItem.fromMap(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees.fromIDorData(e)),
      StrapiUtils.objFromMap<User>(map["user"], (e) => Users.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class Bookings {
  static const collectionName = "bookings";

  static List<Booking> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Booking.fromID(id)).toList();
  }

  static Future<Booking> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Booking.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Booking>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Booking.fromSyncedMap(map)).toList();
    }
  }

  static Future<Booking> create(Booking booking) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: booking.toMap(),
    );
    if (map.isNotEmpty) {
      return Booking.fromSyncedMap(map);
    }
  }

  static Future<Booking> update(Booking booking) async {
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

  static Future<Booking> delete(Booking booking) async {
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

  static List<Booking> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => Booking.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => Booking.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static Booking fromIDorData(idOrData) {
    if (idOrData is String) {
      return Booking.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Booking.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Booking>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Booking.fromSyncedMap(map)).toList();
    }
  }
}

class Locality {
  Locality.fromID(this.id)
      : _synced = false,
        name = null,
        enabled = null,
        city = null,
        coordinates = null,
        createdAt = null,
        updatedAt = null;

  Locality.fresh(this.name, this.enabled, this.city, this.coordinates)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Locality._synced(this.name, this.enabled, this.city, this.coordinates,
      this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Locality._unsynced(this.name, this.enabled, this.city, this.coordinates,
      this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String name;

  final bool enabled;

  final City city;

  final Coordinates coordinates;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  Locality copyWIth(
          {String name, bool enabled, City city, Coordinates coordinates}) =>
      Locality._unsynced(
          name ?? this.name,
          enabled ?? this.enabled,
          city ?? this.city,
          coordinates ?? this.coordinates,
          this.createdAt,
          this.updatedAt,
          this.id);
  Locality setNull(
          {bool name = false,
          bool enabled = false,
          bool city = false,
          bool coordinates = false}) =>
      Locality._unsynced(
          name ? null : this.name,
          enabled ? null : this.enabled,
          city ? null : this.city,
          coordinates ? null : this.coordinates,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "name": name,
        "enabled": enabled,
        "city": city?.toMap(),
        "coordinates": coordinates?.toMap(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static Locality fromSyncedMap(Map<String, dynamic> map) => Locality._synced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities.fromIDorData(e)),
      StrapiUtils.objFromMap<Coordinates>(
          map["coordinates"], (e) => Coordinates.fromMap(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Locality fromMap(Map<String, dynamic> map) => Locality._unsynced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities.fromIDorData(e)),
      StrapiUtils.objFromMap<Coordinates>(
          map["coordinates"], (e) => Coordinates.fromMap(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class Localities {
  static const collectionName = "localities";

  static List<Locality> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Locality.fromID(id)).toList();
  }

  static Future<Locality> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Locality.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Locality>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Locality.fromSyncedMap(map)).toList();
    }
  }

  static Future<Locality> create(Locality locality) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: locality.toMap(),
    );
    if (map.isNotEmpty) {
      return Locality.fromSyncedMap(map);
    }
  }

  static Future<Locality> update(Locality locality) async {
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

  static Future<Locality> delete(Locality locality) async {
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

  static List<Locality> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => Locality.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => Locality.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static Locality fromIDorData(idOrData) {
    if (idOrData is String) {
      return Locality.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Locality.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Locality>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Locality.fromSyncedMap(map)).toList();
    }
  }
}

class PushNotification {
  PushNotification.fromID(this.id)
      : _synced = false,
        pushed_on = null,
        user = null,
        createdAt = null,
        updatedAt = null;

  PushNotification.fresh(this.pushed_on, this.user)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  PushNotification._synced(
      this.pushed_on, this.user, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  PushNotification._unsynced(
      this.pushed_on, this.user, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final DateTime pushed_on;

  final User user;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  PushNotification copyWIth({DateTime pushed_on, User user}) =>
      PushNotification._unsynced(pushed_on ?? this.pushed_on, user ?? this.user,
          this.createdAt, this.updatedAt, this.id);
  PushNotification setNull({bool pushed_on = false, bool user = false}) =>
      PushNotification._unsynced(pushed_on ? null : this.pushed_on,
          user ? null : this.user, this.createdAt, this.updatedAt, this.id);
  Map<String, dynamic> toMap() => {
        "pushed_on": pushed_on?.toIso8601String(),
        "user": user?.toMap(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static PushNotification fromSyncedMap(Map<String, dynamic> map) =>
      PushNotification._synced(
          StrapiUtils.parseDateTime(map["pushed_on"]),
          StrapiUtils.objFromMap<User>(
              map["user"], (e) => Users.fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static PushNotification fromMap(Map<String, dynamic> map) =>
      PushNotification._unsynced(
          StrapiUtils.parseDateTime(map["pushed_on"]),
          StrapiUtils.objFromMap<User>(
              map["user"], (e) => Users.fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  @override
  String toString() => toMap().toString();
}

class PushNotifications {
  static const collectionName = "push-notifications";

  static List<PushNotification> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => PushNotification.fromID(id)).toList();
  }

  static Future<PushNotification> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return PushNotification.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<PushNotification>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => PushNotification.fromSyncedMap(map)).toList();
    }
  }

  static Future<PushNotification> create(
      PushNotification pushNotification) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: pushNotification.toMap(),
    );
    if (map.isNotEmpty) {
      return PushNotification.fromSyncedMap(map);
    }
  }

  static Future<PushNotification> update(
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

  static Future<PushNotification> delete(
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

  static List<PushNotification> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => PushNotification.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => PushNotification.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static PushNotification fromIDorData(idOrData) {
    if (idOrData is String) {
      return PushNotification.fromID(idOrData);
    }
    if (idOrData is Map) {
      return PushNotification.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<PushNotification>> getForListOfIDs(
      List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => PushNotification.fromSyncedMap(map)).toList();
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
        cities = null,
        createdAt = null,
        updatedAt = null;

  Country.fresh(
      this.name,
      this.iso2Code,
      this.englishCurrencySymbol,
      this.flagUrl,
      this.enabled,
      this.localCurrencySymbol,
      this.localName,
      this.cities)
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
      this.cities,
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
      this.cities,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String name;

  final String iso2Code;

  final String englishCurrencySymbol;

  final String flagUrl;

  final bool enabled;

  final String localCurrencySymbol;

  final String localName;

  final List<City> cities;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  Country copyWIth(
          {String name,
          String iso2Code,
          String englishCurrencySymbol,
          String flagUrl,
          bool enabled,
          String localCurrencySymbol,
          String localName,
          List<City> cities}) =>
      Country._unsynced(
          name ?? this.name,
          iso2Code ?? this.iso2Code,
          englishCurrencySymbol ?? this.englishCurrencySymbol,
          flagUrl ?? this.flagUrl,
          enabled ?? this.enabled,
          localCurrencySymbol ?? this.localCurrencySymbol,
          localName ?? this.localName,
          cities ?? this.cities,
          this.createdAt,
          this.updatedAt,
          this.id);
  Country setNull(
          {bool name = false,
          bool iso2Code = false,
          bool englishCurrencySymbol = false,
          bool flagUrl = false,
          bool enabled = false,
          bool localCurrencySymbol = false,
          bool localName = false,
          bool cities = false}) =>
      Country._unsynced(
          name ? null : this.name,
          iso2Code ? null : this.iso2Code,
          englishCurrencySymbol ? null : this.englishCurrencySymbol,
          flagUrl ? null : this.flagUrl,
          enabled ? null : this.enabled,
          localCurrencySymbol ? null : this.localCurrencySymbol,
          localName ? null : this.localName,
          cities ? null : this.cities,
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
        "localName": localName,
        "cities": cities?.map((e) => e.toMap()),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static Country fromSyncedMap(Map<String, dynamic> map) => Country._synced(
      map["name"],
      map["iso2Code"],
      map["englishCurrencySymbol"],
      map["flagUrl"],
      StrapiUtils.parseBool(map["enabled"]),
      map["localCurrencySymbol"],
      map["localName"],
      StrapiUtils.objFromListOfMap<City>(
          map["cities"], (e) => Cities.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Country fromMap(Map<String, dynamic> map) => Country._unsynced(
      map["name"],
      map["iso2Code"],
      map["englishCurrencySymbol"],
      map["flagUrl"],
      StrapiUtils.parseBool(map["enabled"]),
      map["localCurrencySymbol"],
      map["localName"],
      StrapiUtils.objFromListOfMap<City>(
          map["cities"], (e) => Cities.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class Countries {
  static const collectionName = "countries";

  static List<Country> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Country.fromID(id)).toList();
  }

  static Future<Country> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Country.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Country>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Country.fromSyncedMap(map)).toList();
    }
  }

  static Future<Country> create(Country country) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: country.toMap(),
    );
    if (map.isNotEmpty) {
      return Country.fromSyncedMap(map);
    }
  }

  static Future<Country> update(Country country) async {
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

  static Future<Country> delete(Country country) async {
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

  static List<Country> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => Country.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => Country.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static Country fromIDorData(idOrData) {
    if (idOrData is String) {
      return Country.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Country.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Country>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Country.fromSyncedMap(map)).toList();
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
        partner = null,
        packages = null,
        bookings = null,
        employees = null,
        businessFeatures = null,
        createdAt = null,
        updatedAt = null;

  Business.fresh(
      this.name,
      this.address,
      this.enabled,
      this.catalogue,
      this.partner,
      this.packages,
      this.bookings,
      this.employees,
      this.businessFeatures)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Business._synced(
      this.name,
      this.address,
      this.enabled,
      this.catalogue,
      this.partner,
      this.packages,
      this.bookings,
      this.employees,
      this.businessFeatures,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  Business._unsynced(
      this.name,
      this.address,
      this.enabled,
      this.catalogue,
      this.partner,
      this.packages,
      this.bookings,
      this.employees,
      this.businessFeatures,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String name;

  final Address address;

  final bool enabled;

  final List<MenuCategories> catalogue;

  final Partner partner;

  final List<Package> packages;

  final List<Booking> bookings;

  final List<Employee> employees;

  final List<BusinessFeature> businessFeatures;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  Business copyWIth(
          {String name,
          Address address,
          bool enabled,
          List<MenuCategories> catalogue,
          Partner partner,
          List<Package> packages,
          List<Booking> bookings,
          List<Employee> employees,
          List<BusinessFeature> businessFeatures}) =>
      Business._unsynced(
          name ?? this.name,
          address ?? this.address,
          enabled ?? this.enabled,
          catalogue ?? this.catalogue,
          partner ?? this.partner,
          packages ?? this.packages,
          bookings ?? this.bookings,
          employees ?? this.employees,
          businessFeatures ?? this.businessFeatures,
          this.createdAt,
          this.updatedAt,
          this.id);
  Business setNull(
          {bool name = false,
          bool address = false,
          bool enabled = false,
          bool catalogue = false,
          bool partner = false,
          bool packages = false,
          bool bookings = false,
          bool employees = false,
          bool businessFeatures = false}) =>
      Business._unsynced(
          name ? null : this.name,
          address ? null : this.address,
          enabled ? null : this.enabled,
          catalogue ? null : this.catalogue,
          partner ? null : this.partner,
          packages ? null : this.packages,
          bookings ? null : this.bookings,
          employees ? null : this.employees,
          businessFeatures ? null : this.businessFeatures,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "name": name,
        "address": address?.toMap(),
        "enabled": enabled,
        "catalogue": catalogue?.map((e) => e.toMap()),
        "partner": partner?.toMap(),
        "packages": packages?.map((e) => e.toMap()),
        "bookings": bookings?.map((e) => e.toMap()),
        "employees": employees?.map((e) => e.toMap()),
        "businessFeatures": businessFeatures?.map((e) => e.toMap()),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static Business fromSyncedMap(Map<String, dynamic> map) => Business._synced(
      map["name"],
      StrapiUtils.objFromMap<Address>(
          map["address"], (e) => Address.fromMap(e)),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromListOfMap<MenuCategories>(
          map["catalogue"], (e) => MenuCategories.fromMap(e)),
      StrapiUtils.objFromMap<Partner>(
          map["partner"], (e) => Partners.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Employee>(
          map["employees"], (e) => Employees.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<BusinessFeature>(
          map["businessFeatures"], (e) => BusinessFeatures.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Business fromMap(Map<String, dynamic> map) => Business._unsynced(
      map["name"],
      StrapiUtils.objFromMap<Address>(
          map["address"], (e) => Address.fromMap(e)),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromListOfMap<MenuCategories>(
          map["catalogue"], (e) => MenuCategories.fromMap(e)),
      StrapiUtils.objFromMap<Partner>(
          map["partner"], (e) => Partners.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Employee>(
          map["employees"], (e) => Employees.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<BusinessFeature>(
          map["businessFeatures"], (e) => BusinessFeatures.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class Businesses {
  static const collectionName = "businesses";

  static List<Business> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Business.fromID(id)).toList();
  }

  static Future<Business> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Business.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Business>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Business.fromSyncedMap(map)).toList();
    }
  }

  static Future<Business> create(Business business) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: business.toMap(),
    );
    if (map.isNotEmpty) {
      return Business.fromSyncedMap(map);
    }
  }

  static Future<Business> update(Business business) async {
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

  static Future<Business> delete(Business business) async {
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

  static List<Business> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => Business.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => Business.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static Business fromIDorData(idOrData) {
    if (idOrData is String) {
      return Business.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Business.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Business>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Business.fromSyncedMap(map)).toList();
    }
  }
}

class Partner {
  Partner.fromID(this.id)
      : _synced = false,
        name = null,
        enabled = null,
        logo = null,
        businesses = null,
        owner = null,
        createdAt = null,
        updatedAt = null;

  Partner.fresh(this.name, this.enabled, this.logo, this.businesses, this.owner)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Partner._synced(this.name, this.enabled, this.logo, this.businesses,
      this.owner, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Partner._unsynced(this.name, this.enabled, this.logo, this.businesses,
      this.owner, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String name;

  final bool enabled;

  final List<StrapiFile> logo;

  final List<Business> businesses;

  final User owner;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  Partner copyWIth(
          {String name,
          bool enabled,
          List<StrapiFile> logo,
          List<Business> businesses,
          User owner}) =>
      Partner._unsynced(
          name ?? this.name,
          enabled ?? this.enabled,
          logo ?? this.logo,
          businesses ?? this.businesses,
          owner ?? this.owner,
          this.createdAt,
          this.updatedAt,
          this.id);
  Partner setNull(
          {bool name = false,
          bool enabled = false,
          bool logo = false,
          bool businesses = false,
          bool owner = false}) =>
      Partner._unsynced(
          name ? null : this.name,
          enabled ? null : this.enabled,
          logo ? null : this.logo,
          businesses ? null : this.businesses,
          owner ? null : this.owner,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "name": name,
        "enabled": enabled,
        "logo": logo?.map((e) => e.toMap()),
        "businesses": businesses?.map((e) => e.toMap()),
        "owner": owner?.toMap(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static Partner fromSyncedMap(Map<String, dynamic> map) => Partner._synced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["logo"], (e) => StrapiFiles.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Business>(
          map["businesses"], (e) => Businesses.fromIDorData(e)),
      StrapiUtils.objFromMap<User>(map["owner"], (e) => Users.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Partner fromMap(Map<String, dynamic> map) => Partner._unsynced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["logo"], (e) => StrapiFiles.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Business>(
          map["businesses"], (e) => Businesses.fromIDorData(e)),
      StrapiUtils.objFromMap<User>(map["owner"], (e) => Users.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class Partners {
  static const collectionName = "partners";

  static List<Partner> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Partner.fromID(id)).toList();
  }

  static Future<Partner> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Partner.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Partner>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Partner.fromSyncedMap(map)).toList();
    }
  }

  static Future<Partner> create(Partner partner) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: partner.toMap(),
    );
    if (map.isNotEmpty) {
      return Partner.fromSyncedMap(map);
    }
  }

  static Future<Partner> update(Partner partner) async {
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

  static Future<Partner> delete(Partner partner) async {
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

  static List<Partner> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => Partner.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => Partner.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static Partner fromIDorData(idOrData) {
    if (idOrData is String) {
      return Partner.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Partner.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Partner>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Partner.fromSyncedMap(map)).toList();
    }
  }
}

class DefaultData {
  DefaultData.fromID(this.id)
      : _synced = false,
        locality = null,
        deviceId = null,
        createdAt = null,
        updatedAt = null;

  DefaultData.fresh(this.locality, this.deviceId)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  DefaultData._synced(
      this.locality, this.deviceId, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  DefaultData._unsynced(
      this.locality, this.deviceId, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final Locality locality;

  final String deviceId;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  DefaultData copyWIth({Locality locality, String deviceId}) =>
      DefaultData._unsynced(locality ?? this.locality,
          deviceId ?? this.deviceId, this.createdAt, this.updatedAt, this.id);
  DefaultData setNull({bool locality = false, bool deviceId = false}) =>
      DefaultData._unsynced(
          locality ? null : this.locality,
          deviceId ? null : this.deviceId,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "locality": locality?.toMap(),
        "deviceId": deviceId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static DefaultData fromSyncedMap(
          Map<String, dynamic> map) =>
      DefaultData._synced(
          StrapiUtils.objFromMap<Locality>(
              map["locality"], (e) => Localities.fromIDorData(e)),
          map["deviceId"],
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static DefaultData fromMap(Map<String, dynamic> map) => DefaultData._unsynced(
      StrapiUtils.objFromMap<Locality>(
          map["locality"], (e) => Localities.fromIDorData(e)),
      map["deviceId"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class DefaultDatas {
  static const collectionName = "default-data";

  static List<DefaultData> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => DefaultData.fromID(id)).toList();
  }

  static Future<DefaultData> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return DefaultData.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<DefaultData>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => DefaultData.fromSyncedMap(map)).toList();
    }
  }

  static Future<DefaultData> create(DefaultData defaultData) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: defaultData.toMap(),
    );
    if (map.isNotEmpty) {
      return DefaultData.fromSyncedMap(map);
    }
  }

  static Future<DefaultData> update(DefaultData defaultData) async {
    final id = defaultData.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: defaultData.toMap(),
      );
      if (map.isNotEmpty) {
        return DefaultData.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<DefaultData> delete(DefaultData defaultData) async {
    final id = defaultData.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return DefaultData.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static List<DefaultData> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => DefaultData.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => DefaultData.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static DefaultData fromIDorData(idOrData) {
    if (idOrData is String) {
      return DefaultData.fromID(idOrData);
    }
    if (idOrData is Map) {
      return DefaultData.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<DefaultData>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => DefaultData.fromSyncedMap(map)).toList();
    }
  }
}

class BusinessFeature {
  BusinessFeature.fromID(this.id)
      : _synced = false,
        startDate = null,
        endDate = null,
        business = null,
        createdAt = null,
        updatedAt = null;

  BusinessFeature.fresh(this.startDate, this.endDate, this.business)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  BusinessFeature._synced(this.startDate, this.endDate, this.business,
      this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  BusinessFeature._unsynced(this.startDate, this.endDate, this.business,
      this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final DateTime startDate;

  final DateTime endDate;

  final Business business;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  BusinessFeature copyWIth(
          {DateTime startDate, DateTime endDate, Business business}) =>
      BusinessFeature._unsynced(
          startDate ?? this.startDate,
          endDate ?? this.endDate,
          business ?? this.business,
          this.createdAt,
          this.updatedAt,
          this.id);
  BusinessFeature setNull(
          {bool startDate = false,
          bool endDate = false,
          bool business = false}) =>
      BusinessFeature._unsynced(
          startDate ? null : this.startDate,
          endDate ? null : this.endDate,
          business ? null : this.business,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "business": business?.toMap(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static BusinessFeature fromSyncedMap(Map<String, dynamic> map) =>
      BusinessFeature._synced(
          StrapiUtils.parseDateTime(map["startDate"]),
          StrapiUtils.parseDateTime(map["endDate"]),
          StrapiUtils.objFromMap<Business>(
              map["business"], (e) => Businesses.fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static BusinessFeature fromMap(Map<String, dynamic> map) =>
      BusinessFeature._unsynced(
          StrapiUtils.parseDateTime(map["startDate"]),
          StrapiUtils.parseDateTime(map["endDate"]),
          StrapiUtils.objFromMap<Business>(
              map["business"], (e) => Businesses.fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  @override
  String toString() => toMap().toString();
}

class BusinessFeatures {
  static const collectionName = "business-features";

  static List<BusinessFeature> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => BusinessFeature.fromID(id)).toList();
  }

  static Future<BusinessFeature> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return BusinessFeature.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<BusinessFeature>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => BusinessFeature.fromSyncedMap(map)).toList();
    }
  }

  static Future<BusinessFeature> create(BusinessFeature businessFeature) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: businessFeature.toMap(),
    );
    if (map.isNotEmpty) {
      return BusinessFeature.fromSyncedMap(map);
    }
  }

  static Future<BusinessFeature> update(BusinessFeature businessFeature) async {
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

  static Future<BusinessFeature> delete(BusinessFeature businessFeature) async {
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

  static List<BusinessFeature> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => BusinessFeature.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => BusinessFeature.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static BusinessFeature fromIDorData(idOrData) {
    if (idOrData is String) {
      return BusinessFeature.fromID(idOrData);
    }
    if (idOrData is Map) {
      return BusinessFeature.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<BusinessFeature>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => BusinessFeature.fromSyncedMap(map)).toList();
    }
  }
}

class Role {
  Role.fromID(this.id)
      : _synced = false,
        name = null,
        description = null,
        type = null,
        permissions = null,
        users = null,
        createdAt = null,
        updatedAt = null;

  Role.fresh(
      this.name, this.description, this.type, this.permissions, this.users)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Role._synced(this.name, this.description, this.type, this.permissions,
      this.users, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Role._unsynced(this.name, this.description, this.type, this.permissions,
      this.users, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String name;

  final String description;

  final String type;

  final List<Permission> permissions;

  final List<User> users;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  Role copyWIth(
          {String name,
          String description,
          String type,
          List<Permission> permissions,
          List<User> users}) =>
      Role._unsynced(
          name ?? this.name,
          description ?? this.description,
          type ?? this.type,
          permissions ?? this.permissions,
          users ?? this.users,
          this.createdAt,
          this.updatedAt,
          this.id);
  Role setNull(
          {bool name = false,
          bool description = false,
          bool type = false,
          bool permissions = false,
          bool users = false}) =>
      Role._unsynced(
          name ? null : this.name,
          description ? null : this.description,
          type ? null : this.type,
          permissions ? null : this.permissions,
          users ? null : this.users,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "name": name,
        "description": description,
        "type": type,
        "permissions": permissions?.map((e) => e.toMap()),
        "users": users?.map((e) => e.toMap()),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static Role fromSyncedMap(Map<String, dynamic> map) => Role._synced(
      map["name"],
      map["description"],
      map["type"],
      StrapiUtils.objFromListOfMap<Permission>(
          map["permissions"], (e) => Permissions.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<User>(
          map["users"], (e) => Users.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Role fromMap(Map<String, dynamic> map) => Role._unsynced(
      map["name"],
      map["description"],
      map["type"],
      StrapiUtils.objFromListOfMap<Permission>(
          map["permissions"], (e) => Permissions.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<User>(
          map["users"], (e) => Users.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class Roles {
  static const collectionName = "Roles";

  static List<Role> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Role.fromID(id)).toList();
  }

  static Future<Role> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Role.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Role>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Role.fromSyncedMap(map)).toList();
    }
  }

  static Future<Role> create(Role role) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: role.toMap(),
    );
    if (map.isNotEmpty) {
      return Role.fromSyncedMap(map);
    }
  }

  static Future<Role> update(Role role) async {
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

  static Future<Role> delete(Role role) async {
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

  static List<Role> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => Role.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => Role.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static Role fromIDorData(idOrData) {
    if (idOrData is String) {
      return Role.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Role.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Role>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Role.fromSyncedMap(map)).toList();
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
        role = null,
        favourites = null,
        name = null,
        pushNotifications = null,
        employee = null,
        bookings = null,
        partner = null,
        locality = null,
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
      this.role,
      this.favourites,
      this.name,
      this.pushNotifications,
      this.employee,
      this.bookings,
      this.partner,
      this.locality)
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
      this.role,
      this.favourites,
      this.name,
      this.pushNotifications,
      this.employee,
      this.bookings,
      this.partner,
      this.locality,
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
      this.role,
      this.favourites,
      this.name,
      this.pushNotifications,
      this.employee,
      this.bookings,
      this.partner,
      this.locality,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String username;

  final String email;

  final String provider;

  final String resetPasswordToken;

  final String confirmationToken;

  final bool confirmed;

  final bool blocked;

  final Role role;

  final List<Favourites> favourites;

  final String name;

  final List<PushNotification> pushNotifications;

  final Employee employee;

  final List<Booking> bookings;

  final Partner partner;

  final Locality locality;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  User copyWIth(
          {String username,
          String email,
          String provider,
          String resetPasswordToken,
          String confirmationToken,
          bool confirmed,
          bool blocked,
          Role role,
          List<Favourites> favourites,
          String name,
          List<PushNotification> pushNotifications,
          Employee employee,
          List<Booking> bookings,
          Partner partner,
          Locality locality}) =>
      User._unsynced(
          username ?? this.username,
          email ?? this.email,
          provider ?? this.provider,
          resetPasswordToken ?? this.resetPasswordToken,
          confirmationToken ?? this.confirmationToken,
          confirmed ?? this.confirmed,
          blocked ?? this.blocked,
          role ?? this.role,
          favourites ?? this.favourites,
          name ?? this.name,
          pushNotifications ?? this.pushNotifications,
          employee ?? this.employee,
          bookings ?? this.bookings,
          partner ?? this.partner,
          locality ?? this.locality,
          this.createdAt,
          this.updatedAt,
          this.id);
  User setNull(
          {bool username = false,
          bool email = false,
          bool provider = false,
          bool resetPasswordToken = false,
          bool confirmationToken = false,
          bool confirmed = false,
          bool blocked = false,
          bool role = false,
          bool favourites = false,
          bool name = false,
          bool pushNotifications = false,
          bool employee = false,
          bool bookings = false,
          bool partner = false,
          bool locality = false}) =>
      User._unsynced(
          username ? null : this.username,
          email ? null : this.email,
          provider ? null : this.provider,
          resetPasswordToken ? null : this.resetPasswordToken,
          confirmationToken ? null : this.confirmationToken,
          confirmed ? null : this.confirmed,
          blocked ? null : this.blocked,
          role ? null : this.role,
          favourites ? null : this.favourites,
          name ? null : this.name,
          pushNotifications ? null : this.pushNotifications,
          employee ? null : this.employee,
          bookings ? null : this.bookings,
          partner ? null : this.partner,
          locality ? null : this.locality,
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
        "role": role?.toMap(),
        "favourites": favourites?.map((e) => e.toMap()),
        "name": name,
        "pushNotifications": pushNotifications?.map((e) => e.toMap()),
        "employee": employee?.toMap(),
        "bookings": bookings?.map((e) => e.toMap()),
        "partner": partner?.toMap(),
        "locality": locality?.toMap(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static User fromSyncedMap(Map<String, dynamic> map) => User._synced(
      map["username"],
      map["email"],
      map["provider"],
      map["resetPasswordToken"],
      map["confirmationToken"],
      StrapiUtils.parseBool(map["confirmed"]),
      StrapiUtils.parseBool(map["blocked"]),
      StrapiUtils.objFromMap<Role>(map["role"], (e) => Roles.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Favourites>(
          map["favourites"], (e) => Favourites.fromMap(e)),
      map["name"],
      StrapiUtils.objFromListOfMap<PushNotification>(
          map["pushNotifications"], (e) => PushNotifications.fromIDorData(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings.fromIDorData(e)),
      StrapiUtils.objFromMap<Partner>(
          map["partner"], (e) => Partners.fromIDorData(e)),
      StrapiUtils.objFromMap<Locality>(
          map["locality"], (e) => Localities.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static User fromMap(Map<String, dynamic> map) => User._unsynced(
      map["username"],
      map["email"],
      map["provider"],
      map["resetPasswordToken"],
      map["confirmationToken"],
      StrapiUtils.parseBool(map["confirmed"]),
      StrapiUtils.parseBool(map["blocked"]),
      StrapiUtils.objFromMap<Role>(map["role"], (e) => Roles.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Favourites>(
          map["favourites"], (e) => Favourites.fromMap(e)),
      map["name"],
      StrapiUtils.objFromListOfMap<PushNotification>(
          map["pushNotifications"], (e) => PushNotifications.fromIDorData(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees.fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings.fromIDorData(e)),
      StrapiUtils.objFromMap<Partner>(
          map["partner"], (e) => Partners.fromIDorData(e)),
      StrapiUtils.objFromMap<Locality>(
          map["locality"], (e) => Localities.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class Users {
  static const collectionName = "Users";

  static List<User> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => User.fromID(id)).toList();
  }

  static Future<User> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return User.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<User>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => User.fromSyncedMap(map)).toList();
    }
  }

  static Future<User> create(User user) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: user.toMap(),
    );
    if (map.isNotEmpty) {
      return User.fromSyncedMap(map);
    }
  }

  static Future<User> update(User user) async {
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

  static Future<User> delete(User user) async {
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

  static List<User> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => User.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => User.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static User fromIDorData(idOrData) {
    if (idOrData is String) {
      return User.fromID(idOrData);
    }
    if (idOrData is Map) {
      return User.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<User>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => User.fromSyncedMap(map)).toList();
    }
  }

  static Future<User> me() async {
    if (Strapi.i.strapiToken.isEmpty) {
      throw Exception(
          "cannot get users/me endpoint without token, please authenticate first");
    }
    final response = await StrapiCollection.customEndpoint(
        collection: "users", endPoint: "me");
    if (response is Map) {
      return User.fromSyncedMap(response);
    } else if (response is List && response.isNotEmpty) {
      return User.fromSyncedMap(response.first);
    } else {
      throw Exception("wrong response from users/me endpoint");
    }
  }
}

class Permission {
  Permission.fromID(this.id)
      : _synced = false,
        type = null,
        controller = null,
        action = null,
        enabled = null,
        policy = null,
        role = null,
        createdAt = null,
        updatedAt = null;

  Permission.fresh(this.type, this.controller, this.action, this.enabled,
      this.policy, this.role)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  Permission._synced(this.type, this.controller, this.action, this.enabled,
      this.policy, this.role, this.createdAt, this.updatedAt, this.id)
      : _synced = true;

  Permission._unsynced(this.type, this.controller, this.action, this.enabled,
      this.policy, this.role, this.createdAt, this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final String type;

  final String controller;

  final String action;

  final bool enabled;

  final String policy;

  final Role role;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  Permission copyWIth(
          {String type,
          String controller,
          String action,
          bool enabled,
          String policy,
          Role role}) =>
      Permission._unsynced(
          type ?? this.type,
          controller ?? this.controller,
          action ?? this.action,
          enabled ?? this.enabled,
          policy ?? this.policy,
          role ?? this.role,
          this.createdAt,
          this.updatedAt,
          this.id);
  Permission setNull(
          {bool type = false,
          bool controller = false,
          bool action = false,
          bool enabled = false,
          bool policy = false,
          bool role = false}) =>
      Permission._unsynced(
          type ? null : this.type,
          controller ? null : this.controller,
          action ? null : this.action,
          enabled ? null : this.enabled,
          policy ? null : this.policy,
          role ? null : this.role,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "type": type,
        "controller": controller,
        "action": action,
        "enabled": enabled,
        "policy": policy,
        "role": role?.toMap(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static Permission fromSyncedMap(
          Map<String, dynamic> map) =>
      Permission._synced(
          map["type"],
          map["controller"],
          map["action"],
          StrapiUtils.parseBool(map["enabled"]),
          map["policy"],
          StrapiUtils.objFromMap<Role>(
              map["role"], (e) => Roles.fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static Permission fromMap(Map<String, dynamic> map) => Permission._unsynced(
      map["type"],
      map["controller"],
      map["action"],
      StrapiUtils.parseBool(map["enabled"]),
      map["policy"],
      StrapiUtils.objFromMap<Role>(map["role"], (e) => Roles.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class Permissions {
  static const collectionName = "Permissions";

  static List<Permission> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => Permission.fromID(id)).toList();
  }

  static Future<Permission> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return Permission.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<Permission>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Permission.fromSyncedMap(map)).toList();
    }
  }

  static Future<Permission> create(Permission permission) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: permission.toMap(),
    );
    if (map.isNotEmpty) {
      return Permission.fromSyncedMap(map);
    }
  }

  static Future<Permission> update(Permission permission) async {
    final id = permission.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: permission.toMap(),
      );
      if (map.isNotEmpty) {
        return Permission.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<Permission> delete(Permission permission) async {
    final id = permission.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return Permission.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static List<Permission> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => Permission.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => Permission.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static Permission fromIDorData(idOrData) {
    if (idOrData is String) {
      return Permission.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Permission.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Permission>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => Permission.fromSyncedMap(map)).toList();
    }
  }
}

class StrapiFile {
  StrapiFile.fromID(this.id)
      : _synced = false,
        name = null,
        alternativeText = null,
        caption = null,
        width = null,
        height = null,
        formats = null,
        hash = null,
        ext = null,
        mime = null,
        size = null,
        url = null,
        previewUrl = null,
        provider = null,
        provider_metadata = null,
        related = null,
        createdAt = null,
        updatedAt = null;

  StrapiFile.fresh(
      this.name,
      this.alternativeText,
      this.caption,
      this.width,
      this.height,
      this.formats,
      this.hash,
      this.ext,
      this.mime,
      this.size,
      this.url,
      this.previewUrl,
      this.provider,
      this.provider_metadata,
      this.related)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  StrapiFile._synced(
      this.name,
      this.alternativeText,
      this.caption,
      this.width,
      this.height,
      this.formats,
      this.hash,
      this.ext,
      this.mime,
      this.size,
      this.url,
      this.previewUrl,
      this.provider,
      this.provider_metadata,
      this.related,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = true;

  StrapiFile._unsynced(
      this.name,
      this.alternativeText,
      this.caption,
      this.width,
      this.height,
      this.formats,
      this.hash,
      this.ext,
      this.mime,
      this.size,
      this.url,
      this.previewUrl,
      this.provider,
      this.provider_metadata,
      this.related,
      this.createdAt,
      this.updatedAt,
      this.id)
      : _synced = false;

  final bool _synced;

  final String name;

  final String alternativeText;

  final String caption;

  final int width;

  final int height;

  final Map<String, dynamic> formats;

  final String hash;

  final String ext;

  final String mime;

  final double size;

  final String url;

  final String previewUrl;

  final String provider;

  final Map<String, dynamic> provider_metadata;

  final List<dynamic> related;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  bool get synced => _synced;
  StrapiFile copyWIth(
          {String name,
          String alternativeText,
          String caption,
          int width,
          int height,
          Map<String, dynamic> formats,
          String hash,
          String ext,
          String mime,
          double size,
          String url,
          String previewUrl,
          String provider,
          Map<String, dynamic> provider_metadata,
          List<dynamic> related}) =>
      StrapiFile._unsynced(
          name ?? this.name,
          alternativeText ?? this.alternativeText,
          caption ?? this.caption,
          width ?? this.width,
          height ?? this.height,
          formats ?? this.formats,
          hash ?? this.hash,
          ext ?? this.ext,
          mime ?? this.mime,
          size ?? this.size,
          url ?? this.url,
          previewUrl ?? this.previewUrl,
          provider ?? this.provider,
          provider_metadata ?? this.provider_metadata,
          related ?? this.related,
          this.createdAt,
          this.updatedAt,
          this.id);
  StrapiFile setNull(
          {bool name = false,
          bool alternativeText = false,
          bool caption = false,
          bool width = false,
          bool height = false,
          bool formats = false,
          bool hash = false,
          bool ext = false,
          bool mime = false,
          bool size = false,
          bool url = false,
          bool previewUrl = false,
          bool provider = false,
          bool provider_metadata = false,
          bool related = false}) =>
      StrapiFile._unsynced(
          name ? null : this.name,
          alternativeText ? null : this.alternativeText,
          caption ? null : this.caption,
          width ? null : this.width,
          height ? null : this.height,
          formats ? null : this.formats,
          hash ? null : this.hash,
          ext ? null : this.ext,
          mime ? null : this.mime,
          size ? null : this.size,
          url ? null : this.url,
          previewUrl ? null : this.previewUrl,
          provider ? null : this.provider,
          provider_metadata ? null : this.provider_metadata,
          related ? null : this.related,
          this.createdAt,
          this.updatedAt,
          this.id);
  Map<String, dynamic> toMap() => {
        "name": name,
        "alternativeText": alternativeText,
        "caption": caption,
        "width": width,
        "height": height,
        "formats": jsonEncode(formats),
        "hash": hash,
        "ext": ext,
        "mime": mime,
        "size": size,
        "url": url,
        "previewUrl": previewUrl,
        "provider": provider,
        "provider_metadata": jsonEncode(provider_metadata),
        "related": related,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static StrapiFile fromSyncedMap(Map<String, dynamic> map) =>
      StrapiFile._synced(
          map["name"],
          map["alternativeText"],
          map["caption"],
          StrapiUtils.parseInt(map["width"]),
          StrapiUtils.parseInt(map["height"]),
          jsonDecode(map["formats"]),
          map["hash"],
          map["ext"],
          map["mime"],
          StrapiUtils.parseDouble(map["size"]),
          map["url"],
          map["previewUrl"],
          map["provider"],
          jsonDecode(map["provider_metadata"]),
          map["related"],
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static StrapiFile fromMap(Map<String, dynamic> map) => StrapiFile._unsynced(
      map["name"],
      map["alternativeText"],
      map["caption"],
      StrapiUtils.parseInt(map["width"]),
      StrapiUtils.parseInt(map["height"]),
      jsonDecode(map["formats"]),
      map["hash"],
      map["ext"],
      map["mime"],
      StrapiUtils.parseDouble(map["size"]),
      map["url"],
      map["previewUrl"],
      map["provider"],
      jsonDecode(map["provider_metadata"]),
      map["related"],
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => toMap().toString();
}

class StrapiFiles {
  static const collectionName = "StrapiFiles";

  static List<StrapiFile> fromIDs(List<String> ids) {
    if (ids.isEmpty) {
      return [];
    }
    return ids.map((id) => StrapiFile.fromID(id)).toList();
  }

  static Future<StrapiFile> findOne(String id) async {
    final mapResponse = await StrapiCollection.findOne(
      collection: collectionName,
      id: id,
    );
    if (mapResponse.isNotEmpty) {
      return StrapiFile.fromSyncedMap(mapResponse);
    }
  }

  static Future<List<StrapiFile>> findMultiple(
      {int limit = 16, StrapiQuery query}) async {
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, limit: limit, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => StrapiFile.fromSyncedMap(map)).toList();
    }
  }

  static Future<StrapiFile> create(StrapiFile strapiFile) async {
    final map = await StrapiCollection.create(
      collection: collectionName,
      data: strapiFile.toMap(),
    );
    if (map.isNotEmpty) {
      return StrapiFile.fromSyncedMap(map);
    }
  }

  static Future<StrapiFile> update(StrapiFile strapiFile) async {
    final id = strapiFile.id;
    if (id is String) {
      final map = await StrapiCollection.update(
        collection: collectionName,
        id: id,
        data: strapiFile.toMap(),
      );
      if (map.isNotEmpty) {
        return StrapiFile.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while updating");
    }
  }

  static Future<int> count() async {
    return await StrapiCollection.count(collectionName);
  }

  static Future<StrapiFile> delete(StrapiFile strapiFile) async {
    final id = strapiFile.id;
    if (id is String) {
      final map =
          await StrapiCollection.delete(collection: collectionName, id: id);
      if (map.isNotEmpty) {
        return StrapiFile.fromSyncedMap(map);
      }
    } else {
      sPrint("id is null while deleting");
    }
  }

  static List<StrapiFile> fromListOfIDOrData(List idsOrData) {
    if (idsOrData is! List) {
      return [];
    }
    if (idsOrData.isEmpty) {
      return [];
    }
    if (idsOrData.first is String) {
      return idsOrData.map((e) => StrapiFile.fromID(e)).toList();
    }
    if (idsOrData.first is Map) {
      return idsOrData.map((e) => StrapiFile.fromSyncedMap(e)).toList();
    }
    return [];
  }

  static StrapiFile fromIDorData(idOrData) {
    if (idOrData is String) {
      return StrapiFile.fromID(idOrData);
    }
    if (idOrData is Map) {
      return StrapiFile.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<StrapiFile>> getForListOfIDs(List<String> ids) async {
    if (ids != null && ids.isEmpty) {
      throw Exception("list of ids cannot be empty or null");
    }
    final query = StrapiQuery();
    ids.forEach((id) {
      query.where("id", StrapiQueryOperation.includesInAnArray, id);
    });
    final list = await StrapiCollection.findMultiple(
        collection: collectionName, query: query);
    if (list.isNotEmpty) {
      return list.map((map) => StrapiFile.fromSyncedMap(map)).toList();
    }
  }
}

class MenuCategories {
  MenuCategories._unsynced(this.name, this.enabled, this.image,
      this.description, this.catalogueItems);

  final String name;

  final bool enabled;

  final List<StrapiFile> image;

  final String description;

  final List<MenuItem> catalogueItems;

  Map<String, dynamic> toMap() => {
        "name": name,
        "enabled": enabled,
        "image": image?.map((e) => e.toMap()),
        "description": description,
        "catalogueItems": catalogueItems?.map((e) => e.toMap())
      };
  static MenuCategories fromMap(Map<String, dynamic> map) =>
      MenuCategories._unsynced(
          map["name"],
          StrapiUtils.parseBool(map["enabled"]),
          StrapiUtils.objFromListOfMap<StrapiFile>(
              map["image"], (e) => StrapiFiles.fromIDorData(e)),
          map["description"],
          StrapiUtils.objFromListOfMap<MenuItem>(
              map["catalogueItems"], (e) => MenuItem.fromMap(e)));
  @override
  String toString() => toMap().toString();
}

class Address {
  Address._unsynced(this.address, this.coordinates, this.locality);

  final String address;

  final Coordinates coordinates;

  final Locality locality;

  Map<String, dynamic> toMap() => {
        "address": address,
        "coordinates": coordinates?.toMap(),
        "locality": locality?.toMap()
      };
  static Address fromMap(Map<String, dynamic> map) => Address._unsynced(
      map["address"],
      StrapiUtils.objFromMap<Coordinates>(
          map["coordinates"], (e) => Coordinates.fromMap(e)),
      StrapiUtils.objFromMap<Locality>(
          map["locality"], (e) => Localities.fromIDorData(e)));
  @override
  String toString() => toMap().toString();
}

class Package {
  Package._unsynced(this.name, this.products, this.startDate, this.endDate,
      this.enabled, this.priceBefore, this.priceAfter);

  final String name;

  final List<MenuItem> products;

  final DateTime startDate;

  final DateTime endDate;

  final bool enabled;

  final double priceBefore;

  final double priceAfter;

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
      map["name"],
      StrapiUtils.objFromListOfMap<MenuItem>(
          map["products"], (e) => MenuItem.fromMap(e)),
      StrapiUtils.parseDateTime(map["startDate"]),
      StrapiUtils.parseDateTime(map["endDate"]),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.parseDouble(map["priceBefore"]),
      StrapiUtils.parseDouble(map["priceAfter"]));
  @override
  String toString() => toMap().toString();
}

class MenuItem {
  MenuItem._unsynced(this.price, this.duration, this.enabled, this.nameOverride,
      this.descriptionOverride, this.imageOverride);

  final double price;

  final int duration;

  final bool enabled;

  final String nameOverride;

  final String descriptionOverride;

  final List<StrapiFile> imageOverride;

  Map<String, dynamic> toMap() => {
        "price": price,
        "duration": duration,
        "enabled": enabled,
        "nameOverride": nameOverride,
        "descriptionOverride": descriptionOverride,
        "imageOverride": imageOverride?.map((e) => e.toMap())
      };
  static MenuItem fromMap(Map<String, dynamic> map) => MenuItem._unsynced(
      StrapiUtils.parseDouble(map["price"]),
      StrapiUtils.parseInt(map["duration"]),
      StrapiUtils.parseBool(map["enabled"]),
      map["nameOverride"],
      map["descriptionOverride"],
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["imageOverride"], (e) => StrapiFiles.fromIDorData(e)));
  @override
  String toString() => toMap().toString();
}

class Favourites {
  Favourites._unsynced(this.business, this.addedOn);

  final Business business;

  final DateTime addedOn;

  Map<String, dynamic> toMap() =>
      {"business": business?.toMap(), "addedOn": addedOn?.toIso8601String()};
  static Favourites fromMap(Map<String, dynamic> map) => Favourites._unsynced(
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses.fromIDorData(e)),
      StrapiUtils.parseDateTime(map["addedOn"]));
  @override
  String toString() => toMap().toString();
}

class Coordinates {
  Coordinates._unsynced(this.latitude, this.longitude);

  final double latitude;

  final double longitude;

  Map<String, dynamic> toMap() =>
      {"latitude": latitude, "longitude": longitude};
  static Coordinates fromMap(Map<String, dynamic> map) => Coordinates._unsynced(
      StrapiUtils.parseDouble(map["latitude"]),
      StrapiUtils.parseDouble(map["longitude"]));
  @override
  String toString() => toMap().toString();
}

class Demo {
  Demo._unsynced(this.b);

  final bool b;

  Map<String, dynamic> toMap() => {"b": b};
  static Demo fromMap(Map<String, dynamic> map) =>
      Demo._unsynced(StrapiUtils.parseBool(map["b"]));
  @override
  String toString() => toMap().toString();
}
