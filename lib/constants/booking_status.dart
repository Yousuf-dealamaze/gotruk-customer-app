enum OrderStatus {
  created('CREATED'),
  confirmed('CONFIRMED'),
  assigned('ASSIGNED'),
  atPickup('AT_PICKUP'),
  inTransit('IN_TRANSIT'),
  completed('COMPLETED'),
  delivered('DELIVERED'),
  cancelled('CANCELLED');

  final String value;
  const OrderStatus(this.value);

  /// Convert API string → enum
  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.created, // fallback
    );
  }
}
