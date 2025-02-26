import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:notedok/messages.dart';

// This is the only place where side-effects are allowed!

@immutable
abstract class Command {
  void execute(void Function(Message) dispatch);

  static Command none() {
    return None();
  }

  static Command getInitialCommand() {
    return InitializeApp();
  }
}

@immutable
class None implements Command {
  @override
  void execute(void Function(Message) dispatch) {}
}

@immutable
class InitializeApp implements Command {
  @override
  void execute(void Function(Message) dispatch) async {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    if (session.isSignedIn) {
      var idToken = session.userPoolTokensResult.value.idToken;
      safePrint('ID TOKEN: ${idToken.raw}');
    }
  }
}
