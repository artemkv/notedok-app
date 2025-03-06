import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  if (model is NotePageViewModel) {
    return notePageView(context, model, dispatch);
  }
  if (model is SignOutInProgressModel) {
    return signOutInProgress();
  }
  if (model is NoteLoadingModel) {
    return noteLoading(context, model, dispatch);
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
    body: Center(child: spinner()),
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
    body: NoteList(model: model, dispatch: dispatch),
    backgroundColor: Colors.white,
  );
}

Widget noteListItem(String title, String text) {
  return SizedBox(
    height: 150,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: GoogleFonts.openSans(
                fontSize: textFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          // TODO: can this show links? Should it?
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 16, left: 16, right: 16),
            child: Text(text),
          ),
        ),
      ],
    ),
  );
}

Widget notePageView(
  BuildContext context,
  NotePageViewModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: SearchableAppBar(),
    drawer: drawer(context, dispatch),
    body: Column(
      children: [
        noteHeader(context, model.currentFileIdx, model.files.length),
        Expanded(
          child: NotePageView(
            key: UniqueKey(),
            model: model,
            dispatch: dispatch,
          ),
        ),
      ],
    ),
    backgroundColor: Colors.white,
  );
}

class NoteView extends StatelessWidget {
  final NotePageViewModel model;
  final int pageIdx;

  const NoteView({super.key, required this.model, required this.pageIdx});

  @override
  Widget build(BuildContext context) {
    return model.currentFileIdx == pageIdx
        ? Markdown(data: "**${model.note.title}**\n\n${model.note.text}")
        : Container();
  }
}

Widget noteLoading(
  BuildContext context,
  NoteLoadingModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    // TODO: should I be able to search while retrieving the note?
    appBar: SearchableAppBar(),
    drawer: drawer(context, dispatch),
    body: Column(
      children: [
        noteHeader(context, model.currentFileIdx, model.files.length),
        Expanded(child: Center(child: spinner())),
      ],
    ),
    backgroundColor: Colors.white,
  );
}

Widget noteHeader(BuildContext context, int noteIdx, int notesTotal) {
  return Container(
    decoration: BoxDecoration(color: blue),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Center(
            child: Text(
              "${noteIdx + 1}/$notesTotal",
              style: GoogleFonts.openSans(
                textStyle: TextStyle(color: Colors.white),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
