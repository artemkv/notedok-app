import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/model.dart';
import 'package:notedok/theme.dart';

// These should be all stateless! No side effects allowed!

Widget home(
  BuildContext context,
  Model model,
  void Function(Message) dispatch,
) {
  if (model is ApplicationNotInitializedModel) {
    return applicationNotInitialized(dispatch);
  }

  return unknownModel(model);
}

Widget unknownModel(Model model) {
  return Text("Unknown model: ${model.runtimeType}");
}

Widget applicationNotInitialized(void Function(Message) dispatch) {
  return Material(
    type: MaterialType.transparency,
    child: Container(
      decoration: const BoxDecoration(color: themeColor),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Text(
            'NotedOK',
            style: GoogleFonts.outfit(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
