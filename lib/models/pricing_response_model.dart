import 'dart:convert';

PricingResponse pricingResponseFromJson(String str) =>
    PricingResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String _asString(dynamic value) => value?.toString() ?? '';
int _asInt(dynamic value) => value is num ? value.toInt() : 0;
double _asDouble(dynamic value) => value is num ? value.toDouble() : 0.0;
bool _asBool(dynamic value) => value == true;

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }
  return const <dynamic>[];
}

DateTime _asDate(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

class PricingResponse {
  final bool success;
  final int code;
  final String message;
  final PricingData data;

  PricingResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory PricingResponse.fromJson(Map<String, dynamic> json) {
    return PricingResponse(
      success: _asBool(json['success']),
      code: _asInt(json['code']),
      message: _asString(json['message']),
      data: PricingData.fromJson(_asMap(json['data'])),
    );
  }
}

class PricingData {
  final List<PricingRow>? rows;
  final int currentPage;
  final int totalPages;
  final UniqueFilters? uniqueFilters;

  PricingData({
    required this.rows,
    required this.currentPage,
    required this.totalPages,
    this.uniqueFilters,
  });

  factory PricingData.fromJson(Map<String, dynamic> json) {
    final rowsJson = _asList(json['rows']);
    return PricingData(
      rows: rowsJson.map((x) => PricingRow.fromJson(_asMap(x))).toList(),
      currentPage: _asInt(json['currentPage']),
      totalPages: _asInt(json['totalPages']),
      uniqueFilters: json['uniqueFilters'] == null
          ? null
          : UniqueFilters.fromJson(_asMap(json['uniqueFilters'])),
    );
  }
}

class PricingRow {
  final String id;
  final String pricingRuleId;
  final String ruleTypeId;
  final String bookingTypeId;
  final String vehicleCategory;
  final String vehicleTypeId;
  final String vehicleSizeId;
  final String cargoTypeId;
  final double dayFixPrice;
  final String dayFixCurrency;
  final String description;
  final String pricingRuleTitle;
  final DateTime effectiveDate;
  final DateTime expiryDate;
  final String status;
  final String transporterId;
  final String fleetId;
  final String pricingType;
  final List<Slab> slabs;
  final Fleet fleet;
  final Currency currency;
  final Calculation calculation;
  final Transporter transporterDetails;

  PricingRow({
    required this.id,
    required this.pricingRuleId,
    required this.ruleTypeId,
    required this.bookingTypeId,
    required this.vehicleCategory,
    required this.vehicleTypeId,
    required this.vehicleSizeId,
    required this.cargoTypeId,
    required this.dayFixPrice,
    required this.dayFixCurrency,
    required this.description,
    required this.pricingRuleTitle,
    required this.effectiveDate,
    required this.expiryDate,
    required this.status,
    required this.transporterId,
    required this.fleetId,
    required this.pricingType,
    required this.slabs,
    required this.fleet,
    required this.currency,
    required this.calculation,
    required this.transporterDetails,
  });

  factory PricingRow.fromJson(Map<String, dynamic> json) {
    return PricingRow(
      id: _asString(json['id']),
      pricingRuleId: _asString(json['pricingRuleId']),
      ruleTypeId: _asString(json['ruleTypeId']),
      bookingTypeId: _asString(json['bookingTypeId']),
      vehicleCategory: _asString(json['vehicleCategory']),
      vehicleTypeId: _asString(json['vehicleTypeId']),
      vehicleSizeId: _asString(json['vehicleSizeId']),
      cargoTypeId: _asString(json['cargoTypeId']),
      dayFixPrice: _asDouble(json['dayFixPrice']),
      dayFixCurrency: _asString(json['dayFixCurrency']),
      description: _asString(json['description']),
      pricingRuleTitle: _asString(json['pricingRuleTitle']),
      effectiveDate: _asDate(json['effectiveDate']),
      expiryDate: _asDate(json['expiryDate']),
      status: _asString(json['status']),
      transporterId: _asString(json['transporterId']),
      fleetId: _asString(json['fleetId']),
      pricingType: _asString(json['pricingType']),
      slabs: _asList(
        json['slabs'],
      ).map((x) => Slab.fromJson(_asMap(x))).toList(),
      fleet: Fleet.fromJson(_asMap(json['fleet'])),
      currency: Currency.fromJson(_asMap(json['currency'])),
      calculation: Calculation.fromJson(_asMap(json['calculation'])),
      transporterDetails: Transporter.fromJson(
        _asMap(json['transporterDetails']),
      ),
    );
  }
}

class Slab {
  final String id;
  final String pricingRuleId;
  final int kmFrom;
  final int kmTo;
  final double ratePerKm;
  final String status;

  Slab({
    required this.id,
    required this.pricingRuleId,
    required this.kmFrom,
    required this.kmTo,
    required this.ratePerKm,
    required this.status,
  });

  factory Slab.fromJson(Map<String, dynamic> json) {
    return Slab(
      id: _asString(json['id']),
      pricingRuleId: _asString(json['pricingRuleId']),
      kmFrom: _asInt(json['kmFrom']),
      kmTo: _asInt(json['kmTo']),
      ratePerKm: _asDouble(json['ratePerKm']),
      status: _asString(json['status']),
    );
  }
}

class Fleet {
  final String id;
  final String idd;
  final String type;
  final String name;
  final String code;
  final String description;
  final Capacity capacity;
  final String status;

  Fleet({
    required this.id,
    required this.idd,
    required this.type,
    required this.name,
    required this.code,
    required this.description,
    required this.capacity,
    required this.status,
  });

  factory Fleet.fromJson(Map<String, dynamic> json) {
    return Fleet(
      id: _asString(json['id']),
      idd: _asString(json['idd']),
      type: _asString(json['type']),
      name: _asString(json['name']),
      code: _asString(json['code']),
      description: _asString(json['description']),
      capacity: Capacity.fromJson(_asMap(json['capacity'])),
      status: _asString(json['status']),
    );
  }
}

class Capacity {
  final String weight;
  final String volume;

  Capacity({required this.weight, required this.volume});

  factory Capacity.fromJson(Map<String, dynamic> json) {
    return Capacity(
      weight: _asString(json['weight']),
      volume: _asString(json['volume']),
    );
  }
}

class Currency {
  final String id;
  final String currencyCode;
  final String currencyName;
  final String currencySymbol;
  final int numericCode;
  final int decimalPlaces;
  final String countryCode;
  final String region;
  final bool isBaseCurrency;
  final String status;

  Currency({
    required this.id,
    required this.currencyCode,
    required this.currencyName,
    required this.currencySymbol,
    required this.numericCode,
    required this.decimalPlaces,
    required this.countryCode,
    required this.region,
    required this.isBaseCurrency,
    required this.status,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: _asString(json['id']),
      currencyCode: _asString(json['currencyCode']),
      currencyName: _asString(json['currencyName']),
      currencySymbol: _asString(json['currencySymbol']),
      numericCode: _asInt(json['numericCode']),
      decimalPlaces: _asInt(json['decimalPlaces']),
      countryCode: _asString(json['countryCode']),
      region: _asString(json['region']),
      isBaseCurrency: _asBool(json['isBaseCurrency']),
      status: _asString(json['status']),
    );
  }
}

class Calculation {
  final double totalDistanceKm;
  final int vehicleQty;
  final int qty;
  final double basePrice;
  final double basePriceAmount;
  final double distanceAmount;
  final double platformCharges;
  final double grossTotal;
  final double serviceTax;
  final double totalAmount;
  final List<Breakdown> breakdown;
  final Rates rates;

  Calculation({
    required this.totalDistanceKm,
    required this.vehicleQty,
    required this.qty,
    required this.basePrice,
    required this.basePriceAmount,
    required this.distanceAmount,
    required this.platformCharges,
    required this.grossTotal,
    required this.serviceTax,
    required this.totalAmount,
    required this.breakdown,
    required this.rates,
  });

  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      totalDistanceKm: _asDouble(json['totalDistanceKm']),
      vehicleQty: _asInt(json['vehicleQty']),
      qty: _asInt(json['qty']),
      basePrice: _asDouble(json['basePrice']),
      basePriceAmount: _asDouble(json['basePriceAmount']),
      distanceAmount: _asDouble(json['distanceAmount']),
      platformCharges: _asDouble(json['platformCharges']),
      grossTotal: _asDouble(json['grossTotal']),
      serviceTax: _asDouble(json['serviceTax']),
      totalAmount: _asDouble(json['totalAmount']),
      breakdown: _asList(
        json['breakdown'],
      ).map((x) => Breakdown.fromJson(_asMap(x))).toList(),
      rates: Rates.fromJson(_asMap(json['rates'])),
    );
  }
}

