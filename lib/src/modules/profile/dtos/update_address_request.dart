class UpdateAddressRequest {
  final int addressId;
  final String recipientName;
  final String phone;
  final String provinceOrCity;
  final String district;
  final String ward;
  final String addressLine;

  UpdateAddressRequest({
    required this.addressId,
    required this.recipientName,
    required this.phone,
    required this.provinceOrCity,
    required this.district,
    required this.ward,
    required this.addressLine,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'recipientName': recipientName,
      'phone': phone,
      'provinceOrCity': provinceOrCity,
      'district': district,
      'ward': ward,
      'addressLine': addressLine
    };
  }
}