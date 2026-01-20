import 'package:sneakerx/src/modules/seller_product/models/create_attribute_value_request.dart';

class CreateAttributeRequest {
  final String name;
  final List<CreateAttributeValueRequest> values;

  CreateAttributeRequest({
    required this.name,
    required this.values,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'values': values.map((value) => value.toJson()).toList(),
    };
  }
}