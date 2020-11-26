library thecountrynumber;

///A library to

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:thephonenumber/data.dart';

/// A CountryNumber.
class TheCountryNumber {
  static List<_TheCountry> _countries = [];

  List<TheCountry> get countries => _countries.map((e) => TheCountry(e)).toList();

  TheCountryNumber._init() {
    final dataJ = json.decode(data) as List;
    dataJ.forEach((element) {
      _countries.add(_TheCountry.fromJson(element));
    });
  }

  static final TheCountryNumber _countryNumber = TheCountryNumber._init();

  factory TheCountryNumber() {
    return _countryNumber;
  }

  String toString2() {
    return _countries.fold("\n",
            (previousValue, element) => previousValue + element.toString() + "\n");
  }

  TheNumber parseNumber({
    String internationalNumber,
    String dialCode,
    String iso2Code,
    String iso3Code,
    String currency,
    String name,
    String englishName,
  }) {
    if (_countries.isEmpty) throw Exception("library is not initialized");
    if (!isNullOrEmpty(internationalNumber)) {
      final tmp = _countries.firstWhere((element) {
        if (isNullOrEmpty(element.dialCode)) {
          return false;
        } else {
          return internationalNumber.startsWith(element.dialCode);
        }
      }, orElse: () {
        return null;
      });
      if (tmp == null) {
        return null;
      }
      return _getNumberForCountry(tmp,
          internationalNumber: internationalNumber);
    }

    if (!isNullOrEmpty(dialCode)) {
      final tmp = _countries.firstWhere((element) {
        if (isNullOrEmpty(element.dialCode)) {
          return false;
        } else {
          return element.dialCode == dialCode;
        }
      }, orElse: () {
        return null;
      });
      if (tmp == null) {
        return null;
      }
      return _getNumberForCountry(tmp);
    }

    if (!isNullOrEmpty(iso2Code)) {
      final tmp = _countries.firstWhere((element) {
        if (isNullOrEmpty(element.iso2Code)) {
          return false;
        } else {
          return element.iso2Code == iso2Code;
        }
      }, orElse: () {
        return null;
      });
      if (tmp == null) {
        return null;
      }
      return _getNumberForCountry(tmp);
    }
    if (!isNullOrEmpty(iso3Code)) {
      final tmp = _countries.firstWhere((element) {
        if (isNullOrEmpty(element.iso3Code)) {
          return false;
        } else {
          return element.iso3Code == iso3Code;
        }
      }, orElse: () {
        return null;
      });
      if (tmp == null) {
        return null;
      }
      return _getNumberForCountry(tmp);
    }
    if (!isNullOrEmpty(currency)) {
      final tmp = _countries.firstWhere((element) {
        if (isNullOrEmpty(element.currency)) {
          return false;
        } else {
          return element.currency == currency;
        }
      }, orElse: () {
        return null;
      });
      if (tmp == null) {
        return null;
      }
      return _getNumberForCountry(tmp);
    }

    if (!isNullOrEmpty(name)) {
      final tmp = _countries.firstWhere((element) {
        if (isNullOrEmpty(element.name)) {
          return false;
        } else {
          return element.name == name;
        }
      }, orElse: () {
        return null;
      });
      if (tmp == null) {
        return null;
      }
      return _getNumberForCountry(tmp);
    }

    if (!isNullOrEmpty(englishName)) {
      final tmp = _countries.firstWhere(
            (element) {
          if (isNullOrEmpty(element.englishName)) {
            return false;
          } else {
            return element.englishName == englishName;
          }
        },
        orElse: () {
          return null;
        },
      );
      if (tmp == null) {
        return null;
      }
      return _getNumberForCountry(tmp);
    }
    return null;
  }

  static bool isNullOrEmpty(String s) {
    if (s == null) {
      return true;
    }
    if (s.isEmpty) {
      return true;
    }
    return false;
  }

  static TheNumber _getNumberForCountry(_TheCountry country,
      {String internationalNumber}) {
    final _number = internationalNumber != null
        ? internationalNumber.replaceFirst(country.dialCode, "")
        : "";
    return TheNumber(
      dialCode: country.dialCode,
      number: _number,
      internationalNumber: internationalNumber??"",
      country: TheCountry(country),
      hasNumber: internationalNumber!=null,
      validLength: country.dialLengths.any((element) => element==_number.length,)
    );
  }
}


class TheNumber {
  final String dialCode;
  final String number;
  final String internationalNumber;
  final TheCountry country;
  final hasNumber;
  final validLength;

  TheNumber(
      {this.hasNumber=false,this.validLength=false,this.dialCode="", this.number="", this.internationalNumber="",@required this.country}){
    assert(country!=null);
  }

  TheNumber addNumber(String s){
    return TheCountryNumber().parseNumber(internationalNumber: dialCode+s);
  }

  @override
  String toString() {
    return '''hasNumber: $hasNumber\nvalidLength: $validLength\ndialCode: $dialCode\n dialCode: $dialCode\n number: $number\n internationalNumber: $internationalNumber\n$country''';
  }
}

class TheCountry {
  final _TheCountry _country;
  TheCountry(this._country);

  String get iso2=> _country.iso2Code;

  String get iso3=> _country.iso3Code;

  String get currency=> _country.currency;

  String get capital=> _country.capital;

  String get englishName=> _country.englishName;

  String get localName=> _country.name;

  @override
  String toString() {
    return
      '''
      Country:
      $iso2
      $iso3
      $currency
      $capital
      $localName
      $englishName''';
  }
}

class _TheCountry {
  final String name;
  final String dialCode;
  final String iso2Code;
  final String englishName;
  final String iso3Code;
  final String currency;
  final String capital;
  final List<int> dialLengths;

  _TheCountry({
    this.name,
    this.dialCode,
    this.iso2Code,
    this.englishName,
    this.iso3Code,
    this.currency,
    this.capital,
    this.dialLengths,
  });

  static fromJson(Map<String, dynamic> j) {
    return _TheCountry(
      name: j["Name"],
      dialCode: j["DialCode"],
      iso2Code: j["Iso2"],
      englishName: j["EnglishName"],
      iso3Code: j["Iso3"],
      currency: j["Currency"],
      capital: j["Capital"],
      dialLengths: List.castFrom(getDialLengths(j["DialLength"])),
    );
  }

  static List<int> getDialLengths(dynamic d) {
    if (d is String) {
      return [int.parse(d)];
    }
    if (d is int) {
      if (d == -1) {
        return [];
      }
      return [d];
    }
    if (d is Iterable) {
      return List.castFrom(d);
    }
    return [];
  }

  @override
  String toString() {
    return '''$name\n$dialCode\n$iso2Code\n$englishName\n$iso3Code\n$currency\n$capital\n$dialLengths;''';
  }
}
