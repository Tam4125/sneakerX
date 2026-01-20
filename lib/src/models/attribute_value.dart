class AttributeValue {
  final int valueId;
  final int attributeId;
  final String value;
  final String? imageUrl;

  AttributeValue({
    required this.valueId,
    required this.value,
    required this.attributeId,
    this.imageUrl,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      valueId: json['valueId'],
      attributeId: json['attributeId'],
      value: json['value'],
      imageUrl: json['imageUrl'] as String?,
    );
  }


}