import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:notedok/services/amplifyconfiguration.dart';
import 'package:notedok/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // https://docs.amplify.aws/gen1/flutter/build-a-backend/auth/set-up-auth/
  // https://docs.amplify.aws/flutter/build-a-backend/auth/set-up-auth/
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured Amplify');
  } on Exception catch (err) {
    safePrint('Error configuring Amplify: $err');
  }

  runApp(const MainApp());
}
