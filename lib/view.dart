import 'package:flutter/material.dart';
import 'package:notedok/custom_components.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/model.dart';
import 'package:notedok/theme.dart';

// These should be all stateless! No side effects allowed!

const textFontSize = 16.0;

Widget home(
  BuildContext context,
  Model model,
  void Function(Message) dispatch,
) {
  if (model is RetrievingFileListModel) {
    return retrievingFileList(context, model, dispatch);
  }
  if (model is FileListRetrievedModel) {
    return fileListRetrieved(model, dispatch);
  }
  if (model is SignOutInProgressModel) {
    return signOutInProgress();
  }

  return unknownModel(model);
}

Widget unknownModel(Model model) {
  return Text("Unknown model: ${model.runtimeType}");
}

Widget spinner() {
  return const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [CircularProgressIndicator(value: null)],
  );
}

Widget retrievingFileList(
  BuildContext context,
  RetrievingFileListModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: SearchableAppBar(),
    drawer: drawer(context, dispatch),
    body: Center(child: Expanded(child: spinner())),
    backgroundColor: Colors.white,
  );
}

Widget signOutInProgress() {
  return Material(
    type: MaterialType.transparency,
    child: Container(
      decoration: BoxDecoration(color: blue),
      child: const Column(children: []),
    ),
  );
}

Widget drawer(BuildContext context, void Function(Message) dispatch) {
  return NavigationDrawer(
    children: <Widget>[
      DrawerHeader(
        decoration: BoxDecoration(color: pink),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(2.0),
              child: Text(
                "NotedOK",
                style: TextStyle(fontSize: textFontSize, color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.0),
              child: Text(
                "Access your notes anywhere",
                style: TextStyle(
                  fontSize: textFontSize * 0.8,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      const NavigationDrawerDestination(
        icon: Icon(Icons.logout),
        label: Text('Sign out'),
      ),
    ],
    onDestinationSelected: (idx) {
      Navigator.pop(context);
      dispatch(SignOutRequested());
    },
  );
}

Widget fileListRetrieved(
  FileListRetrievedModel model,
  void Function(Message) dispatch,
) {
  // TODO: See DailyWinView
  return Text(model.files.toString());
}
