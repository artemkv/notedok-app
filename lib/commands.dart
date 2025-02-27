import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:notedok/domain.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/services/session_api.dart';

// This is the only place where side-effects are allowed!

@immutable
abstract class Command {
  void execute(void Function(Message) dispatch);

  static Command none() {
    return None();
  }

  static Command getInitialCommand() {
    return RetrieveFileList();
  }
}

@immutable
class None implements Command {
  @override
  void execute(void Function(Message) dispatch) {}
}

// TODO: consider sign-in explicitly the first time
@immutable
class RetrieveFileList implements Command {
  @override
  void execute(void Function(Message) dispatch) async {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    if (session.isSignedIn) {
      var idToken = session.userPoolTokensResult.value.idToken;

      // TODO: loop until retrieved all batches
      // TODO: make batch size 1000
      var json = await getFiles(10, "", () => Future.value(idToken.raw));
      var getFilesResponse = GetFilesResponse.fromJson(json);
      // TODO: sort
      var files = getFilesResponse.files.map((f) => f.fileName).toList();

      dispatch(RetrieveFileListSuccess(files));
    }
  }
}
