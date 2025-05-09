part of 'sources.dart';

class InformationJointerSource {
  static const _baseURL = '${URLs.host}/api';

  static Future<List<InformationJointer>?> getInformationJointerSource(
      String servicePoint) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseURL/ServicePointUsers'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
         body: jsonEncode({
          "service_point": servicePoint,
        }),
        // body: {'service_point': servicePoint},
      );

      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) => InformationJointer.fromJson(e)).toList();
      } else {
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
