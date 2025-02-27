import 'package:flutter/material.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/model.dart';

// These should be all stateless! No side effects allowed!

Widget home(
  BuildContext context,
  Model model,
  void Function(Message) dispatch,
) {
  if (model is RetrievingFileListModel) {
    return retrievingFileList(model, dispatch);
  }
  if (model is FileListRetrievedModel) {
    return fileListRetrieved(model, dispatch);
  }

  return unknownModel(model);
}

Widget unknownModel(Model model) {
  return Text("Unknown model: ${model.runtimeType}");
}

Widget retrievingFileList(
  RetrievingFileListModel model,
  void Function(Message) dispatch,
) {
  return Text("retrieving...");
}

Widget fileListRetrieved(
  FileListRetrievedModel model,
  void Function(Message) dispatch,
) {
  return Text(model.files.toString());
}
