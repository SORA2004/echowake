import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkingService {
  Future<dynamic> fetchData(String url) async {
    var uri = Uri.parse(url);
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return null;
    }
  }
}
