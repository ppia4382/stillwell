import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FitbitRemoteDatasource {
  final String _baseUrl = 'www.fitbit.com';
  final String _tokenUrl = 'https://api.fitbit.com/oauth2/token';

  Future<String?> getAuthCode() async {
    final clientId = dotenv.env['FITBIT_CLIENT_ID'];
    const redirectUri = "stillwell://callback";

    final url = Uri.https(_baseUrl, '/oauth2/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'activity sleep heartrate',
      'expires_in': '604800',
    });

    final result = await FlutterWebAuth2.authenticate(
      url: url.toString(),
      callbackUrlScheme: "stillwell",
    );

    return Uri.parse(result).queryParameters['code'];
  }

  Future<String> exchangeCodeForToken(String code) async {
    final clientId = dotenv.env['FITBIT_CLIENT_ID'];
    final clientSecret = dotenv.env['FITBIT_CLIENT_SECRET'];

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}';

    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'grant_type': 'authorization_code',
        'redirect_uri': 'stillwell://callback',
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'] as String;
    } else {
      throw Exception('Failed to exchange token: ${response.body}');
    }
  }
}