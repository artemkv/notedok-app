import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/model.dart';
import 'package:notedok/view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SearchableAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String searchString;
  final void Function(Message) dispatch;

  const SearchableAppBar({
    super.key,
    required this.searchString,
    required this.dispatch,
  });

  @override
  State<SearchableAppBar> createState() => _SearchableAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _SearchableAppBarState extends State<SearchableAppBar> {
  bool _searchActivated = false;
  bool _searchEmpty = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.text = widget.searchString;
    _searchEmpty = widget.searchString.isEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_searchActivated) {
      return AppBar(
        leading: BackButton(
          onPressed: () {
            setState(() {
              _searchActivated = false;
            });
          },
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          // TODO: maybe better font
          style: GoogleFonts.openSans(
            textStyle: const TextStyle(color: Colors.white),
          ),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search in titles',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(50)],
          onChanged: (value) {
            setState(() {
              _searchEmpty = value.isEmpty;
            });
          },
          onSubmitted: (value) {
            widget.dispatch(SearchSubmitted(_controller.text));
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions:
            _searchEmpty
                ? []
                : [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () {
                      setState(() {
                        _controller.text = "";
                        _searchEmpty = true;
                      });
                    },
                  ),
                ],
      );
    }
    // Default app bar - search is not activated
    return AppBar(
      title:
          widget.searchString.isEmpty
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
                widget.searchString,
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(color: Colors.white),
                  fontSize: textFontSize,
                ),
              ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () {
            setState(() {
              _searchActivated = true;
            });
          },
        ),
      ],
    );
  }
}

class NoteList extends StatefulWidget {
  final NoteListViewModel model;
  final void Function(Message) dispatch;

  const NoteList({super.key, required this.model, required this.dispatch});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final ItemScrollController _controller = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemScrollController: _controller,
      itemCount: widget.model.items.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 12,
          thickness: 0.5,
          indent: 16,
          endIndent: 16,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        var item = widget.model.items[index];
        if (item is NoteListItemNote) {
          return noteListItem(item.note, index, widget.dispatch);
        }
        if (item is NoteListItemLoadMoreTrigger) {
          return ListTile(
            title: NoteListItemLoadMore(dispatch: widget.dispatch),
          );
        }
        if (item is NoteListItemLoadingMore) {
          return ListTile(title: noteListItemLoadingMore());
        }
        if (item is NoteListItemRetryLoadMore) {
          return ListTile(
            title: noteListItemRetryLoadMore(
              item.filesToLoad,
              item.filesToPreload,
              item.reason,
              widget.dispatch,
            ),
          );
        }

        throw "Unknown type of NoteListItem";
      },
    );
  }
}

class NoteListItemLoadMore extends StatefulWidget {
  final void Function(Message) dispatch;

  const NoteListItemLoadMore({super.key, required this.dispatch});

  @override
  State<NoteListItemLoadMore> createState() => _NoteListItemLoadMoreState();
}

class _NoteListItemLoadMoreState extends State<NoteListItemLoadMore> {
  bool fired = false;

