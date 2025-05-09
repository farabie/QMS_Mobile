part of '../sources.dart';

class TicketDetailSource {
  static const _baseURL = '${UrlsDms.host}/PatroliApi';

  Future<TicketDetail?> listDetailTicket(String ticketNumber) async {
    try {
      final uri = Uri.parse('$_baseURL/getTicketDetail?param1=$ticketNumber');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer xzvOowuH6nFdXJH2dz8ZxHX2hWSR7skvbnVzdQ=='
      });

      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        final Map<String, dynamic> resBody = jsonDecode(response.body);
        DMethod.log('Ticket detail: ${resBody.toString()}');

        // Check if the data array is not empty
        if (resBody['data'] != null && resBody['data'].isNotEmpty) {
          // Parse the first item in the data array as TicketDetail
          return TicketDetail.fromJson(resBody['data'][0]);
        } else {
          DMethod.log('No ticket details found', colorCode: 1);
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
