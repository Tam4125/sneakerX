class CreateAttributeValueRequest {
  final String value;
  final String? imageUrl;

  CreateAttributeValueRequest({
    required this.value,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'imageUrl': imageUrl,
    };
  }
}