import 'package:http/http.dart' as http;
import 'dart:convert';

// Android emulator:
// http://10.0.2.2:8100
// Real device:
const BASE_URL = 'http://192.168.0.14:8100';
// Cloud service:
// const BASE_URL = 'https://notedok.artemkv.net:8100';

class ApiException implements Exception {
  int statusCode;
  String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() {
    return message;
  }
}

class ApiResponseData {
  final dynamic data;

  ApiResponseData(this.data);

  ApiResponseData.fromJson(Map<String, dynamic> json) : data = json['data'];

  @override
  String toString() {
    return 'Data: ${data.toString()}';
  }
}

class ApiResponseError {
  final String error;

  ApiResponseError(this.error);

  ApiResponseError.fromJson(Map<String, dynamic> json) : error = json['err'];

  @override
  String toString() {
    return 'Error: $error';
  }
}

void handleErrors(http.Response response) {
  if (response.statusCode >= 400) {
    ApiResponseError errorResponse = ApiResponseError.fromJson(
      jsonDecode(response.body),
    );
    throw ApiException(response.statusCode, errorResponse.error);
  }
}

dynamic getData(http.Response response) {
  ApiResponseData dataResponse = ApiResponseData.fromJson(
    jsonDecode(response.body),
  );
  return dataResponse.data;
}

Future<dynamic> getJson(String endpoint, String session) async {
  var client = http.Client(); // TODO: re-use client if possible
  var url = Uri.parse('$BASE_URL$endpoint');
  var headers = {'x-session': session};

  try {
    var response = await client.get(url, headers: headers);
    handleErrors(response);
    return getData(response);
  } finally {
    client.close();
  }
}

Future<dynamic> postJson(
  String endpoint,
  Object data, {
  String? session,
}) async {
  var client = http.Client();
  var url = Uri.parse('$BASE_URL$endpoint');
  var headers = <String, String>{};
  if (session != null) {
    headers['x-session'] = session;
  }

  try {
    var response = await client.post(
      url,
      body: jsonEncode(data),
      headers: headers,
    );
    handleErrors(response);
    return getData(response);
  } finally {
    client.close();
  }
}

Future<dynamic> signIn(String idToken) async {
  return await postJson('/signin', {'id_token': idToken});
}

Future<dynamic> getFiles(
  int pageSize,
  String continuationToken,
  String session,
) async {
  return await getJson(
    '/files?pageSize=$pageSize&continuationToken=$continuationToken',
    session,
  );
}
