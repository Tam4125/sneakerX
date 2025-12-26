import 'dart:convert';

import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_stripe_intent_request.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_stripe_intent_response.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class PaymentService {
  static const String baseUrl = "${AppConfig.baseUrl}/payments";

  Future<CreateStripeIntentResponse?> createStripeIntent(CreateStripeIntentRequest request) async {
    String url = "$baseUrl/create/stripe-intent";

    try {
      final response = await ApiClient.post(
          url,
          request.toJson()
      );

      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {

        // Parse the ApiResponse wrapper first
        final apiResponse = ApiResponse<CreateStripeIntentResponse>.fromJson(
            jsonMap,
                (data) => CreateStripeIntentResponse.fromJson(data as Map<String, dynamic>)
        );

        return apiResponse.data;
      } else {
        final errorMap = jsonDecode(response.body);
        throw Exception(errorMap['message'] ?? "Error create stripe payment intent");
      }
    } catch (e) {
      throw Exception("Error create stripe payment intent: $e");
    }
  }
}