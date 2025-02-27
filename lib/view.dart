import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notedok/custom_components.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/model.dart';
import 'package:notedok/theme.dart';

// These should be all stateless! No side effects allowed!

const textPadding = 12.0;
const textFontSize = 16.0;

Widget home(
  BuildContext context,
  Model model,
  void Function(Message) dispatch,
) {
  if (model is RetrievingFileListModel) {
    return retrievingFileList(context, model, dispatch);
  }
  if (model is NoteListViewModel) {
    return noteListView(context, model, dispatch);
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
    // TODO: should I be able to search while retrieving the list of notes?
    appBar: AppBar(
      title: Text(
        'NotedOK',
        style: GoogleFonts.openSans(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
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

Widget noteListView(
  BuildContext context,
  NoteListViewModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: SearchableAppBar(),
    drawer: drawer(context, dispatch),
    body: NoteListView(key: UniqueKey(), model: model, dispatch: dispatch),
    backgroundColor: Colors.white,
  );
}

Widget noteView(String fileName) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: textPadding / 2),
                child: Text(
                  fileName,
                  style: GoogleFonts.openSans(
                    textStyle: const TextStyle(fontSize: textFontSize),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(textPadding * 1.6),
                      child: Text(
                        """Here should be the note text""",
                        style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            fontSize: textFontSize * 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
