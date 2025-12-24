class CreateUserAddressRequest {
  final String recipientName;
  final String phone;
  final String provinceOrCity;
  final String district;
  final String ward;
  final String addressLine;

  CreateUserAddressRequest({
    required this.recipientName,
    required this.phone,
    required this.provinceOrCity,
    required this.district,
    required this.ward,
    required this.addressLine,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientName': recipientName,
      'phone': phone,
      'provinceOrCity': provinceOrCity,
      'district': district,
      'ward': ward,
      'addressLine': addressLine
    };
  }
}