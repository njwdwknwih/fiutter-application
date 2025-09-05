class Address {
  final String id;
  final String label;
  final String fullAddress;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.isDefault,
  });

  factory Address.empty() => Address(
    id: '',
    label: '',
    fullAddress: '',
    city: '',
    state: '',
    zipCode: '',
    isDefault: false,
  );

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'fullAddress': fullAddress,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'isDefault': isDefault,
    };
  }

  factory Address.fromMap(String id, Map<String, dynamic> map) {
    return Address(
      id: id,
      label: map['label'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Address copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? city,
    String? state,
    String? zipCode,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
