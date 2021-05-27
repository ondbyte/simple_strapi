import 'package:bapp/helpers/exceptions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/super_strapi/my_strapi/partnerX.dart';
import 'package:bapp/super_strapi/my_strapi/x.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/state_manager.dart';
import 'package:simple_strapi/simple_strapi.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessX extends X {
  static final i = BusinessX._x();
  BusinessX._x();

  final businesses = <Business>[].obs;

  Future<List<Business>> init() async {
    final partner = PartnerX.i.partner();
    if (partner is Partner) {
      await getPartnerBusinessesFromServer(
        partner,
        key: ValueKey("getPartnerBusinessesFromServer"),
      );
    }
    return businesses;
  }

  Future<List<Business>> getPartnerBusinessesFromServer(
    Partner partner, {
    required Key key,
    Rx? observe,
  }) async {
    final all = await memoize(
      key,
      () async {
        final ids = partner.businesses?.map((e) => e.id) ?? [];
        if (isNullOrEmpty(ids)) {
          bPrint("partner doesnt have businesses");
          return <Business>[];
        }
        return <Business>[];
      },
      runWhenChanged: observe,
    );
    businesses.clear();
    businesses.addAll(all);
    return businesses;
  }

  Future<List<Business>> getNearestBusinesses({
    BusinessCategory? forCategory,
    Key key = const ValueKey("getNearestBusinesses"),
    Rx? observe,
  }) async {
    final q = StrapiCollectionQuery(
      collectionName: Business.collectionName,
      requiredFields: Business.fields(),
    );
    q.requireCompenentField(
      Business.fields.address,
      Address.fields(),
    );
    return memoize(
      key,
      () async {
        if (forCategory is BusinessCategory) {
          q.whereModelField(
            field: Business.fields.business_category,
            query: StrapiModelQuery(
              requiredFields: BusinessCategory.fields(),
            )..whereField(
                field: BusinessCategory.fields.name,
                query: StrapiFieldQuery.equalTo,
                value: forCategory.name,
              ),
          );
        }
        final found = await Businesses.executeQuery(q);
        return found;
      },
      runWhenChanged: observe,
    );
  }

  Map<DateTime, List> getHolidaysOfBusiness(Business business) {
    final holidays = (business.holidays ?? []);
    final returnable = <DateTime, List>{};
    holidays.forEach((element) {
      final date = element.date;
      final name = element.nameOfTheHoliday;
      if (date is DateTime && name is String) {
        returnable.addAll({
          date: [name]
        });
      }
    });
    return returnable;
  }

  Future<List<Timing>> getAvailableSlots(
      Business business, Employee employee, DateTime date,
      {Key key = const ValueKey("getAvailableSlots")}) async {
    ///check whether date is of now/today
    final difference = DateTime.now().difference(date);
    if (difference.inSeconds > 7) {
      return [];
    }
    return memoize(key, () async {
      final businessId = business.id;
      final employeeId = employee.id;
      final dayName = DateFormatters.dayName.format(date).toLowerCase();
      if (businessId is! String && employeeId is String) {
        throw BappImpossibleException("businessId or employeeId is null");
      }
      final response = await StrapiCollection.customEndpoint(
        collection: "businesses",
        endPoint: "availableTimeSlots",
        params: {
          "businessId": "$businessId",
          "employeeId": "$employeeId",
          "date": "$date",
          "dayName": "$dayName",
        },
      );
      final data = response.isNotEmpty ? response.first : {};
      if (data is Map) {
        final String? error = data["error"];
        if (error is String) {
          throw throwExceptionForStrapiResponse(error, data);
        }

        final freeTime = data["freeTime"];

        if (freeTime is List) {
          final returnable = <Timing>[];
          freeTime.forEach(
            (e) {
              final start = DateTime.tryParse(e["start"])?.toLocal();
              final end = DateTime.tryParse(e["end"])?.toLocal();
              if (start is DateTime && end is DateTime) {
                returnable.add(
                  Timing(from: start, to: end),
                );
              } else {
                bPrint("NOOOOOOOOOOOOOOOO");
              }
            },
          );
          return returnable;
        }
      }
      throw EmptyResponseException();
    });
  }

  Future<Map<String, List<Employee>>> availableEmployees(
    Business business,
    DateTime forDay,
  ) async {
    final id = business.id;
    if (id is! String) {
      throw BappImpossibleException("businessId is null");
    }
    final response = await StrapiCollection.customEndpoint(
      collection: Business.collectionName,
      endPoint: "availableEmployees",
      params: {
        "businessId": "$id",
        "date": forDay.toIso8601String(),
      },
    );
    if (response.isEmpty) {
      throw EmptyResponseException();
    } else {
      final data = response.first;
      if (data is Map && data.isNotEmpty) {
        final error = data["error"];
        if (error is String) {
          throw throwExceptionForStrapiResponse(error, data);
        }
        final availableEmployees = data["availableEmployees"] ?? {};
        final unAvailableEmployees = data["unAvailableEmployees"] ?? {};
        if (availableEmployees is List && unAvailableEmployees is List) {
          return {
            "availableEmployees": List.generate(
              availableEmployees.length,
              (index) => Employee.fromSyncedMap(
                availableEmployees[index],
              ),
            ),
            "unAvailableEmployees": List.generate(
              unAvailableEmployees.length,
              (index) => Employee.fromSyncedMap(unAvailableEmployees[index]),
            ),
          };
        }
        throw EmptyResponseException();
      } else {
        throw BappImpossibleException(
          "response should be populated with availableEmployees,unavailableEmployees or error",
        );
      }
    }
  }

  @override
  Future dispose() async {
    super.dispose();
  }
}
