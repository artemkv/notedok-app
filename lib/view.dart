import 'package:flutter/material.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/model.dart';

// These should be all stateless! No side effects allowed!

Widget home(
  BuildContext context,
  Model model,
  void Function(Message) dispatch,
) {
  if (model is UserSignedInModel) {
    return userSignedIn(model, dispatch);
  }

  return unknownModel(model);
}

Widget unknownModel(Model model) {
  return Text("Unknown model: ${model.runtimeType}");
}

Widget userSignedIn(UserSignedInModel model, void Function(Message) dispatch) {
  return Text("Signed in");
}
