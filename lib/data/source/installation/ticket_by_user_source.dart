part of '../sources.dart';

class TicketByUserSource {
  static const _baseURL = '${UrlsDms.host}/PatroliApi';

  Future<List<TicketByUser>?> listTicketByUserCM(String username) async {
    try {
      final uri =
          Uri.parse('$_baseURL/getTicketByUser?param1=$username&param2=2');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer xzvOowuH6nFdXJH2dz8ZxHX2hWSR7skvbnVzdQ=='
      });

      DMethod.logResponse(response);
      if (response.statusCode == 200) {
        final Map<String, dynamic> resBody = jsonDecode(response.body);

        // Access the 'data' key in the response
        final List<dynamic> data = resBody['data'];

        DMethod.log('Number of tickets found: ${data.length}', colorCode: 1);

        final List<TicketByUser> closedTickets = data
            .map((e) => TicketByUser.fromJson(Map<String, dynamic>.from(e)))
            .where((ticket) => ticket.ticketStatus?.toLowerCase() == 'closed')
            .toList();

        DMethod.log('Number of closed tickets CM: ${closedTickets.length}',
            colorCode: 1);
        return closedTickets;
      } else {
        DMethod.log(
            'Failed to load list ticket by users: ${response.statusCode}',
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

  Future<List<TicketByUser>?> listTicketByUserPM(String username) async {
    try {
      final uri =
          Uri.parse('$_baseURL/getTicketByUser?param1=$username&param2=3');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer xzvOowuH6nFdXJH2dz8ZxHX2hWSR7skvbnVzdQ=='
      });

      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        final Map<String, dynamic> resBody = jsonDecode(response.body);

        // Access the 'data' key in the response
        final List<dynamic> data = resBody['data'];

        DMethod.log('Number of tickets found: ${data.length}', colorCode: 1);

        final List<TicketByUser> closedTickets = data
            .map((e) => TicketByUser.fromJson(Map<String, dynamic>.from(e)))
            .where((ticket) => ticket.ticketStatus?.toLowerCase() == 'closed')
            .toList();

        DMethod.log('Number of closed tickets PM: ${closedTickets.length}',
            colorCode: 1);
        return closedTickets;
      } else {
        DMethod.log(
            'Failed to load list ticket by users: ${response.statusCode}',
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
