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
class NoteListFirstBatchLoaded implements Message {
  final List<Note> notes;

  const NoteListFirstBatchLoaded(this.notes);
}

@immutable
class NoteListNextBatchRequested implements Message {}

@immutable
class NoteListNextBatchLoaded implements Message {
  final List<Note> notes;

  const NoteListNextBatchLoaded(this.notes);
}

@immutable
class NoteListReloadRequested implements Message {}

@immutable
class MovedToNote implements Message {
  final int noteIdx;

  const MovedToNote(this.noteIdx);
}

@immutable
class NoteContentLoaded implements Message {
  final String fileName;
  final String text;

  const NoteContentLoaded(this.fileName, this.text);
}

@immutable
class NoteContentLoadedingFailed implements Message {
  const NoteContentLoadedingFailed();
}
