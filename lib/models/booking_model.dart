
class BookingResponse {
  final bool success;
  final int code;
  final String message;
  final BookingData data;

  BookingResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: BookingData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'code': code,
    'message': message,
    'data': data.toJson(),
  };
}

// ==========================
// Data Wrapper
// ==========================
class BookingData {
  final List<BookingRow> rows;
  final int totalItems;
  final int currentPage;
  final int totalPages;

  BookingData({
    required this.rows,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      rows: (json['rows'] as List? ?? [])
          .map((e) => BookingRow.fromJson(e))
          .toList(),
      totalItems: json['totalItems'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'rows': rows.map((e) => e.toJson()).toList(),
    'totalItems': totalItems,
    'currentPage': currentPage,
    'totalPages': totalPages,
  };
}

// ==========================
// Booking Row
// ==========================
class BookingRow {
  final String id;
  final String userId;
  final String bookingCode;
  final dynamic currency;
  final double bookingDistanceKm;
  final double bookingAmount;
  final double totalDistanceKm;
  final double totalAmount;

  final BookingJsonData bookingJsonData;

  final int vehiclesQuantity;
  final String status;
  final String pricingRuleId;
  final String bookingMode;

  final DateTime? scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  final PricingRule pricingRule;
  final Address addresses;

  BookingRow({
    required this.id,
    required this.userId,
    required this.bookingCode,
    this.currency,
    required this.bookingDistanceKm,
    required this.bookingAmount,
    required this.totalDistanceKm,
    required this.totalAmount,
    required this.bookingJsonData,
    required this.vehiclesQuantity,
    required this.status,
    required this.pricingRuleId,
    required this.bookingMode,
    this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.pricingRule,
    required this.addresses,
  });

  factory BookingRow.fromJson(Map<String, dynamic> json) {
    return BookingRow(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      bookingCode: json['bookingCode'] ?? '',
      currency: json['currency'],

      bookingDistanceKm: (json['bookingDistanceKm'] as num?)?.toDouble() ?? 0,
      bookingAmount: (json['bookingAmount'] as num?)?.toDouble() ?? 0,

      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,

      bookingJsonData: BookingJsonData.fromJson(json['bookingJsonData'] ?? {}),

      vehiclesQuantity: json['vehiclesQuantity'] ?? 0,
      status: json['status'] ?? '',
      pricingRuleId: json['pricingRuleId'] ?? '',
      bookingMode: json['bookingMode'] ?? '',

      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : null,

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),

      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,

      pricingRule: PricingRule.fromJson(json['pricingRule'] ?? {}),

      addresses: Address.fromJson(json['addresses'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'bookingCode': bookingCode,
    'currency': currency,
    'bookingDistanceKm': bookingDistanceKm,
    'bookingAmount': bookingAmount,
    'totalDistanceKm': totalDistanceKm,
    'totalAmount': totalAmount,
    'bookingJsonData': bookingJsonData.toJson(),
    'vehiclesQuantity': vehiclesQuantity,
    'status': status,
    'pricingRuleId': pricingRuleId,
    'bookingMode': bookingMode,
    'scheduledAt': scheduledAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
    'pricingRule': pricingRule.toJson(),
    'addresses': addresses.toJson(),
  };
}

// ==========================
// Booking Json Data
// ==========================
class BookingJsonData {
  final UserData userData;

  BookingJsonData({required this.userData});

  factory BookingJsonData.fromJson(Map<String, dynamic> json) {
    return BookingJsonData(userData: UserData.fromJson(json['userData'] ?? {}));
  }

  Map<String, dynamic> toJson() => {'userData': userData.toJson()};
}

// ==========================
// User Data
// ==========================
class UserData {
  final String id;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String status;
  final String userType;

  UserData({
    required this.id,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    required this.status,
    required this.userType,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      status: json['status'] ?? '',
      userType: json['userType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'phoneNumber': phoneNumber,
    'status': status,
    'userType': userType,
  };
}

// ==========================
// Pricing Rule
// ==========================
class PricingRule {
  final String id;
  final String pricingRuleId;
  final String ruleTypeId;
  final String bookingTypeId;
  final String vehicleCategory;
  final String vehicleTypeId;
  final String vehicleSizeId;
  final String cargoTypeId;

  final int dayFixPrice;
  final String dayFixCurrency;

  final String pricingRuleTitle;
  final String status;

  final Fleet fleet;

  PricingRule({
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
    required this.pricingRuleTitle,
    required this.status,
    required this.fleet,
  });

  factory PricingRule.fromJson(Map<String, dynamic> json) {
    return PricingRule(
      id: json['id'] ?? '',
      pricingRuleId: json['pricingRuleId'] ?? '',
      ruleTypeId: json['ruleTypeId'] ?? '',
      bookingTypeId: json['bookingTypeId'] ?? '',
      vehicleCategory: json['vehicleCategory'] ?? '',
      vehicleTypeId: json['vehicleTypeId'] ?? '',
      vehicleSizeId: json['vehicleSizeId'] ?? '',
      cargoTypeId: json['cargoTypeId'] ?? '',
      dayFixPrice: json['dayFixPrice'] ?? 0,
      dayFixCurrency: json['dayFixCurrency'] ?? '',
      pricingRuleTitle: json['pricingRuleTitle'] ?? '',
      status: json['status'] ?? '',
      fleet: Fleet.fromJson(json['fleet'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pricingRuleId': pricingRuleId,
    'ruleTypeId': ruleTypeId,
    'bookingTypeId': bookingTypeId,
    'vehicleCategory': vehicleCategory,
    'vehicleTypeId': vehicleTypeId,
    'vehicleSizeId': vehicleSizeId,
    'cargoTypeId': cargoTypeId,
    'dayFixPrice': dayFixPrice,
    'dayFixCurrency': dayFixCurrency,
    'pricingRuleTitle': pricingRuleTitle,
    'status': status,
    'fleet': fleet.toJson(),
  };
}

// ==========================
// Fleet
// ==========================
class Fleet {
  final String id;
  final String name;
  final String code;
  final String status;

  final Capacity capacity;

  Fleet({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.capacity,
  });

  factory Fleet.fromJson(Map<String, dynamic> json) {
    return Fleet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      status: json['status'] ?? '',
      capacity: Capacity.fromJson(json['capacity'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'status': status,
    'capacity': capacity.toJson(),
  };
}

// ==========================
// Capacity
// ==========================
class Capacity {
  final String weight;
  final String volume;

  Capacity({required this.weight, required this.volume});

  factory Capacity.fromJson(Map<String, dynamic> json) {
    return Capacity(weight: json['weight'] ?? '', volume: json['volume'] ?? '');
  }

  Map<String, dynamic> toJson() => {'weight': weight, 'volume': volume};
}

// ==========================
// Address
// ==========================
class Address {
  final dynamic pickup;
  final dynamic drop;

  Address({this.pickup, this.drop});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(pickup: json['pickup'], drop: json['drop']);
  }

  Map<String, dynamic> toJson() => {'pickup': pickup, 'drop': drop};
}
