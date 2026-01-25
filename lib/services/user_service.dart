import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class UserService {
  Future<http.Response> getProfile(String token) async {
    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
