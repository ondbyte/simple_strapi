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

  static final collectionName = "cities";

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
  static _CityFields get fields => _CityFields.i;
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
          map["country"], (e) => Countries._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Locality>(
          map["localities"], (e) => Localities._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static City fromMap(Map<String, dynamic> map) => City._unsynced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<Country>(
          map["country"], (e) => Countries._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Locality>(
          map["localities"], (e) => Localities._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => "[Strapi Collection Type City]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return City.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<City>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => City.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<City> create(City city) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: city.toMap(),
      );
      if (map.isNotEmpty) {
        return City.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<City> update(City city) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<City> delete(City city) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static City _fromIDorData(idOrData) {
    if (idOrData is String) {
      return City.fromID(idOrData);
    }
    if (idOrData is Map) {
      return City.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<City>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _CityFields {
  _CityFields._i();

  static final _CityFields i = _CityFields._i();

  final name = StrapiLeafField("name");

  final enabled = StrapiLeafField("enabled");

  final country = StrapiModelField("country");

  final localities = StrapiCollectionField("localities");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [name, enabled, country, localities, createdAt, updatedAt, id];
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

  static final collectionName = "employees";

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
  static _EmployeeFields get fields => _EmployeeFields.i;
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
          map["image"], (e) => StrapiFiles._fromIDorData(e)),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<User>(map["user"], (e) => Users._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Business>(
          map["businesses"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Employee fromMap(Map<String, dynamic> map) => Employee._unsynced(
      map["name"],
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["image"], (e) => StrapiFiles._fromIDorData(e)),
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<User>(map["user"], (e) => Users._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Business>(
          map["businesses"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() =>
      "[Strapi Collection Type Employee]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return Employee.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<Employee>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => Employee.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Employee> create(Employee employee) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: employee.toMap(),
      );
      if (map.isNotEmpty) {
        return Employee.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Employee> update(Employee employee) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<Employee> delete(Employee employee) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Employee _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Employee.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Employee.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Employee>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _EmployeeFields {
  _EmployeeFields._i();

  static final _EmployeeFields i = _EmployeeFields._i();

  final name = StrapiLeafField("name");

  final image = StrapiCollectionField("image");

  final enabled = StrapiLeafField("enabled");

  final user = StrapiModelField("user");

  final bookings = StrapiCollectionField("bookings");

  final businesses = StrapiCollectionField("businesses");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      image,
      enabled,
      user,
      bookings,
      businesses,
      createdAt,
      updatedAt,
      id
    ];
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
        demo_date = null,
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
      this.user,
      this.demo_date)
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
      this.demo_date,
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
      this.demo_date,
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

  final DateTime demo_date;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  static final collectionName = "bookings";

  bool get synced => _synced;
  Booking copyWIth(
          {Business business,
          DateTime bookedOn,
          DateTime bookingStartTime,
          DateTime bookingEndTime,
          List<Package> packages,
          List<MenuItem> products,
          Employee employee,
          User user,
          DateTime demo_date}) =>
      Booking._unsynced(
          business ?? this.business,
          bookedOn ?? this.bookedOn,
          bookingStartTime ?? this.bookingStartTime,
          bookingEndTime ?? this.bookingEndTime,
          packages ?? this.packages,
          products ?? this.products,
          employee ?? this.employee,
          user ?? this.user,
          demo_date ?? this.demo_date,
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
          bool user = false,
          bool demo_date = false}) =>
      Booking._unsynced(
          business ? null : this.business,
          bookedOn ? null : this.bookedOn,
          bookingStartTime ? null : this.bookingStartTime,
          bookingEndTime ? null : this.bookingEndTime,
          packages ? null : this.packages,
          products ? null : this.products,
          employee ? null : this.employee,
          user ? null : this.user,
          demo_date ? null : this.demo_date,
          this.createdAt,
          this.updatedAt,
          this.id);
  static _BookingFields get fields => _BookingFields.i;
  Map<String, dynamic> toMap() => {
        "business": business?.toMap(),
        "bookedOn": bookedOn?.toIso8601String(),
        "bookingStartTime": bookingStartTime?.toIso8601String(),
        "bookingEndTime": bookingEndTime?.toIso8601String(),
        "packages": packages?.map((e) => e.toMap()),
        "products": products?.map((e) => e.toMap()),
        "employee": employee?.toMap(),
        "user": user?.toMap(),
        "demo_date": demo_date?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static Booking fromSyncedMap(Map<String, dynamic> map) => Booking._synced(
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["bookedOn"]),
      StrapiUtils.parseDateTime(map["bookingStartTime"]),
      StrapiUtils.parseDateTime(map["bookingEndTime"]),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<MenuItem>(
          map["products"], (e) => MenuItem.fromMap(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.objFromMap<User>(map["user"], (e) => Users._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["demo_date"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Booking fromMap(Map<String, dynamic> map) => Booking._unsynced(
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["bookedOn"]),
      StrapiUtils.parseDateTime(map["bookingStartTime"]),
      StrapiUtils.parseDateTime(map["bookingEndTime"]),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<MenuItem>(
          map["products"], (e) => MenuItem.fromMap(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.objFromMap<User>(map["user"], (e) => Users._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["demo_date"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() =>
      "[Strapi Collection Type Booking]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return Booking.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<Booking>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => Booking.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Booking> create(Booking booking) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: booking.toMap(),
      );
      if (map.isNotEmpty) {
        return Booking.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Booking> update(Booking booking) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<Booking> delete(Booking booking) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Booking _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Booking.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Booking.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Booking>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _BookingFields {
  _BookingFields._i();

  static final _BookingFields i = _BookingFields._i();

  final business = StrapiModelField("business");

  final bookedOn = StrapiLeafField("bookedOn");

  final bookingStartTime = StrapiLeafField("bookingStartTime");

  final bookingEndTime = StrapiLeafField("bookingEndTime");

  final packages = StrapiComponentField("packages");

  final products = StrapiComponentField("products");

  final employee = StrapiModelField("employee");

  final user = StrapiModelField("user");

  final demo_date = StrapiLeafField("demo_date");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      business,
      bookedOn,
      bookingStartTime,
      bookingEndTime,
      packages,
      products,
      employee,
      user,
      demo_date,
      createdAt,
      updatedAt,
      id
    ];
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

  static final collectionName = "localities";

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
  static _LocalityFields get fields => _LocalityFields.i;
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
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.objFromMap<Coordinates>(
          map["coordinates"], (e) => Coordinates.fromMap(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Locality fromMap(Map<String, dynamic> map) => Locality._unsynced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.objFromMap<Coordinates>(
          map["coordinates"], (e) => Coordinates.fromMap(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() =>
      "[Strapi Collection Type Locality]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return Locality.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<Locality>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => Locality.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Locality> create(Locality locality) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: locality.toMap(),
      );
      if (map.isNotEmpty) {
        return Locality.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Locality> update(Locality locality) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<Locality> delete(Locality locality) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Locality _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Locality.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Locality.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Locality>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _LocalityFields {
  _LocalityFields._i();

  static final _LocalityFields i = _LocalityFields._i();

  final name = StrapiLeafField("name");

  final enabled = StrapiLeafField("enabled");

  final city = StrapiModelField("city");

  final coordinates = StrapiComponentField("coordinates");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [name, enabled, city, coordinates, createdAt, updatedAt, id];
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

  static final collectionName = "push-notifications";

  bool get synced => _synced;
  PushNotification copyWIth({DateTime pushed_on, User user}) =>
      PushNotification._unsynced(pushed_on ?? this.pushed_on, user ?? this.user,
          this.createdAt, this.updatedAt, this.id);
  PushNotification setNull({bool pushed_on = false, bool user = false}) =>
      PushNotification._unsynced(pushed_on ? null : this.pushed_on,
          user ? null : this.user, this.createdAt, this.updatedAt, this.id);
  static _PushNotificationFields get fields => _PushNotificationFields.i;
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
              map["user"], (e) => Users._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static PushNotification fromMap(Map<String, dynamic> map) =>
      PushNotification._unsynced(
          StrapiUtils.parseDateTime(map["pushed_on"]),
          StrapiUtils.objFromMap<User>(
              map["user"], (e) => Users._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  @override
  String toString() =>
      "[Strapi Collection Type PushNotification]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return PushNotification.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<PushNotification>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => PushNotification.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<PushNotification> create(
      PushNotification pushNotification) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: pushNotification.toMap(),
      );
      if (map.isNotEmpty) {
        return PushNotification.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<PushNotification> update(
      PushNotification pushNotification) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<PushNotification> delete(
      PushNotification pushNotification) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static PushNotification _fromIDorData(idOrData) {
    if (idOrData is String) {
      return PushNotification.fromID(idOrData);
    }
    if (idOrData is Map) {
      return PushNotification.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<PushNotification>> executeQuery(
      StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _PushNotificationFields {
  _PushNotificationFields._i();

  static final _PushNotificationFields i = _PushNotificationFields._i();

  final pushed_on = StrapiLeafField("pushed_on");

  final user = StrapiModelField("user");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [pushed_on, user, createdAt, updatedAt, id];
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

  static final collectionName = "countries";

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
  static _CountryFields get fields => _CountryFields.i;
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
          map["cities"], (e) => Cities._fromIDorData(e)),
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
          map["cities"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() =>
      "[Strapi Collection Type Country]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return Country.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<Country>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => Country.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Country> create(Country country) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: country.toMap(),
      );
      if (map.isNotEmpty) {
        return Country.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Country> update(Country country) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<Country> delete(Country country) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Country _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Country.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Country.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Country>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _CountryFields {
  _CountryFields._i();

  static final _CountryFields i = _CountryFields._i();

  final name = StrapiLeafField("name");

  final iso2Code = StrapiLeafField("iso2Code");

  final englishCurrencySymbol = StrapiLeafField("englishCurrencySymbol");

  final flagUrl = StrapiLeafField("flagUrl");

  final enabled = StrapiLeafField("enabled");

  final localCurrencySymbol = StrapiLeafField("localCurrencySymbol");

  final localName = StrapiLeafField("localName");

  final cities = StrapiCollectionField("cities");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      iso2Code,
      englishCurrencySymbol,
      flagUrl,
      enabled,
      localCurrencySymbol,
      localName,
      cities,
      createdAt,
      updatedAt,
      id
    ];
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

  static final collectionName = "businesses";

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
  static _BusinessFields get fields => _BusinessFields.i;
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
          map["partner"], (e) => Partners._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Employee>(
          map["employees"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<BusinessFeature>(
          map["businessFeatures"], (e) => BusinessFeatures._fromIDorData(e)),
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
          map["partner"], (e) => Partners._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Package>(
          map["packages"], (e) => Package.fromMap(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Employee>(
          map["employees"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<BusinessFeature>(
          map["businessFeatures"], (e) => BusinessFeatures._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() =>
      "[Strapi Collection Type Business]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return Business.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<Business>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => Business.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Business> create(Business business) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: business.toMap(),
      );
      if (map.isNotEmpty) {
        return Business.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Business> update(Business business) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<Business> delete(Business business) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Business _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Business.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Business.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Business>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _BusinessFields {
  _BusinessFields._i();

  static final _BusinessFields i = _BusinessFields._i();

  final name = StrapiLeafField("name");

  final address = StrapiComponentField("address");

  final enabled = StrapiLeafField("enabled");

  final catalogue = StrapiComponentField("catalogue");

  final partner = StrapiModelField("partner");

  final packages = StrapiComponentField("packages");

  final bookings = StrapiCollectionField("bookings");

  final employees = StrapiCollectionField("employees");

  final businessFeatures = StrapiCollectionField("businessFeatures");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      address,
      enabled,
      catalogue,
      partner,
      packages,
      bookings,
      employees,
      businessFeatures,
      createdAt,
      updatedAt,
      id
    ];
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

  static final collectionName = "partners";

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
  static _PartnerFields get fields => _PartnerFields.i;
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
          map["logo"], (e) => StrapiFiles._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Business>(
          map["businesses"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.objFromMap<User>(map["owner"], (e) => Users._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Partner fromMap(Map<String, dynamic> map) => Partner._unsynced(
      map["name"],
      StrapiUtils.parseBool(map["enabled"]),
      StrapiUtils.objFromListOfMap<StrapiFile>(
          map["logo"], (e) => StrapiFiles._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Business>(
          map["businesses"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.objFromMap<User>(map["owner"], (e) => Users._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() =>
      "[Strapi Collection Type Partner]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return Partner.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<Partner>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => Partner.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Partner> create(Partner partner) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: partner.toMap(),
      );
      if (map.isNotEmpty) {
        return Partner.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Partner> update(Partner partner) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<Partner> delete(Partner partner) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Partner _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Partner.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Partner.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Partner>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _PartnerFields {
  _PartnerFields._i();

  static final _PartnerFields i = _PartnerFields._i();

  final name = StrapiLeafField("name");

  final enabled = StrapiLeafField("enabled");

  final logo = StrapiCollectionField("logo");

  final businesses = StrapiCollectionField("businesses");

  final owner = StrapiModelField("owner");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [name, enabled, logo, businesses, owner, createdAt, updatedAt, id];
  }
}

class DefaultData {
  DefaultData.fromID(this.id)
      : _synced = false,
        locality = null,
        deviceId = null,
        city = null,
        createdAt = null,
        updatedAt = null;

  DefaultData.fresh(this.locality, this.deviceId, this.city)
      : _synced = false,
        createdAt = null,
        updatedAt = null,
        id = null;

  DefaultData._synced(this.locality, this.deviceId, this.city, this.createdAt,
      this.updatedAt, this.id)
      : _synced = true;

  DefaultData._unsynced(this.locality, this.deviceId, this.city, this.createdAt,
      this.updatedAt, this.id)
      : _synced = false;

  final bool _synced;

  final Locality locality;

  final String deviceId;

  final City city;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  static final collectionName = "default-data";

  bool get synced => _synced;
  DefaultData copyWIth({Locality locality, String deviceId, City city}) =>
      DefaultData._unsynced(
          locality ?? this.locality,
          deviceId ?? this.deviceId,
          city ?? this.city,
          this.createdAt,
          this.updatedAt,
          this.id);
  DefaultData setNull(
          {bool locality = false, bool deviceId = false, bool city = false}) =>
      DefaultData._unsynced(
          locality ? null : this.locality,
          deviceId ? null : this.deviceId,
          city ? null : this.city,
          this.createdAt,
          this.updatedAt,
          this.id);
  static _DefaultDataFields get fields => _DefaultDataFields.i;
  Map<String, dynamic> toMap() => {
        "locality": locality?.toMap(),
        "deviceId": deviceId,
        "city": city?.toMap(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id
      };
  static DefaultData fromSyncedMap(
          Map<String, dynamic> map) =>
      DefaultData._synced(
          StrapiUtils.objFromMap<Locality>(
              map["locality"], (e) => Localities._fromIDorData(e)),
          map["deviceId"],
          StrapiUtils.objFromMap<City>(
              map["city"], (e) => Cities._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static DefaultData fromMap(Map<String, dynamic> map) => DefaultData._unsynced(
      StrapiUtils.objFromMap<Locality>(
          map["locality"], (e) => Localities._fromIDorData(e)),
      map["deviceId"],
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() =>
      "[Strapi Collection Type DefaultData]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return DefaultData.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<DefaultData>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => DefaultData.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<DefaultData> create(DefaultData defaultData) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: defaultData.toMap(),
      );
      if (map.isNotEmpty) {
        return DefaultData.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<DefaultData> update(DefaultData defaultData) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<DefaultData> delete(DefaultData defaultData) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static DefaultData _fromIDorData(idOrData) {
    if (idOrData is String) {
      return DefaultData.fromID(idOrData);
    }
    if (idOrData is Map) {
      return DefaultData.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<DefaultData>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _DefaultDataFields {
  _DefaultDataFields._i();

  static final _DefaultDataFields i = _DefaultDataFields._i();

  final locality = StrapiModelField("locality");

  final deviceId = StrapiLeafField("deviceId");

  final city = StrapiModelField("city");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [locality, deviceId, city, createdAt, updatedAt, id];
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

  static final collectionName = "business-features";

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
  static _BusinessFeatureFields get fields => _BusinessFeatureFields.i;
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
              map["business"], (e) => Businesses._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static BusinessFeature fromMap(Map<String, dynamic> map) =>
      BusinessFeature._unsynced(
          StrapiUtils.parseDateTime(map["startDate"]),
          StrapiUtils.parseDateTime(map["endDate"]),
          StrapiUtils.objFromMap<Business>(
              map["business"], (e) => Businesses._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  @override
  String toString() =>
      "[Strapi Collection Type BusinessFeature]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return BusinessFeature.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<BusinessFeature>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => BusinessFeature.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<BusinessFeature> create(BusinessFeature businessFeature) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: businessFeature.toMap(),
      );
      if (map.isNotEmpty) {
        return BusinessFeature.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<BusinessFeature> update(BusinessFeature businessFeature) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<BusinessFeature> delete(BusinessFeature businessFeature) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static BusinessFeature _fromIDorData(idOrData) {
    if (idOrData is String) {
      return BusinessFeature.fromID(idOrData);
    }
    if (idOrData is Map) {
      return BusinessFeature.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<BusinessFeature>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _BusinessFeatureFields {
  _BusinessFeatureFields._i();

  static final _BusinessFeatureFields i = _BusinessFeatureFields._i();

  final startDate = StrapiLeafField("startDate");

  final endDate = StrapiLeafField("endDate");

  final business = StrapiModelField("business");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [startDate, endDate, business, createdAt, updatedAt, id];
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

  static final collectionName = "null";

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
  static _RoleFields get fields => _RoleFields.i;
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
          map["permissions"], (e) => Permissions._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<User>(
          map["users"], (e) => Users._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  static Role fromMap(Map<String, dynamic> map) => Role._unsynced(
      map["name"],
      map["description"],
      map["type"],
      StrapiUtils.objFromListOfMap<Permission>(
          map["permissions"], (e) => Permissions._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<User>(
          map["users"], (e) => Users._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => "[Strapi Collection Type Role]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return Role.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<Role>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => Role.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Role> create(Role role) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: role.toMap(),
      );
      if (map.isNotEmpty) {
        return Role.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Role> update(Role role) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<Role> delete(Role role) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Role _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Role.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Role.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Role>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _RoleFields {
  _RoleFields._i();

  static final _RoleFields i = _RoleFields._i();

  final name = StrapiLeafField("name");

  final description = StrapiLeafField("description");

  final type = StrapiLeafField("type");

  final permissions = StrapiCollectionField("permissions");

  final users = StrapiCollectionField("users");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      description,
      type,
      permissions,
      users,
      createdAt,
      updatedAt,
      id
    ];
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
        city = null,
        demo_date = null,
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
      this.locality,
      this.city,
      this.demo_date)
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
      this.city,
      this.demo_date,
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
      this.city,
      this.demo_date,
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

  final City city;

  final DateTime demo_date;

  final DateTime createdAt;

  final DateTime updatedAt;

  final String id;

  static final collectionName = "null";

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
          Locality locality,
          City city,
          DateTime demo_date}) =>
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
          city ?? this.city,
          demo_date ?? this.demo_date,
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
          bool locality = false,
          bool city = false,
          bool demo_date = false}) =>
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
          city ? null : this.city,
          demo_date ? null : this.demo_date,
          this.createdAt,
          this.updatedAt,
          this.id);
  static _UserFields get fields => _UserFields.i;
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
        "city": city?.toMap(),
        "demo_date": demo_date?.toIso8601String(),
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
      StrapiUtils.objFromMap<Role>(map["role"], (e) => Roles._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Favourites>(
          map["favourites"], (e) => Favourites.fromMap(e)),
      map["name"],
      StrapiUtils.objFromListOfMap<PushNotification>(
          map["pushNotifications"], (e) => PushNotifications._fromIDorData(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.objFromMap<Partner>(
          map["partner"], (e) => Partners._fromIDorData(e)),
      StrapiUtils.objFromMap<Locality>(
          map["locality"], (e) => Localities._fromIDorData(e)),
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["demo_date"]),
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
      StrapiUtils.objFromMap<Role>(map["role"], (e) => Roles._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Favourites>(
          map["favourites"], (e) => Favourites.fromMap(e)),
      map["name"],
      StrapiUtils.objFromListOfMap<PushNotification>(
          map["pushNotifications"], (e) => PushNotifications._fromIDorData(e)),
      StrapiUtils.objFromMap<Employee>(
          map["employee"], (e) => Employees._fromIDorData(e)),
      StrapiUtils.objFromListOfMap<Booking>(
          map["bookings"], (e) => Bookings._fromIDorData(e)),
      StrapiUtils.objFromMap<Partner>(
          map["partner"], (e) => Partners._fromIDorData(e)),
      StrapiUtils.objFromMap<Locality>(
          map["locality"], (e) => Localities._fromIDorData(e)),
      StrapiUtils.objFromMap<City>(map["city"], (e) => Cities._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["demo_date"]),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() => "[Strapi Collection Type User]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return User.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<User>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => User.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<User> create(User user) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: user.toMap(),
      );
      if (map.isNotEmpty) {
        return User.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<User> update(User user) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<User> delete(User user) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static User _fromIDorData(idOrData) {
    if (idOrData is String) {
      return User.fromID(idOrData);
    }
    if (idOrData is Map) {
      return User.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<User>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }

  static Future<User> me() async {
    try {
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
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }
}

class _UserFields {
  _UserFields._i();

  static final _UserFields i = _UserFields._i();

  final username = StrapiLeafField("username");

  final email = StrapiLeafField("email");

  final provider = StrapiLeafField("provider");

  final resetPasswordToken = StrapiLeafField("resetPasswordToken");

  final confirmationToken = StrapiLeafField("confirmationToken");

  final confirmed = StrapiLeafField("confirmed");

  final blocked = StrapiLeafField("blocked");

  final role = StrapiModelField("role");

  final favourites = StrapiComponentField("favourites");

  final name = StrapiLeafField("name");

  final pushNotifications = StrapiCollectionField("pushNotifications");

  final employee = StrapiModelField("employee");

  final bookings = StrapiCollectionField("bookings");

  final partner = StrapiModelField("partner");

  final locality = StrapiModelField("locality");

  final city = StrapiModelField("city");

  final demo_date = StrapiLeafField("demo_date");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      username,
      email,
      provider,
      resetPasswordToken,
      confirmationToken,
      confirmed,
      blocked,
      role,
      favourites,
      name,
      pushNotifications,
      employee,
      bookings,
      partner,
      locality,
      city,
      demo_date,
      createdAt,
      updatedAt,
      id
    ];
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

  static final collectionName = "null";

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
  static _PermissionFields get fields => _PermissionFields.i;
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
  static Permission fromSyncedMap(Map<String, dynamic> map) =>
      Permission._synced(
          map["type"],
          map["controller"],
          map["action"],
          StrapiUtils.parseBool(map["enabled"]),
          map["policy"],
          StrapiUtils.objFromMap<Role>(
              map["role"], (e) => Roles._fromIDorData(e)),
          StrapiUtils.parseDateTime(map["createdAt"]),
          StrapiUtils.parseDateTime(map["updatedAt"]),
          map["id"]);
  static Permission fromMap(Map<String, dynamic> map) => Permission._unsynced(
      map["type"],
      map["controller"],
      map["action"],
      StrapiUtils.parseBool(map["enabled"]),
      map["policy"],
      StrapiUtils.objFromMap<Role>(map["role"], (e) => Roles._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["createdAt"]),
      StrapiUtils.parseDateTime(map["updatedAt"]),
      map["id"]);
  @override
  String toString() =>
      "[Strapi Collection Type Permission]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return Permission.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<Permission>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => Permission.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Permission> create(Permission permission) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: permission.toMap(),
      );
      if (map.isNotEmpty) {
        return Permission.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<Permission> update(Permission permission) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<Permission> delete(Permission permission) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Permission _fromIDorData(idOrData) {
    if (idOrData is String) {
      return Permission.fromID(idOrData);
    }
    if (idOrData is Map) {
      return Permission.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<Permission>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _PermissionFields {
  _PermissionFields._i();

  static final _PermissionFields i = _PermissionFields._i();

  final type = StrapiLeafField("type");

  final controller = StrapiLeafField("controller");

  final action = StrapiLeafField("action");

  final enabled = StrapiLeafField("enabled");

  final policy = StrapiLeafField("policy");

  final role = StrapiModelField("role");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      type,
      controller,
      action,
      enabled,
      policy,
      role,
      createdAt,
      updatedAt,
      id
    ];
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

  static final collectionName = "null";

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
  static _StrapiFileFields get fields => _StrapiFileFields.i;
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
  String toString() =>
      "[Strapi Collection Type StrapiFile]\n" + toMap().toString();
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
    try {
      final mapResponse = await StrapiCollection.findOne(
        collection: collectionName,
        id: id,
      );
      if (mapResponse.isNotEmpty) {
        return StrapiFile.fromSyncedMap(mapResponse);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<List<StrapiFile>> findMultiple({int limit = 16}) async {
    try {
      final list = await StrapiCollection.findMultiple(
        collection: collectionName,
        limit: limit,
      );
      if (list.isNotEmpty) {
        return list.map((map) => StrapiFile.fromSyncedMap(map)).toList();
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<StrapiFile> create(StrapiFile strapiFile) async {
    try {
      final map = await StrapiCollection.create(
        collection: collectionName,
        data: strapiFile.toMap(),
      );
      if (map.isNotEmpty) {
        return StrapiFile.fromSyncedMap(map);
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<StrapiFile> update(StrapiFile strapiFile) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static Future<int> count() async {
    try {
      return await StrapiCollection.count(collectionName);
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return 0;
  }

  static Future<StrapiFile> delete(StrapiFile strapiFile) async {
    try {
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
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
  }

  static StrapiFile _fromIDorData(idOrData) {
    if (idOrData is String) {
      return StrapiFile.fromID(idOrData);
    }
    if (idOrData is Map) {
      return StrapiFile.fromSyncedMap(idOrData);
    }
    return null;
  }

  static Future<List<StrapiFile>> executeQuery(StrapiCollectionQuery query,
      {int maxTimeOutInMillis = 15000}) async {
    final queryString = query.query(
      collectionName: collectionName,
    );
    try {
      final response = await Strapi.i
          .graphRequest(queryString, maxTimeOutInMillis: maxTimeOutInMillis);
      if (response.body.isNotEmpty) {
        final object = response.body.first;
        if (object is Map && object.containsKey("data")) {
          final data = object["data"];
          if (data is Map && data.containsKey(collectionName)) {
            final myList = data[collectionName];
            if (myList is List) {
              return myList.map((e) => _fromIDorData(e)).toList();
            } else if (myList is Map && myList.containsKey("id")) {
              return [_fromIDorData(myList)];
            }
          }
        }
      }
    } catch (e, s) {
      sPrint(e);
      sPrint(s);
    }
    return [];
  }
}

class _StrapiFileFields {
  _StrapiFileFields._i();

  static final _StrapiFileFields i = _StrapiFileFields._i();

  final name = StrapiLeafField("name");

  final alternativeText = StrapiLeafField("alternativeText");

  final caption = StrapiLeafField("caption");

  final width = StrapiLeafField("width");

  final height = StrapiLeafField("height");

  final formats = StrapiLeafField("formats");

  final hash = StrapiLeafField("hash");

  final ext = StrapiLeafField("ext");

  final mime = StrapiLeafField("mime");

  final size = StrapiLeafField("size");

  final url = StrapiLeafField("url");

  final previewUrl = StrapiLeafField("previewUrl");

  final provider = StrapiLeafField("provider");

  final provider_metadata = StrapiLeafField("provider_metadata");

  final related = StrapiCollectionField("related");

  final createdAt = StrapiLeafField("createdAt");

  final updatedAt = StrapiLeafField("updatedAt");

  final id = StrapiLeafField("id");

  List<StrapiField> call() {
    return [
      name,
      alternativeText,
      caption,
      width,
      height,
      formats,
      hash,
      ext,
      mime,
      size,
      url,
      previewUrl,
      provider,
      provider_metadata,
      related,
      createdAt,
      updatedAt,
      id
    ];
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

  static _MenuCategoriesFields get fields => _MenuCategoriesFields.i;
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
              map["image"], (e) => StrapiFiles._fromIDorData(e)),
          map["description"],
          StrapiUtils.objFromListOfMap<MenuItem>(
              map["catalogueItems"], (e) => MenuItem.fromMap(e)));
  @override
  String toString() =>
      "[Strapi Component Type MenuCategories]: \n" + toMap().toString();
}

class _MenuCategoriesFields {
  _MenuCategoriesFields._i();

  static final _MenuCategoriesFields i = _MenuCategoriesFields._i();

  final name = StrapiLeafField("name");

  final enabled = StrapiLeafField("enabled");

  final image = StrapiCollectionField("image");

  final description = StrapiLeafField("description");

  final catalogueItems = StrapiComponentField("catalogueItems");

  List<StrapiField> call() {
    return [name, enabled, image, description, catalogueItems];
  }
}

class Address {
  Address._unsynced(this.address, this.coordinates, this.locality);

  final String address;

  final Coordinates coordinates;

  final Locality locality;

  static _AddressFields get fields => _AddressFields.i;
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
          map["locality"], (e) => Localities._fromIDorData(e)));
  @override
  String toString() =>
      "[Strapi Component Type Address]: \n" + toMap().toString();
}

class _AddressFields {
  _AddressFields._i();

  static final _AddressFields i = _AddressFields._i();

  final address = StrapiLeafField("address");

  final coordinates = StrapiComponentField("coordinates");

  final locality = StrapiModelField("locality");

  List<StrapiField> call() {
    return [address, coordinates, locality];
  }
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

  static _PackageFields get fields => _PackageFields.i;
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
  String toString() =>
      "[Strapi Component Type Package]: \n" + toMap().toString();
}

class _PackageFields {
  _PackageFields._i();

  static final _PackageFields i = _PackageFields._i();

  final name = StrapiLeafField("name");

  final products = StrapiComponentField("products");

  final startDate = StrapiLeafField("startDate");

  final endDate = StrapiLeafField("endDate");

  final enabled = StrapiLeafField("enabled");

  final priceBefore = StrapiLeafField("priceBefore");

  final priceAfter = StrapiLeafField("priceAfter");

  List<StrapiField> call() {
    return [
      name,
      products,
      startDate,
      endDate,
      enabled,
      priceBefore,
      priceAfter
    ];
  }
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

  static _MenuItemFields get fields => _MenuItemFields.i;
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
          map["imageOverride"], (e) => StrapiFiles._fromIDorData(e)));
  @override
  String toString() =>
      "[Strapi Component Type MenuItem]: \n" + toMap().toString();
}

class _MenuItemFields {
  _MenuItemFields._i();

  static final _MenuItemFields i = _MenuItemFields._i();

  final price = StrapiLeafField("price");

  final duration = StrapiLeafField("duration");

  final enabled = StrapiLeafField("enabled");

  final nameOverride = StrapiLeafField("nameOverride");

  final descriptionOverride = StrapiLeafField("descriptionOverride");

  final imageOverride = StrapiCollectionField("imageOverride");

  List<StrapiField> call() {
    return [
      price,
      duration,
      enabled,
      nameOverride,
      descriptionOverride,
      imageOverride
    ];
  }
}

class Favourites {
  Favourites._unsynced(this.business, this.addedOn);

  final Business business;

  final DateTime addedOn;

  static _FavouritesFields get fields => _FavouritesFields.i;
  Map<String, dynamic> toMap() =>
      {"business": business?.toMap(), "addedOn": addedOn?.toIso8601String()};
  static Favourites fromMap(Map<String, dynamic> map) => Favourites._unsynced(
      StrapiUtils.objFromMap<Business>(
          map["business"], (e) => Businesses._fromIDorData(e)),
      StrapiUtils.parseDateTime(map["addedOn"]));
  @override
  String toString() =>
      "[Strapi Component Type Favourites]: \n" + toMap().toString();
}

class _FavouritesFields {
  _FavouritesFields._i();

  static final _FavouritesFields i = _FavouritesFields._i();

  final business = StrapiModelField("business");

  final addedOn = StrapiLeafField("addedOn");

  List<StrapiField> call() {
    return [business, addedOn];
  }
}

class Coordinates {
  Coordinates._unsynced(this.latitude, this.longitude);

  final double latitude;

  final double longitude;

  static _CoordinatesFields get fields => _CoordinatesFields.i;
  Map<String, dynamic> toMap() =>
      {"latitude": latitude, "longitude": longitude};
  static Coordinates fromMap(Map<String, dynamic> map) => Coordinates._unsynced(
      StrapiUtils.parseDouble(map["latitude"]),
      StrapiUtils.parseDouble(map["longitude"]));
  @override
  String toString() =>
      "[Strapi Component Type Coordinates]: \n" + toMap().toString();
}

class _CoordinatesFields {
  _CoordinatesFields._i();

  static final _CoordinatesFields i = _CoordinatesFields._i();

  final latitude = StrapiLeafField("latitude");

  final longitude = StrapiLeafField("longitude");

  List<StrapiField> call() {
    return [latitude, longitude];
  }
}

class Demo {
  Demo._unsynced(this.b);

  final bool b;

  static _DemoFields get fields => _DemoFields.i;
  Map<String, dynamic> toMap() => {"b": b};
  static Demo fromMap(Map<String, dynamic> map) =>
      Demo._unsynced(StrapiUtils.parseBool(map["b"]));
  @override
  String toString() => "[Strapi Component Type Demo]: \n" + toMap().toString();
}

class _DemoFields {
  _DemoFields._i();

  static final _DemoFields i = _DemoFields._i();

  final b = StrapiLeafField("b");

  List<StrapiField> call() {
    return [b];
  }
}
