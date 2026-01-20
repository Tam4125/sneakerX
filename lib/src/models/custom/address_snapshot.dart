class AddressSnapshot {
  final String recipientName;
  final String phone;
  final String provinceOrCity;
  final String district;
  final String ward;
  final String addressLine;

  AddressSnapshot({
    required this.recipientName,
    required this.phone,
    required this.provinceOrCity,
    required this.district,
    required this.ward,
    required this.addressLine,
  });

  factory AddressSnapshot.fromJson(Map<String, dynamic> json) {
    return AddressSnapshot(
      recipientName: json['recipientName'],
      phone: json['phone'],
      provinceOrCity: json['provinceOrCity'],
      district: json['district'],
      ward: json['ward'],
      addressLine: json['addressLine'],
    );
  }
}