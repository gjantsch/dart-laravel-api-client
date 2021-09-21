import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
export 'package:pnp_api/laravel_sanctum_request.dart';

/// Provides login, logout and generic requests to Laravel/Sanctum APIs.
class laravelSanctumRequest {
  bool _isHttps = false;
  String _apiURL = '';
  String _loginEndpoint = '';
  String _logoutEndpoint = '';
  String _meEndpoint = '';
  String _token = '';

  laravelSanctumRequest(String apiUrl, String loginEndpoint,
      String? logoutEndpoint, String? meEndpoint) {
    _loginEndpoint = loginEndpoint;
    _logoutEndpoint = logoutEndpoint ?? '';
    _meEndpoint = meEndpoint ?? '';

    /// parse the url string to check it is sane
    Uri uri = Uri.parse(apiUrl);
    _isHttps = (uri.scheme == 'https');
    _apiURL = uri.host;

    if (uri.hasPort) {
      _apiURL = "${uri.host}:${uri.port}";
    }

    /// attempt to get the HEAD at login endpoint to make sure it is valid
    http.head(getUri(loginEndpoint));

  }

  @override
  String toString() {
    return "Bearer $_token";
  }

  /// Build URI.
  Uri getUri(String resource, {Map<String, dynamic>? queryParameters}) {
    return _isHttps
        ? Uri.https(_apiURL, resource, queryParameters)
        : Uri.http(_apiURL, resource, queryParameters);
  }

  /// Attempt to login.
  Future<Map<String, dynamic>> login(String username, String password) async {
    Uri uri = getUri(_loginEndpoint);

    var response =
        await http.post(uri, body: {'name': username, 'password': password});
    Map<String, dynamic>? data;

    if (response.statusCode == 200) {
      data = convert.jsonDecode(response.body) as Map<String, dynamic>;
      _token = data['token'];
    }

    return {'statusCode': response.statusCode, 'response': data};
  }

  /// Logout.
  Future<bool> logout() async {
    Uri uri = getUri(_logoutEndpoint);
    var response =
        await http.get(uri, headers: {'Authorization': 'Bearer $_token'});

    _token = '';
    return true;
  }
  /// Get current user profile.
  Future<Map<String, dynamic>> getUser() async {
    Uri uri = getUri(_meEndpoint);
    var response =
        await http.get(uri, headers: {'Authorization': 'Bearer $_token'});

    Map<String, dynamic>? data;
    if (response.statusCode == 200) {
      data = convert.jsonDecode(response.body) as Map<String, dynamic>;
    }

    return {'statusCode': response.statusCode, 'response': data};
  }

  /// Generic GET Request.
  Future<Map<String, dynamic>> get(String resource,
      {Map<String, dynamic>? queryParameters}) async {
    Uri uri = getUri(resource, queryParameters: queryParameters);
    var response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_token'},
    );

    Map<String, dynamic>? data;
    if (response.statusCode == 200) {
      data = convert.jsonDecode(response.body) as Map<String, dynamic>;
    }

    return {'statusCode': response.statusCode, 'response': data};
  }

  /// Generic POST request.
  Future<Map<String, dynamic>> post(String resource,
      [Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? body]) async {
    Uri uri = getUri(resource, queryParameters: queryParameters);
    var response = await http.post(uri,
        headers: {'Authorization': 'Bearer $_token'}, body: body);

    Map<String, dynamic>? data;
    if (response.statusCode == 200) {
      data = convert.jsonDecode(response.body) as Map<String, dynamic>;
    }

    return {'statusCode': response.statusCode, 'response': data};
  }
}
