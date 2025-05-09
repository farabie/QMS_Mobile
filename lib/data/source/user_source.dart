part of 'sources.dart';

class UserSource {
  static const _baseURL = '${URLs.host}/api';

  static Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseURL/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer xzvOowuH6nFdXJH2dz8ZxHX2hWSR7skvbnVzdQ==',
        },
        body: {'username': username, 'password': password},
      );
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        Map<String, dynamic> resBody = jsonDecode(response.body);

        // Cek jika result == 'ok' tetapi data kosong
        if (resBody['result'] == 'ok' && resBody['data'].isEmpty) {
          DMethod.log("Login gagal: ${resBody['message']}", colorCode: 1);
          return null; // Login gagal meskipun result 'ok'
        }

        // Cek jika login berhasil
        if (resBody['result'] == 'ok' && resBody['data'].isNotEmpty) {
          return User.fromJson(
              Map.from(resBody['data'][0])); // Ambil data user pertama
        }
      }
      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  Future<bool> logout(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseURL/logout'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'Authorization': 'Bearer xzvOowuH6nFdXJH2dz8ZxHX2hWSR7skvbnVzdQ==',
        },
        body: {
          'user': userId.toString(), // Ensure the userId is sent as a string
        },
      );
      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        Map<String, dynamic> resBody = jsonDecode(response.body);
        if (resBody['result'] == 'ok') {
          DMethod.log(resBody['message'] ?? 'Logout successful', colorCode: 2);
          return true;
        }

        DMethod.log(resBody['message'] ?? 'Logout failed', colorCode: 1);
        return false;
      }

      return false; // Return false if status code is not 200
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false; // Return false in case of an error
    }
  }
}