  void setFired() {
    setState(() {
      fired = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: GlobalKey(),
      onVisibilityChanged: (visibilityInfo) {
        if (!fired) {
          if (visibilityInfo.visibleFraction > 0.0) {
            widget.dispatch(NoteListViewNextBatchRequested());
            setFired();
          }
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: spinner(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotePageView extends StatefulWidget {
  final NotePageViewModel model;
  final void Function(Message) dispatch;

  const NotePageView({super.key, required this.model, required this.dispatch});

  @override
  State<NotePageView> createState() => _NotePageViewState();
}

class _NotePageViewState extends State<NotePageView> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.model.currentFileIdx);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      onPageChanged: (page) {
        widget.dispatch(NotePageViewMovedToNote(page));
      },
      scrollDirection: Axis.horizontal,
      controller: _controller,
      itemBuilder: (context, index) {
        return NoteView(model: widget.model, pageIdx: index);
      },
      itemCount: widget.model.files.length,
    );
  }
}

class NoteEditor extends StatefulWidget {
  final NoteEditorModel model;
  final void Function(Message) dispatch;

  const NoteEditor({super.key, required this.model, required this.dispatch});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.model.title;
    _textController.text = widget.model.text;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title:
            widget.model.isNew
                ? Text(
                  'New note',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(color: Colors.white),
                    fontSize: textFontSize,
                  ),
                )
                : Text(
                  'Edit note',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(color: Colors.white),
                    fontSize: textFontSize,
                  ),
                ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: () {
              if (widget.model.isNew) {
                widget.dispatch(
                  SaveNewNoteRequested(
                    _titleController.text,
                    _textController.text,
                  ),
                );
              } else {
                widget.dispatch(
                  SaveNoteRequested(
                    _titleController.text,
                    _textController.text,
                    widget.model.title,
                    widget.model.text,
                  ),
                );
              }
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (widget.model.isNew) {
            widget.dispatch(NewNoteCreationCanceled());
          } else {
            widget.dispatch(NoteEditingCanceled());
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: textPadding,
                left: textPadding * 2,
                right: textPadding * 2,
                bottom: textPadding,
              ),
              child: TextField(
                maxLength: 50,
                controller: _titleController,
                // TODO: maybe only if empty, otherwise auto-focus text?
                autofocus: true,
                style: const TextStyle(fontSize: textFontSize),
                maxLines: 1,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'No title',
                ),
              ),
            ),
            const Divider(height: 12, thickness: 1, indent: 12, endIndent: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: textPadding,
                  left: textPadding * 2,
                  right: textPadding * 2,
                  bottom: textPadding,
                ),
                child: TextField(
                  maxLength: 100000,
                  controller: _textController,
                  autofocus: true,
                  style: const TextStyle(fontSize: textFontSize),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type your text here',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// There is no state now, but since it's copy-paste, I leave it like this
class AppSettingsEditor extends StatefulWidget {
  final AppSettingsModel model;
  final void Function(Message) dispatch;

  const AppSettingsEditor({
    super.key,
    required this.model,
    required this.dispatch,
  });

  @override
  State<AppSettingsEditor> createState() => _AppSettingsEditorState();
}

class _AppSettingsEditorState extends State<AppSettingsEditor> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'Settings',
          style: GoogleFonts.openSans(
            textStyle: TextStyle(color: Colors.white, fontSize: textFontSize),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          widget.dispatch(CancelEditingAppSettingsRequested());
        },
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 32,
                right: 32,
                top: 16,
                bottom: 16,
              ),
              child: Text(
                "Account data",
                style: TextStyle(color: Colors.black, fontSize: textFontSize),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  widget.dispatch(AccountDeletionRequested());
                },
                child: const Text('DELETE ALL ACCOUNT DATA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountDeletionConfirmationScreen extends StatefulWidget {
  final AccountDeletionConfirmationStateModel model;
  final void Function(Message) dispatch;

  const AccountDeletionConfirmationScreen({
    super.key,
    required this.model,
    required this.dispatch,
  });

  @override
  State<AccountDeletionConfirmationScreen> createState() =>
      _DataDeletionConfirmationScreen();
}

class _DataDeletionConfirmationScreen
    extends State<AccountDeletionConfirmationScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.model.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: single-source this app bar
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'Confirm data deletion',
          style: GoogleFonts.openSans(
            textStyle: TextStyle(color: Colors.white, fontSize: textFontSize),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          widget.dispatch(AccountDeletionCanceled());
        },
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(textPadding * 2),
              child: Text(
                "Type 'delete' then press 'DELETE'",
                style: TextStyle(fontSize: textFontSize),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: textPadding,
                left: textPadding * 2,
                right: textPadding * 2,
                bottom: textPadding,
              ),
              child: TextField(
                maxLength: 100,
                controller: _controller,
                autofocus: true,
                style: const TextStyle(fontSize: textFontSize),
                maxLines: 1,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.none,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'delete',
                ),
              ),
            ),
            Center(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed:
                        value.text == "delete"
                            ? () {
                              widget.dispatch(AccountDeletionConfirmed());
                            }
                            : null,
                    child: const Text("DELETE"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