class Breakdown {
  final String slab;
  final double distanceInSlab;
  final double ratePerKm;
  final double slabAmount;

  Breakdown({
    required this.slab,
    required this.distanceInSlab,
    required this.ratePerKm,
    required this.slabAmount,
  });

  factory Breakdown.fromJson(Map<String, dynamic> json) {
    return Breakdown(
      slab: _asString(json['slab']),
      distanceInSlab: _asDouble(json['distanceInSlab']),
      ratePerKm: _asDouble(json['ratePerKm']),
      slabAmount: _asDouble(json['slabAmount']),
    );
  }
}

class Rates {
  final double platformRate;
  final double serviceTaxRate;

  Rates({required this.platformRate, required this.serviceTaxRate});

  factory Rates.fromJson(Map<String, dynamic> json) {
    return Rates(
      platformRate: _asDouble(json['platformRate']),
      serviceTaxRate: _asDouble(json['serviceTaxRate']),
    );
  }
}

class Transporter {
  final String id;
  final String userType;
  final String displayId;
  final String displayName;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String phoneNumber;
  final bool phoneVerification;
  final bool emailVerification;
  final String status;
  final String companyName;

  Transporter({
    required this.id,
    required this.userType,
    required this.displayId,
    required this.displayName,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.phoneNumber,
    required this.phoneVerification,
    required this.emailVerification,
    required this.status,
    required this.companyName,
  });

