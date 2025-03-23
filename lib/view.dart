import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notedok/conversions.dart';
import 'package:notedok/custom_components.dart';
import 'package:notedok/domain.dart';
import 'package:notedok/formatting.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/model.dart';
import 'package:notedok/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:markdown/markdown.dart' as md;

// These should be all stateless! No side effects allowed!

const textPadding = 12.0;
const textFontSize = 16.0;

const navigationNoteList = 0;
const navigationSettings = 1;
const navigationSignOut = 2;

const listItemHeight = 176.0;

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
  if (model is FileListRetrievalFailedModel) {
    return fileListRetrievalFailed(context, model, dispatch);
  }
  if (model is NoteListViewModel) {
    return noteListView(context, model, dispatch);
  }
  if (model is NoteListViewLoadingFirstBatchFailedModel) {
    return noteListViewLoadingFirstBatchFailed(context, model, dispatch);
  }
  if (model is NotePageViewModel) {
    return notePageView(context, model, dispatch);
  }
  if (model is NotePageViewNoteLoadingModel) {
    return notePageViewNoteLoading(context, model, dispatch);
  }
  if (model is NotePageViewLoadingNoteContentFailedModel) {
    return notePageViewLoadingNoteContentFailed(context, model, dispatch);
  }
  if (model is NoteEditorModel) {
    return NoteEditor(model: model, dispatch: dispatch);
  }
  if (model is SavingNewNoteModel) {
    return savingNote(context, dispatch);
  }
  if (model is SavingNewNoteFailedModel) {
    return savingNewNoteFailed(context, model, dispatch);
  }
  if (model is SavingNewNoteWithUniquePathFailedModel) {
    return savingNewNoteWithUniquePathFailed(context, model, dispatch);
  }
  if (model is SavingNoteModel) {
    return savingNote(context, dispatch);
  }
  if (model is SavingNoteFailedModel) {
    return savingNoteFailed(context, model, dispatch);
  }
  if (model is RenamingNoteFailedModel) {
    return renamingNoteFailed(context, model, dispatch);
  }
  if (model is RenamingNoteWithUniquePathFailedModel) {
    return renamingNoteWithUniquePathFailed(context, model, dispatch);
  }

  if (model is AppSettingsModel) {
    return AppSettingsEditor(model: model, dispatch: dispatch);
  }
  if (model is AccountDeletionConfirmationStateModel) {
    return AccountDeletionConfirmationScreen(model: model, dispatch: dispatch);
  }
  if (model is DeletingAccountModel) {
    return deletingAccount(context, model);
  }
  if (model is DeletingAccountFailedModel) {
    return deletingAccountFailed(context, model, dispatch);
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

AppBar defaultAppBar(String searchString, BuildContext context) {
  return AppBar(
    title:
        searchString.isEmpty
            ? Text(
              'NotedOK',
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
            : Text(
              searchString,
              style: GoogleFonts.openSans(
                textStyle: const TextStyle(color: Colors.white),
                fontSize: textFontSize,
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
    appBar: defaultAppBar(model.searchString, context),
    drawer: drawer(context, navigationNoteList, dispatch),
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
    appBar: defaultAppBar(model.searchString, context),
    drawer: drawer(context, navigationNoteList, dispatch),
    body: Center(child: spinner()),
    backgroundColor: Colors.white,
  );
}

Widget fileListRetrievalFailed(
  BuildContext context,
  FileListRetrievalFailedModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Failed to load notes',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(color: Colors.white),
          fontSize: textFontSize,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(textPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Failed to load notes: ${model.reason}",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: textFontSize,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dispatch(FileListReloadRequested(model.searchString));
              },
              child: const Center(
                child: Text(
                  "Click to reload",
                  style: TextStyle(fontSize: textFontSize, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget noteListViewLoadingFirstBatchFailed(
  BuildContext context,
  NoteListViewLoadingFirstBatchFailedModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Failed to load notes',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(color: Colors.white),
          fontSize: textFontSize,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(textPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Failed to load notes: ${model.reason}",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: textFontSize,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dispatch(
                  NoteListViewFirstBatchReloadRequested(
                    model.filesToLoad,
                    model.filesToPreload,
                  ),
                );
              },
              child: const Center(
                child: Text(
                  "Click to reload",
                  style: TextStyle(fontSize: textFontSize, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget drawer(
  BuildContext context,
  int selectedIndex,
  void Function(Message) dispatch,
) {
  return NavigationDrawer(
    backgroundColor: lightGrey,
    selectedIndex: selectedIndex,
    children: <Widget>[
      const NavigationDrawerDestination(
        icon: Icon(Icons.list),
        label: Text('Note list'),
      ),
      const NavigationDrawerDestination(
        icon: Icon(Icons.settings_outlined),
        label: Text('Settings'),
      ),
      const NavigationDrawerDestination(
        icon: Icon(Icons.logout),
        label: Text('Sign out'),
      ),
    ],
    onDestinationSelected: (idx) {
      // How moronic is it to dispatch by index?
      // Be careful
      Navigator.pop(context);
      if (idx == navigationNoteList) {
        dispatch(NavigateToNoteListRequested());
        return;
      }
      if (idx == navigationSettings) {
        dispatch(NavigateToAppSettingsRequested());
        return;
      }
      if (idx == navigationSignOut) {
        dispatch(SignOutRequested());
        return;
      }
    },
  );
}

Widget noteListView(
  BuildContext context,
  NoteListViewModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: SearchableAppBar(
      searchString: model.searchString,
      dispatch: dispatch,
    ),
    drawer: drawer(context, navigationNoteList, dispatch),
    body: RefreshIndicator(
      onRefresh: () {
        dispatch(NoteListViewReloadRequested());
        return Future<void>.value(null);
      },
      child:
          model.files.isNotEmpty
              ? NoteList(model: model, dispatch: dispatch)
              // https://blog.okaryo.studio/en/20241005-flutter-non-scroll-widget-refresh-indicator/
              : CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "Nothing found",
                        style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                            fontSize: textFontSize,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

enum NoteListItemContextAction { delete, restore }

Widget noteListItem(Note note, int noteIdx, void Function(Message) dispatch) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      dispatch(NoteListViewMoveToPageView(note, noteIdx));
    },
    child: SizedBox(
      height: listItemHeight,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
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
              ),
              PopupMenuButton(
                iconColor: Colors.grey,
                iconSize: textFontSize,
                onSelected: (action) {
                  if (action == NoteListItemContextAction.delete) {
                    dispatch(NoteListViewDeleteNoteRequested(note));
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem<NoteListItemContextAction>(
                        value: NoteListItemContextAction.delete,
                        child: Text('Delete'),
                      ),
                    ],
              ),
            ],
          ),
          Expanded(
            // TODO: can this show links? Should it?
            child: Padding(
              padding: EdgeInsets.only(top: 4, bottom: 16, left: 16, right: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  note.text,
                  style: GoogleFonts.openSans(fontSize: 14),
                ),
              ),
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

Widget noteListItemDeletingNote() {
  return SizedBox(height: listItemHeight / 2, child: spinner());
}

Widget noteListItemDeletedNote(Note note, void Function(Message) dispatch) {
  return SizedBox(
    height: listItemHeight / 2,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    note.title,
                    style: GoogleFonts.openSans(
                      color: Colors.grey,
                      fontSize: textFontSize,
                      fontWeight: FontWeight.w600,
                      textStyle: TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            PopupMenuButton(
              iconColor: Colors.grey,
              iconSize: textFontSize,
              onSelected: (action) {
                if (action == NoteListItemContextAction.restore) {
                  //dispatch(NoteListViewDeleteNoteRequested(note, noteIdx));
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem<NoteListItemContextAction>(
                      value: NoteListItemContextAction.restore,
                      child: Text('Restore'),
                    ),
                  ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget noteListItemRetryDeletingNote(
  Note note,
  String reason,
  void Function(Message) dispatch,
) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      dispatch(NoteListViewRetryDeletingNoteRequested(note));
    },
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(textPadding),
          child: Text(
            "Failed to delete note: $reason",
            style: const TextStyle(fontSize: textFontSize, color: Colors.red),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Click to re-try",
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        fontSize: textFontSize,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget noteListItemRetryLoadMore(
  final List<String> filesToLoad,
  final List<String> filesToPreload,
  String reason,
  void Function(Message) dispatch,
) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      dispatch(
        NoteListViewNextBatchReloadRequested(filesToLoad, filesToPreload),
      );
    },
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(textPadding),
          child: Text(
            "Failed to load more notes: $reason",
            style: const TextStyle(fontSize: textFontSize, color: Colors.red),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Click to re-try",
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        fontSize: textFontSize,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
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

Widget notePageViewLoadingNoteContentFailed(
  BuildContext context,
  NotePageViewLoadingNoteContentFailedModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Failed to load note',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(color: Colors.white),
          fontSize: textFontSize,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(textPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Failed to load note: ${model.reason}",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: textFontSize,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dispatch(NotePageViewReloadNoteContentRequested());
              },
              child: const Center(
                child: Text(
                  "Click to re-try",
                  style: TextStyle(fontSize: textFontSize, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
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
        ? markdownConverter(
          isMarkdownFile(model.note.fileName),
          model.note.title,
          model.note.text,
        )
        : Container();
  }
}

Widget markdownConverter(bool isMarkdown, String title, String text) {
  return isMarkdown
      ? SelectionArea(
        child: Markdown(
          data: "# $title\n\n$text",
          styleSheet: MarkdownStyleSheet(),
          onTapLink: (text, href, title) {
            if (href != null) {
              try {
                var parsedUrl = Uri.parse(href);
                launchUrl(parsedUrl);
              } catch (err) {
                // Ignore
              }
            }
          },
          extensionSet: md.ExtensionSet(
            md.ExtensionSet.gitHubFlavored.blockSyntaxes,
            md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
          ),
          selectable: false,
        ),
      )
      : SelectionArea(
        child: Markdown(
          data: "# $title (.txt)\n\n${LegacyWikiToMdFormatter().format(text)}",
          styleSheet: MarkdownStyleSheet(),
          onTapLink: (text, href, title) {
            if (href != null) {
              try {
                var parsedUrl = Uri.parse(href);
                launchUrl(parsedUrl);
              } catch (err) {
                // Ignore
              }
            }
          },
          extensionSet: md.ExtensionSet(
            md.ExtensionSet.gitHubFlavored.blockSyntaxes,
            md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
          ),
          selectable: false,
        ),
      );
}

Widget savingNote(BuildContext context, void Function(Message) dispatch) {
  return Scaffold(
    appBar: defaultAppBar("", context),
    drawer: drawer(context, navigationNoteList, dispatch),
    body: Center(child: spinner()),
    backgroundColor: Colors.white,
  );
}

Widget savingNewNoteFailed(
  BuildContext context,
  SavingNewNoteFailedModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Failed to save note',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(color: Colors.white),
          fontSize: textFontSize,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(textPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Failed to save note: ${model.reason}",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: textFontSize,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dispatch(SaveNewNoteRetryRequested(model.title, model.text));
              },
              child: const Center(
                child: Text(
                  "Click to re-try",
                  style: TextStyle(fontSize: textFontSize, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget savingNewNoteWithUniquePathFailed(
  BuildContext context,
  SavingNewNoteWithUniquePathFailedModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Failed to save note',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(color: Colors.white),
          fontSize: textFontSize,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(textPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Failed to save note: ${model.reason}",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: textFontSize,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dispatch(
                  SavingNewNoteWithUniquePathRetryRequested(
                    model.path,
                    model.text,
                  ),
                );
              },
              child: const Center(
                child: Text(
                  "Click to re-try",
                  style: TextStyle(fontSize: textFontSize, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget savingNoteFailed(
  BuildContext context,
  SavingNoteFailedModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Failed to save note',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(color: Colors.white),
          fontSize: textFontSize,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(textPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Failed to save note: ${model.reason}",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: textFontSize,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dispatch(
                  SavingNoteRetryRequested(
                    model.path,
                    model.title,
                    model.text,
                    model.oldTitle,
                    model.oldText,
                  ),
                );
              },
              child: const Center(
                child: Text(
                  "Click to re-try",
                  style: TextStyle(fontSize: textFontSize, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget renamingNoteFailed(
  BuildContext context,
  RenamingNoteFailedModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Failed to save note',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(color: Colors.white),
          fontSize: textFontSize,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(textPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Failed to save note: ${model.reason}",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: textFontSize,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dispatch(
                  RenamingNoteRetryRequested(
                    model.path,
                    model.newPath,
                    model.title,
                    model.text,
                  ),
                );
              },
              child: const Center(
                child: Text(
                  "Click to re-try",
                  style: TextStyle(fontSize: textFontSize, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget renamingNoteWithUniquePathFailed(
  BuildContext context,
  RenamingNoteWithUniquePathFailedModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Failed to save note',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(color: Colors.white),
          fontSize: textFontSize,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(textPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Failed to save note: ${model.reason}",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: textFontSize,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dispatch(
                  RenamingNoteWithUniquePathRetryRequested(
                    model.path,
                    model.newPath,
                    model.title,
                    model.text,
                  ),
                );
              },
              child: const Center(
                child: Text(
                  "Click to re-try",
                  style: TextStyle(fontSize: textFontSize, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget deletingAccountFailed(
  BuildContext context,
  DeletingAccountFailedModel model,
  void Function(Message) dispatch,
) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Failed to delete account',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(color: Colors.white),
          fontSize: textFontSize,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(textPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Failed to delete account: ${model.reason}",
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: textFontSize,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dispatch(AccountDeletionRetryRequested());
              },
              child: const Center(
                child: Text(
                  "Click to re-try",
                  style: TextStyle(fontSize: textFontSize, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget deletingAccount(BuildContext context, DeletingAccountModel model) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Deleting user account',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(color: Colors.white),
          fontSize: textFontSize,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: Center(child: spinner()),
  );
}
