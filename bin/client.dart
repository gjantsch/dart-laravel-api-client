import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:pnp_api/laravel_sanctum_request.dart';

void main(List<String> arguments) async {

  stdin.echoMode = true;
  print('Username:');
  var username = stdin.readLineSync();

  stdin.echoMode = false;
  print('Password:');
    var password = stdin.readLineSync();

  var api = laravelSanctumRequest('http://127.0.0.1:8000', '/api/v2/hello', '/api/v2/bye', '/api/v2/user');
  var jsonResponse = await api.login(username ?? '', password ?? '');
  print(jsonResponse);

  if (jsonResponse != null) {
    var user = await api.getUser();
    var produtos = await api.get('/api/v2/produtos', queryParameters: {'q': 'kombucha'});
    print('====== RESPOSTA =======');
    print(user);
    print(produtos);
    print('====== TOKENS =======');
    print(api);

  } else {
    print('Login failed completely.');
  }
}


