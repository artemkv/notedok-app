import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';
import 'package:notedok/commands.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/model.dart';
import 'package:notedok/reducer.dart';
import 'package:notedok/view.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        home: const RootWidget(),
      ),
    );
  }
}

class RootWidget extends StatefulWidget {
  const RootWidget({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<RootWidget> {
  Model model = Model.getInitialModel();

  @override
  void initState() {
    super.initState();
    Command.getInitialCommand().execute(dispatch);
  }

  @override
  Widget build(BuildContext context) {
    return home(context, model, dispatch);
  }

  void dispatch(Message message) {
    setState(() {
      ModelAndCommand result = reduce(model, message);

      model = result.model;

      result.command.execute(dispatch);
    });
  }
}
