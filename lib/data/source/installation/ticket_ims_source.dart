part of '../sources.dart';

class TicketImsSource {
  static const _baseURL = '${UrlsIMS.host}/api/public';

  Future<TicketIms?> listDetailTicketIMS(String ticketNumber) async {
    try {
      final uri = Uri.parse(
          '$_baseURL/get-detail-material?ticket_number=$ticketNumber');
      final response = await http.get(uri, headers: {
        'Authorization':
            'Bearer KFhNebzV8EvLWTyWYZ0XPKafNGDwtANTN7WzZtka_TfGTqPQtmANLiRfMtCI8JKyxg9'
      });

      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        final Map<String, dynamic> resBody = jsonDecode(response.body);
        DMethod.log('Ticket detail: ${resBody.toString()}');

        // Akses ke data dari "result"
        if (resBody['result'] != null &&
            resBody['result']['data'] != null &&
            resBody['result']['data'].isNotEmpty) {
          // Parse the first item in the data array as TicketIms
          return TicketIms.fromJson(resBody['result']['data'][0]);
        } else {
          DMethod.log('No ticket IMS found', colorCode: 1);
          return null;
        }
      } else {
        DMethod.log('Failed to load detail ticket: ${response.statusCode}',
            colorCode: 1);
        return null;
      }
    } catch (e) {
      if (e is http.ClientException) {
        DMethod.log('Network error: ${e.message}', colorCode: 1);
      } else {
        DMethod.log('Error: ${e.toString()}', colorCode: 1);
      }
      return null;
    }
  }
}
