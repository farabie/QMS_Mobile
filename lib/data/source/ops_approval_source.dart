part of 'sources.dart';

class OpsApprovalSource {
  static const _baseURL = '${URLs.host}/api';

  Future<List<OpsApproval>?> getApprovalOps(String clusterName) async {
    try {
      final response = await http.get(Uri.parse(
          '$_baseURL/approval-ops/cluster?cluster_name=$clusterName'));
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body) as List<dynamic>;

        return resBody
            .map((item) => OpsApproval.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        throw Exception("Cluster For This Approval is Empty");
      } else {
        DMethod.log('Failed to approval ops : ${response.statusCode}',
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
