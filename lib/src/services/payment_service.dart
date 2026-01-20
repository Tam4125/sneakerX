import 'package:dio/dio.dart';
import 'package:sneakerx/src/models/payment.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_stripe_intent_request.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_stripe_intent_response.dart';
import 'package:sneakerx/src/modules/checkout/dtos/update_payment_status.dart';
import 'package:sneakerx/src/utils/api_client.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class PaymentService {
  static const String _paymentPath = "/payments";

  Future<ApiResponse<CreateStripeIntentResponse>> createStripeIntent(CreateStripeIntentRequest request) async {
    final endpoint = "$_paymentPath/create/stripe-intent";

    print("CREATE STRIPE INTENT REQUEST??? : ${request.toJson()}");

    try {
      final response = await ApiClient.post(
          endpoint,
          request.toJson()
      );

      print("CREATE STRIPE INTENT RESPONSE??? : ${response.data}");

      return ApiResponse.fromJson(
        response.data,
          (data) => CreateStripeIntentResponse.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Service Error: Create Stripe Intent failed",
        data: null
      );
    }
  }

  Future<ApiResponse<Payment>> updatePaymentStatus(UpdatePaymentStatusRequest request) async {
    final endpoint = "$_paymentPath/${request.paymentId}";

    print("UPDATE PAYMENT REQUEST??? : ${request.toJson()}");

    try {
      final response = await ApiClient.put(
          endpoint,
          request.toJson()
      );

      return ApiResponse.fromJson(
          response.data,
              (data) => Payment.fromJson(data as Map<String, dynamic>)
      );
    } on DioException catch(e) {
      return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? "Service Error: Update payment status failed",
          data: null
      );
    }
  }
}