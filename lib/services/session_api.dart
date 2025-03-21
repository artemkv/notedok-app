import 'rest_api.dart' as rest;

String session = "";

bool hasSession() {
  return session != "";
}

void killSession() {
  session = "";
}

Future<void> signIn(String idToken) async {
  try {
    var json = await rest.signIn(idToken);
    session = json['session'];
  } catch (e) {
    session = "";
  }
}

Future<T> callApi<T>(
  Future<T> Function() f,
  Future<String> Function() getIdToken,
) async {
  if (!hasSession()) {
    // print(">> No session, first need to sign in");
    var idToken = await getIdToken();
    await signIn(idToken);
    return f();
  }
  try {
    // print(">> Has session, go to the api directly");
    return await f();
  } on rest.RestApiException catch (e) {
    if (e.statusCode == 401) {
      // print(">> Oops, expired, will sign in again and retry");
      var idToken = await getIdToken();
      await signIn(idToken);
      return f();
    }
    rethrow;
  }
}

Future<dynamic> getFiles(
  int pageSize,
  String continuationToken,
  Future<String> Function() getIdToken,
) {
  return callApi(
    () => rest.getFiles(pageSize, continuationToken, session),
    getIdToken,
  );
}

Future<String> getFile(String fileName, Future<String> Function() getIdToken) {
  return callApi(() => rest.getFile(fileName, session), getIdToken);
}

Future<String> postFile(
  String fileName,
  String content,
  Future<String> Function() getIdToken,
) {
  return callApi(() => rest.postFile(fileName, content, session), getIdToken);
}

Future<String> putFile(
  String fileName,
  String content,
  Future<String> Function() getIdToken,
) {
  return callApi(() => rest.putFile(fileName, content, session), getIdToken);
}

Future<String> renameFile(
  String fileName,
  String newFileName,
  Future<String> Function() getIdToken,
) {
  return callApi(
    () => rest.renameFile(fileName, newFileName, session),
    getIdToken,
  );
}

Future<String> deleteFile(
  String fileName,
  Future<String> Function() getIdToken,
) {
  return callApi(() => rest.deleteFile(fileName, session), getIdToken);
}

Future<String> deleteAllFiles(Future<String> Function() getIdToken) {
  return callApi(() => rest.deleteAllFiles(session), getIdToken);
}
