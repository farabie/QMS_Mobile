part of 'sources.dart';

class SendWhatsAppSource {
  static const _baseURL = '${UrlsWaGateway.host}/direct';

  static Future<void> notifSubmitted({String? toName, String? phone, String? typeTicket, String? qmsId}) async {
    final waData = {
      "to_name": toName,
      "to_number": phone,
      "message_template_id": "55872f7e-3757-425b-9fbc-dae51b45ba7a",
      "channel_integration_id": "0fbb5d54-5fe3-45e2-9250-15d2f3102f50",
      "language": {"code": "id"},
      "parameters": {
        "body": [
          {"key": "1", "value": "type_ticket", "value_text": typeTicket},
          {"key": "2", "value": "qms_id", "value_text": qmsId},
        ]
      }
    };

    const token = "UhNMxUjXhahhLA5-OfrCG80PicOIdDsDu3OZQgyfNgM";

    try {
      final response = await http.post(
        Uri.parse(_baseURL),
        headers: {
          "Authorization": token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(waData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        DMethod.log('Pesan berhasil dikirim: $responseData');
        // DMethod.logResponse(responseData);
      } else {
        DMethod.log('Gagal mengirim pesan: ${response.statusCode} - ${response.body}', colorCode: 1);
      }
    } catch (e) {
      DMethod.log('Failed to send whatsapp ', colorCode: 1);
    }
  }
}
