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

class FirstBatchOfNotesLoaded implements Message {
  final List<Note> notes;

  const FirstBatchOfNotesLoaded(this.notes);
}

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
