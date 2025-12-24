class UserAddress {
  final int addressId;
  final int userId;
  final String recipientName;
  final String phone;
  final String provinceOrCity;
  final String district;
  final String ward;
  final String addressLine;

  UserAddress({
    required this.addressId,
    required this.userId,
    required this.recipientName,
    required this.phone,
    required this.provinceOrCity,
    required this.district,
    required this.ward,
    required this.addressLine
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      addressId: json['addressId'],
      userId: json['userId'],
      recipientName: json['recipientName'],
      phone: json['phone'],
      provinceOrCity: json['provinceOrCity'],
      district: json['district'],
      ward: json['ward'],
      addressLine: json['addressLine']
    );
  }
}