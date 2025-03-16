import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notedok/custom_components.dart';
import 'package:notedok/domain.dart';
import 'package:notedok/formatting.dart';
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
  if (model is SignOutInProgressModel) {
    return signOutInProgress();
  }
  if (model is RetrievingFileListModel) {
    return retrievingFileList(context, model, dispatch);
  }
  if (model is FileListRetrievedModel) {
    return fileListRetrieved(context, model, dispatch);
  }
  if (model is NoteListViewModel) {
    return noteListView(context, model, dispatch);
  }
  if (model is NotePageViewModel) {
    return notePageView(context, model, dispatch);
  }
  if (model is NotePageViewNoteLoadingModel) {
    return notePageViewNoteLoading(context, model, dispatch);
  }
  if (model is NoteEditorModel) {
    return NoteEditor(model: model, dispatch: dispatch);
  }
  if (model is SavingNewNoteModel) {
    return savingNote(context, dispatch);
  }
  if (model is SavingNoteModel) {
    return savingNote(context, dispatch);
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

Widget signOutInProgress() {
  return Material(
    type: MaterialType.transparency,
    child: Container(
      decoration: BoxDecoration(color: blue),
      child: const Column(children: []),
    ),
  );
}

AppBar defaultAppBar(BuildContext context) {
  return AppBar(
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
  );
}

Widget retrievingFileList(
  BuildContext context,
  RetrievingFileListModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: defaultAppBar(context),
    drawer: drawer(context, dispatch),
    body: Center(child: spinner()),
    backgroundColor: Colors.white,
  );
}

Widget fileListRetrieved(
  BuildContext context,
  FileListRetrievedModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: defaultAppBar(context),
    drawer: drawer(context, dispatch),
    body: Center(child: spinner()),
    backgroundColor: Colors.white,
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
    appBar: SearchableAppBar(dispatch: dispatch),
    drawer: drawer(context, dispatch),
    body: RefreshIndicator(
      onRefresh: () {
        dispatch(NoteListViewReloadRequested());
        return Future<void>.value(null);
      },
      child: NoteList(model: model, dispatch: dispatch),
    ),
    backgroundColor: Colors.white,
    floatingActionButton: (FloatingActionButton(
      onPressed: () {
        dispatch(CreateNewNoteRequested());
      },
      child: const Icon(Icons.add),
    )),
  );
}

Widget noteListItem(Note note, int noteIdx, void Function(Message) dispatch) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      dispatch(NoteListViewMoveToPageView(note, noteIdx));
    },
    child: SizedBox(
      height: 160,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                note.title,
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
              child: Text(note.text),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget noteListItemLoadingMore() {
  return Row(
    children: [
      Expanded(
        child: Align(
          alignment: Alignment.center,
          child: Padding(padding: const EdgeInsets.all(12.0), child: spinner()),
        ),
      ),
    ],
  );
}

AppBar notePageViewAppBar(
  BuildContext context,
  int noteIdx,
  int notesTotal,
  Note? note,
  void Function(Message) dispatch,
) {
  return AppBar(
    leading: const BackButton(),
    title: Text(
      "${noteIdx + 1}/$notesTotal",
      style: GoogleFonts.openSans(
        textStyle: TextStyle(color: Colors.white),
        fontSize: textFontSize,
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.edit),
        tooltip: 'Edit',
        onPressed: () {
          if (note != null) {
            dispatch(EditNoteRequested(note));
          }
        },
      ),
    ],
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Colors.white,
  );
}

Widget notePageViewNoteLoading(
  BuildContext context,
  NotePageViewNoteLoadingModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: notePageViewAppBar(
      context,
      model.currentFileIdx,
      model.files.length,
      null,
      dispatch,
    ),
    body: Column(children: [Expanded(child: Center(child: spinner()))]),
    backgroundColor: Colors.white,
  );
}

Widget notePageView(
  BuildContext context,
  NotePageViewModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: notePageViewAppBar(
      context,
      model.currentFileIdx,
      model.files.length,
      model.note,
      dispatch,
    ),
    body: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        dispatch(NotePageViewMoveToListView());
      },
      child: Column(
        children: [
          Expanded(
            child: NotePageView(
              key: UniqueKey(),
              model: model,
              dispatch: dispatch,
            ),
          ),
        ],
      ),
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
        ? Markdown(
          data:
              "# ${model.note.title}\n\n${LegacyWikiToMdFormatter().format(model.note.text)}",
        )
        : Container();
  }
}

Widget savingNote(BuildContext context, void Function(Message) dispatch) {
  return Scaffold(
    appBar: defaultAppBar(context),
    drawer: drawer(context, dispatch),
    body: Center(child: spinner()),
    backgroundColor: Colors.white,
  );
}
