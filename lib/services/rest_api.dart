import 'package:http/http.dart' as http;
import 'dart:convert';

// Android emulator:
// http://10.0.2.2:8100
// Real device:
const BASE_URL = 'http://192.168.0.14:8100';
// Cloud service:
// const BASE_URL = 'https://notedok.artemkv.net:8100';

const contentTypeJson = "application/json";
const contentTypeText = "text/plain; charset=utf-8";

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

Future<http.Response> get(String endpoint, String? session) async {
  var client = http.Client(); // TODO: re-use client if possible
  var url = Uri.parse('$BASE_URL$endpoint');
  var headers = <String, String>{};
  if (session != null) {
    headers['x-session'] = session;
  }

  try {
    var response = await client.get(url, headers: headers);
    handleErrors(response);
    return response;
  } finally {
    client.close();
  }
}

Future<http.Response> post(
  String endpoint,
  String content,
  String contentType,
  String? session,
) async {
  var client = http.Client();
  var url = Uri.parse('$BASE_URL$endpoint');
  var headers = <String, String>{"Content-Type": contentType};
  if (session != null) {
    headers['x-session'] = session;
  }

  try {
    var response = await client.post(url, body: content, headers: headers);
    handleErrors(response);
    return response;
  } finally {
    client.close();
  }
}

Future<http.Response> put(
  String endpoint,
  String content,
  String contentType,
  String? session,
) async {
  var client = http.Client();
  var url = Uri.parse('$BASE_URL$endpoint');
  var headers = <String, String>{"Content-Type": contentType};
  if (session != null) {
    headers['x-session'] = session;
  }

  try {
    var response = await client.put(url, body: content, headers: headers);
    handleErrors(response);
    return response;
  } finally {
    client.close();
  }
}

Future<http.Response> delete(String endpoint, String? session) async {
  var client = http.Client(); // TODO: re-use client if possible
  var url = Uri.parse('$BASE_URL$endpoint');
  var headers = <String, String>{};
  if (session != null) {
    headers['x-session'] = session;
  }

  try {
    var response = await client.delete(url, headers: headers);
    handleErrors(response);
    return response;
  } finally {
    client.close();
  }
}

Future<dynamic> signIn(String idToken) async {
  var body = {'id_token': idToken};
  var response = await post('/signin', jsonEncode(body), contentTypeJson, null);
  return getData(response);
}

Future<dynamic> getFiles(
  int pageSize,
  String continuationToken,
  String session,
) async {
  var response = await get(
    '/files?pageSize=$pageSize&continuationToken=$continuationToken',
    session,
  );
  return getData(response);
}

Future<String> getFile(String fileName, String session) async {
  String encodedFileName = Uri.encodeComponent(fileName);
  var response = await get('/files/$encodedFileName', session);
  return response.body;
}

Future<String> postFile(String fileName, String content, String session) async {
  String encodedFileName = Uri.encodeComponent(fileName);
  var response = await post(
    '/files/$encodedFileName',
    content,
    contentTypeText,
    session,
  );
  return response.body;
}

Future<String> putFile(String fileName, String content, String session) async {
  String encodedFileName = Uri.encodeComponent(fileName);
  var response = await put(
    '/files/$encodedFileName',
    content,
    contentTypeText,
    session,
  );
  return response.body;
}

Future<String> renameFile(
  String fileName,
  String newFileName,
  String session,
) async {
  String encodedFileName = Uri.encodeComponent(fileName);
  String encodedNewFileName = Uri.encodeComponent(newFileName);
  var body = {'fileName': encodedFileName, 'newFileName': encodedNewFileName};

  var response = await post(
    '/rename',
    jsonEncode(body),
    contentTypeJson,
    session,
  );
  return response.body; // actually ignored
}

Future<String> deleteFile(String fileName, String session) async {
  String encodedFileName = Uri.encodeComponent(fileName);
  var response = await delete('/files/$encodedFileName', session);
  return response.body; // actually ignored
}