  factory Transporter.fromJson(Map<String, dynamic> json) {
    return Transporter(
      id: _asString(json['id']),
      userType: _asString(json['userType']),
      displayId: _asString(json['displayId']),
      displayName: _asString(json['displayName']),
      username: _asString(json['username']),
      firstName: _asString(json['firstName']),
      lastName: _asString(json['lastName']),
      email: _asString(json['email']),
      countryCode: _asString(json['countryCode']),
      phoneNumber: _asString(json['phoneNumber']),
      phoneVerification: _asBool(json['phoneVerification']),
      emailVerification: _asBool(json['emailVerification']),
      status: _asString(json['status']),
      companyName: _asString(json['companyName']),
    );
  }
}

class UniqueFilters {
  final List<String> ruleTypeId;
  final List<String> bookingTypeId;
  final List<String> vehicleCategory;
  final List<String> vehicleTypeId;
  final List<String> vehicleSizeId;
  final List<String> cargoTypeId;

  UniqueFilters({
    required this.ruleTypeId,
    required this.bookingTypeId,
    required this.vehicleCategory,
    required this.vehicleTypeId,
    required this.vehicleSizeId,
    required this.cargoTypeId,
  });

  factory UniqueFilters.fromJson(Map<String, dynamic> json) {
    return UniqueFilters(
      ruleTypeId: _asList(json['ruleTypeId']).map(_asString).toList(),
      bookingTypeId: _asList(json['bookingTypeId']).map(_asString).toList(),
      vehicleCategory: _asList(json['vehicleCategory']).map(_asString).toList(),
      vehicleTypeId: _asList(json['vehicleTypeId']).map(_asString).toList(),
      vehicleSizeId: _asList(json['vehicleSizeId']).map(_asString).toList(),
      cargoTypeId: _asList(json['cargoTypeId']).map(_asString).toList(),
    );
  }
}
