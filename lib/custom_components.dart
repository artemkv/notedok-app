import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/model.dart';
import 'package:notedok/view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SearchableAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchableAppBar({super.key});

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

    _controller.text = "";
    _searchEmpty = true;
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
            // TODO: search
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
  final NoteListModel model;
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
          thickness: 1,
          indent: 72,
          endIndent: 72,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        var item = widget.model.items[index];
        if (item is NoteListItemNote) {
          return noteListItem(item.note);
        }
        if (item is NoteListItemLoadMoreTrigger) {
          return ListTile(
            title: NoteListItemLoadMore(dispatch: widget.dispatch),
          );
        }
        if (item is NoteListItemLoadingMore) {
          return ListTile(title: noteListItemLoadingMore());
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
            widget.dispatch(NoteListNextBatchRequested());
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
        widget.dispatch(MovedToNote(page));
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
