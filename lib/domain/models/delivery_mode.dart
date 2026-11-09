enum DeliveryMode { home, office }

extension DeliveryModeX on DeliveryMode {
  String get key => this == DeliveryMode.home ? 'home' : 'office';
  static DeliveryMode fromKey(String? v) =>
      v == 'office' ? DeliveryMode.office : DeliveryMode.home;
}
