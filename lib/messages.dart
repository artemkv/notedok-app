// Should all be immutable classes and no logic!

import 'package:flutter/material.dart';
import 'package:notedok/domain.dart';

@immutable
abstract class Message {}

@immutable
class SignOutRequested implements Message {}

@immutable
class RetrieveFileListSuccess implements Message {
  final List<String> files;

  const RetrieveFileListSuccess(this.files);
}

@immutable
class NoteListViewFirstBatchLoaded implements Message {
  final List<Note> notes;

  const NoteListViewFirstBatchLoaded(this.notes);
}

@immutable
class NoteListViewNextBatchRequested implements Message {}

@immutable
class NoteListViewNextBatchLoaded implements Message {
  final List<Note> notes;

  const NoteListViewNextBatchLoaded(this.notes);
}

@immutable
class NoteListViewReloadRequested implements Message {}

@immutable
class NoteListViewMoveToPageView implements Message {
  final int noteIdx;

  const NoteListViewMoveToPageView(this.noteIdx);
}

@immutable
class NotePageViewMoveToListView implements Message {}

@immutable
class NotePageViewMovedToNote implements Message {
  final int noteIdx;

  const NotePageViewMovedToNote(this.noteIdx);
}

@immutable
class NotePageViewNoteContentLoaded implements Message {
  final String fileName;
  final String text;

  const NotePageViewNoteContentLoaded(this.fileName, this.text);
}

@immutable
class NotePageViewNoteContentLoadingFailed implements Message {
  const NotePageViewNoteContentLoadingFailed();
}
